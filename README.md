# SpecFlow Skill

This repository is the public release projection of the canonical private
`gonovus-ai/spec-flow` source. Send Skill changes to the source repository; do not edit
the projection directly.

## Install as a plugin

This repository is also a plugin marketplace for Claude Code and Codex. Add the
marketplace on the `stable` branch, then install the `specflow` plugin.

```bash
claude plugin marketplace add gonovus-ai/spec-flow-skill#stable
claude plugin install specflow@specflow
```

```bash
codex plugin marketplace add gonovus-ai/spec-flow-skill --ref stable
codex plugin add specflow@specflow
```

Remove an existing standalone Skill before installing the plugin. In Claude Code,
open `/plugin`, choose **Marketplaces**, select `specflow`, and enable auto-update.
To update in Codex, run `codex plugin marketplace upgrade specflow`, then
`codex plugin add specflow@specflow`; the refresh alone keeps the installed copy.
A marketplace added at a release tag stays on that tag: remove the `specflow`
marketplace and add it again on `stable` as above.
The `stable` branch advances after the tagged release passes install checks.

## Reproducible plugin install

Use the release tag when you need to reproduce an installation. If the marketplace
is already registered, remove it before re-adding it at the pinned ref.

```bash
claude plugin marketplace add gonovus-ai/spec-flow-skill#skill-v0.8.0
claude plugin install specflow@specflow
```

```bash
codex plugin marketplace add gonovus-ai/spec-flow-skill --ref skill-v0.8.0
codex plugin add specflow@specflow
```

## Install the Skill only

Install SpecFlow for Codex at user scope from this exact release with either
supported installer:

```bash
gh skill install gonovus-ai/spec-flow-skill specflow@skill-v0.8.0 --agent codex --scope user
npx --yes skills@1.5.23 add https://github.com/gonovus-ai/spec-flow-skill/tree/skill-v0.8.0/skills/specflow --global --agent codex --yes
```

Install the same release for Claude Code at user scope:

```bash
gh skill install gonovus-ai/spec-flow-skill specflow@skill-v0.8.0 --agent claude-code --scope user
npx --yes skills@1.5.23 add https://github.com/gonovus-ai/spec-flow-skill/tree/skill-v0.8.0/skills/specflow --global --agent claude-code --yes
```

Source: `gonovus-ai/spec-flow@29ea017f569a1a1f566ff347d395a4b87014b091`

Release: `skill-v0.8.0`
