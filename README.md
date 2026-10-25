# SpecFlow Skill

This repository is the public release projection of the canonical private
`gonovus-ai/spec-flow` source. Send Skill changes to the source repository; do not edit
the projection directly.

## Install as a plugin

This repository is also a plugin marketplace for Claude Code and Codex. Add the
marketplace at this exact release, then install the `specflow` plugin:

```bash
claude plugin marketplace add gonovus-ai/spec-flow-skill#skill-v0.3.2
claude plugin install specflow@specflow
```

```bash
codex plugin marketplace add gonovus-ai/spec-flow-skill --ref skill-v0.3.2
codex plugin add specflow@specflow
```

The plugin carries the same Skill as the commands below. Install it one way only:
remove a Skill installed with `gh skill` or `npx skills` before installing the
plugin, so the Agent does not load two copies. To move to a later release, remove
the `specflow` marketplace and repeat both commands with the later release tag.

## Install the Skill only

Install SpecFlow for Codex at user scope from this exact release with either
supported installer:

```bash
gh skill install gonovus-ai/spec-flow-skill specflow@skill-v0.3.2 --agent codex --scope user
npx --yes skills@1.5.23 add https://github.com/gonovus-ai/spec-flow-skill/tree/skill-v0.3.2/skills/specflow --global --agent codex --yes
```

Install the same release for Claude Code at user scope:

```bash
gh skill install gonovus-ai/spec-flow-skill specflow@skill-v0.3.2 --agent claude-code --scope user
npx --yes skills@1.5.23 add https://github.com/gonovus-ai/spec-flow-skill/tree/skill-v0.3.2/skills/specflow --global --agent claude-code --yes
```

Source: `gonovus-ai/spec-flow@641fba71843cbd6c93a7233060765644ad7f1aa8`

Release: `skill-v0.3.2`
