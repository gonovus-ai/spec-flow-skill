#!/usr/bin/env bash

set -euo pipefail

repository_name="${1:?repository name is required}"
repository="$(gh api "repos/${repository_name}")"
for setting in secret_scanning secret_scanning_push_protection; do
  if [[ "$(jq -r ".security_and_analysis.${setting}.status" <<<"${repository}")" != "enabled" ]]; then
    echo "Required repository protection is disabled: ${setting}" >&2
    exit 1
  fi
done

immutable_releases="$(gh api "repos/${repository_name}/immutable-releases")"
if ! jq -e '.enabled == true and .enforced_by_owner == true' \
  <<<"${immutable_releases}" >/dev/null; then
  echo "Release immutability must include repository owners" >&2
  exit 1
fi

protected_tags=false
while IFS= read -r ruleset_id; do
  ruleset="$(gh api "repos/${repository_name}/rulesets/${ruleset_id}")"
  if jq -e '
    .target == "tag" and .enforcement == "active" and
    (.conditions.ref_name.include | index("refs/tags/skill-v*")) != null and
    (.bypass_actors | length == 0) and
    ([.rules[].type] | contains(["update", "deletion"]))' \
    <<<"${ruleset}" >/dev/null; then
    protected_tags=true
    break
  fi
done < <(gh api "repos/${repository_name}/rulesets?per_page=100" --jq '.[].id')

if [[ "${protected_tags}" != "true" ]]; then
  echo "Unbypassable Skill release tag immutability ruleset is missing" >&2
  exit 1
fi

# Plugin marketplaces follow stable, so it may only ever fast-forward and never disappear.
protected_stable=false
while IFS= read -r ruleset_id; do
  ruleset="$(gh api "repos/${repository_name}/rulesets/${ruleset_id}")"
  if jq -e '
    .target == "branch" and .enforcement == "active" and
    (.conditions.ref_name.include | index("refs/heads/stable")) != null and
    ((.conditions.ref_name.exclude // []) | index("refs/heads/stable")) == null and
    (.bypass_actors | length == 0) and
    ([.rules[].type] | contains(["deletion", "non_fast_forward"]))' \
    <<<"${ruleset}" >/dev/null; then
    protected_stable=true
    break
  fi
done < <(gh api "repos/${repository_name}/rulesets?per_page=100" --jq '.[].id')

if [[ "${protected_stable}" != "true" ]]; then
  echo "Stable branch ruleset blocking deletion and force pushes is missing" >&2
  exit 1
fi
