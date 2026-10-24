#!/usr/bin/env bash

set -euo pipefail

mode="${1:?mode is required}"
source_root="${2:?source root is required}"
release_tag="${3:?release tag is required}"
claude_code_version="${4:?Claude Code version is required}"
codex_cli_version="${5:?Codex CLI version is required}"

if [[ "${mode}" != "local" && "${mode}" != "release" ]]; then
  echo "Mode must be local or release" >&2
  exit 1
fi
if [[ ! "${release_tag}" =~ ^skill-v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  echo "Release tag must match skill-vX.Y.Z" >&2
  exit 1
fi
plugin_version="${BASH_REMATCH[1]}"
skill_path="${source_root}/skills/specflow/SKILL.md"

for manifest in .claude-plugin/plugin.json .codex-plugin/plugin.json; do
  jq -e --arg version "${plugin_version}" \
    '.name == "specflow" and .version == $version' \
    "${source_root}/${manifest}"
done

if [[ "${mode}" == "release" ]]; then
  grep -Fx "claude plugin marketplace add gonovus-ai/spec-flow-skill#${release_tag}" "${source_root}/README.md"
  grep -Fx "claude plugin install specflow@specflow" "${source_root}/README.md"
  grep -Fx "codex plugin marketplace add gonovus-ai/spec-flow-skill --ref ${release_tag}" "${source_root}/README.md"
  grep -Fx "codex plugin add specflow@specflow" "${source_root}/README.md"
  marketplace_source="gonovus-ai/spec-flow-skill"
else
  marketplace_source="${source_root}"
fi

tools_prefix="$(mktemp -d)"
npm_config_userconfig=/dev/null npm install --global --prefix "${tools_prefix}" \
  "@anthropic-ai/claude-code@${claude_code_version}" \
  "@openai/codex@${codex_cli_version}"
claude_cli="${tools_prefix}/bin/claude"
codex_cli="${tools_prefix}/bin/codex"

"${claude_cli}" plugin validate --strict "${source_root}"

for agent in claude-code codex; do
  clean_home="$(mktemp -d)"
  run() { env -i PATH="${PATH}" HOME="${clean_home}" "$@"; }

  if [[ "${agent}" == "claude-code" ]]; then
    if [[ "${mode}" == "release" ]]; then
      run "${claude_cli}" plugin marketplace add "${marketplace_source}#${release_tag}"
    else
      run "${claude_cli}" plugin marketplace add "${marketplace_source}"
    fi
    run "${claude_cli}" plugin install specflow@specflow
    installed_root="$(run "${claude_cli}" plugin list --json | \
      jq -er --arg version "${plugin_version}" \
        'if length == 1 and .[0].id == "specflow@specflow" and
            .[0].version == $version and .[0].enabled
         then .[0].installPath
         else error("expected exactly one enabled SpecFlow plugin") end')"
  else
    if [[ "${mode}" == "release" ]]; then
      run "${codex_cli}" plugin marketplace add "${marketplace_source}" --ref "${release_tag}"
    else
      run "${codex_cli}" plugin marketplace add "${marketplace_source}"
    fi
    run "${codex_cli}" plugin add specflow@specflow --json | \
      jq -e --arg version "${plugin_version}" \
        '.pluginId == "specflow@specflow" and .version == $version'
    installed_root="${clean_home}/.codex/plugins/cache/specflow/specflow/${plugin_version}"
  fi

  if ! cmp "${skill_path}" "${installed_root}/skills/specflow/SKILL.md"; then
    echo "Installed ${agent} plugin does not carry the released Skill" >&2
    exit 1
  fi
  if find "${installed_root}" -path "${installed_root}/bin" -print -quit | grep -q .; then
    echo "Plugin must not ship executables" >&2
    exit 1
  fi

  if [[ "${agent}" == "claude-code" ]]; then
    run "${claude_cli}" plugin uninstall specflow@specflow
    run "${claude_cli}" plugin list --json | jq -e 'length == 0'
  else
    run "${codex_cli}" plugin remove specflow@specflow
    if [[ -e "${installed_root}" ]]; then
      echo "Plugin residue remains after removal" >&2
      exit 1
    fi
  fi
done
