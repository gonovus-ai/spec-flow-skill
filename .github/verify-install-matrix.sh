#!/usr/bin/env bash

set -euo pipefail

mode="${1:?mode is required}"
source_root="${2:?source root is required}"
release_tag="${3:?release tag is required}"
skills_cli_version="${4:?skills CLI version is required}"

if [[ "${mode}" != "local" && "${mode}" != "release" ]]; then
  echo "Mode must be local or release" >&2
  exit 1
fi

skill_path="${source_root}/skills/specflow/SKILL.md"
skill_body() {
  awk '/^# / { content = 1 } content { print }' "$1"
}
skill_name="$(sed -n 's/^name: //p' "${skill_path}")"
skill_description="$(sed -n 's/^description: //p' "${skill_path}")"
compatible_cli="$(sed -n 's/^compatible-cli: "\(.*\)"$/\1/p' "${skill_path}")"
test -n "${skill_name}" && test -n "${skill_description}" && test -n "${compatible_cli}"

if [[ "${mode}" == "release" ]]; then
  grep -Fx "gh skill install gonovus-ai/spec-flow-skill specflow@${release_tag} --agent codex --scope user" "${source_root}/README.md"
  grep -Fx "npx --yes skills@${skills_cli_version} add https://github.com/gonovus-ai/spec-flow-skill/tree/${release_tag}/skills/specflow --global --agent codex --yes" "${source_root}/README.md"
  grep -Fx "gh skill install gonovus-ai/spec-flow-skill specflow@${release_tag} --agent claude-code --scope user" "${source_root}/README.md"
  grep -Fx "npx --yes skills@${skills_cli_version} add https://github.com/gonovus-ai/spec-flow-skill/tree/${release_tag}/skills/specflow --global --agent claude-code --yes" "${source_root}/README.md"
fi

for installer in gh-skill npx-skills; do
  for agent in codex claude-code; do
    clean_home="$(mktemp -d)"

    if [[ "${installer}" == "gh-skill" ]]; then
      if [[ "${mode}" == "local" ]]; then
        HOME="${clean_home}" GH_CONFIG_DIR="${clean_home}/.config/gh" \
          gh skill install "${source_root}" specflow --from-local \
          --agent "${agent}" --scope user
      else
        HOME="${clean_home}" GH_CONFIG_DIR="${clean_home}/.config/gh" \
          gh skill install gonovus-ai/spec-flow-skill "specflow@${release_tag}" \
          --agent "${agent}" --scope user
      fi
      installed_dir="$(HOME="${clean_home}" \
        GH_CONFIG_DIR="${clean_home}/.config/gh" \
        gh skill list --agent "${agent}" --scope user --json path | \
        jq -er 'if length == 1 then .[0].path
                else error("expected exactly one installed skill") end')"
      installed_skill="${installed_dir}/SKILL.md"
      if [[ "${mode}" == "release" ]]; then
        grep -Fx "    github-ref: refs/tags/${release_tag}" "${installed_skill}"
        grep -Fx "    github-repo: https://github.com/gonovus-ai/spec-flow-skill" "${installed_skill}"
        HOME="${clean_home}" GH_CONFIG_DIR="${clean_home}/.config/gh" \
          gh skill list --agent "${agent}" --scope user --json \
          skillName,sourceURL,scope,version,path | \
          jq -e --arg path "${installed_dir}" \
            --arg ref "${release_tag}" \
            'length == 1 and .[0].skillName == "specflow" and
             .[0].sourceURL == "https://github.com/gonovus-ai/spec-flow-skill" and
             .[0].scope == "user" and .[0].version == $ref and
             .[0].path == $path'
      fi
    else
      if [[ "${agent}" == "codex" ]]; then
        installed_skill="${clean_home}/.agents/skills/specflow/SKILL.md"
      else
        installed_skill="${clean_home}/.${agent/claude-code/claude}/skills/specflow/SKILL.md"
      fi
      if [[ "${mode}" == "local" ]]; then
        package="${source_root}"
      else
        package="https://github.com/gonovus-ai/spec-flow-skill/tree/${release_tag}/skills/specflow"
      fi
      HOME="${clean_home}" npm_config_cache="${clean_home}/.npm" \
        npm_config_userconfig=/dev/null \
        npx --yes "skills@${skills_cli_version}" add "${package}" \
        --global --agent "${agent}" --skill specflow --yes
      if [[ "${mode}" == "release" ]]; then
        jq -e --arg ref "${release_tag}" \
          '.skills.specflow | .ref == $ref and
           .sourceUrl == "https://github.com/gonovus-ai/spec-flow-skill.git" and
           .skillPath == "skills/specflow/SKILL.md"' \
          "${clean_home}/.agents/.skill-lock.json"
      fi
    fi

    test -f "${installed_skill}"
    grep -Fx "name: ${skill_name}" "${installed_skill}"
    grep -Fx "description: ${skill_description}" "${installed_skill}"
    installed_compatible_cli="$(sed -n 's/^compatible-cli: //p' "${installed_skill}" | tr -d "'\"")"
    test "${installed_compatible_cli}" = "${compatible_cli}"
    cmp <(skill_body "${skill_path}") <(skill_body "${installed_skill}")

    installed_dir="${installed_skill%/SKILL.md}"
    while IFS= read -r bundled_path; do
      [[ "${bundled_path}" == "SKILL.md" ]] && continue
      if ! cmp "${source_root}/skills/specflow/${bundled_path}" \
        "${installed_dir}/${bundled_path}"; then
        echo "Bundled file missing or changed after install: ${bundled_path}" >&2
        exit 1
      fi
    done < <(cd "${source_root}/skills/specflow" && find . -type f -print | sed 's|^\./||' | sort)

    if [[ "${installer}" == "npx-skills" ]]; then
      HOME="${clean_home}" npm_config_cache="${clean_home}/.npm" \
        npm_config_userconfig=/dev/null \
        npx --yes "skills@${skills_cli_version}" remove \
        --global --agent "${agent}" --skill specflow --yes
      lock_file="${clean_home}/.agents/.skill-lock.json"
      if [[ -e "${lock_file}" ]]; then
        jq -e '.skills == {}' "${lock_file}"
      fi
    else
      rm -r "${installed_skill%/SKILL.md}"
    fi
    test ! -e "${installed_skill}"
    if find "${clean_home}" -path '*/skills/specflow*' -print -quit | grep -q .; then
      echo "Skill residue remains after removal" >&2
      exit 1
    fi
  done
done
