---
name: specflow
description: Author and govern authoritative Specs and the Project Glossary through the supported SpecFlow CLI.
compatible-cli: "@gonovus-ai/spec-flow-cli@0.2.0"
---

# SpecFlow

Use the official public CLI as the only SpecFlow operation boundary. Before any
authentication or resource command, check whether `specflow` is installed and, when
it is, run `specflow --version`.

- If `specflow` is not installed, run only this exact installation command. If
  installation fails, stop. Then run `specflow --version` again and require `0.2.0`:

```bash
npm install --global @gonovus-ai/spec-flow-cli@0.2.0
```

- If the installed version is different, stop and show the User that exact install
  command as the repair command. Do not run that repair command automatically or
  silently upgrade or downgrade an existing global installation.
- If the installed version is `0.2.0`, continue without running the install command or
  changing global state.
- Do not replace the pinned version with `latest`, a raw HTTP command, or a private
  copy. Do not update the Skill or CLI automatically.

Installing the Skill or CLI never starts authentication. Device Authorization remains
a separate, explicit User operation when SpecFlow access is actually needed.

The CLI uses its built-in public origin. Pass `--server <origin>` only when the User
names a different SpecFlow origin, and use that same flag on authentication and every
resource command:

```bash
specflow auth login
specflow project list
```

The resulting independently revocable CLI Session belongs to the User. It carries
that User's current Role only within its approval-time Project scope. Always pass an
explicit `--project-id` after Project Creation or Discovery. Do not register an Agent
identity or request an Agent grant.

## Operating contract

- Manage public Task sharing only when the User requests it. Read the independent
  sharing version with `specflow project sharing read --project-id <id>`; use
  `specflow project sharing set --project-id <id> --public true|false
  --expected-version <version> --idempotency-key <uuid>` with an authorized CLI
  Session. Retain the same key and intent after an uncertain response. A replay
  reports the current switch and cannot reopen a Project another command closed.
  Public sharing exposes Task fields and current description assets, and grants
  no Workspace membership, Spec/Glossary, task-resource or comment-asset access.
  Archive and Trash close sharing; Restore keeps it private until explicitly
  enabled again. Project Read Tokens cannot manage sharing.

- Read the current User's notification inbox with `notification list`. A target
  never grants access: use the fresh target returned by `notification read
  --notification-id <uuid> --idempotency-key <uuid>` before navigating. `notification
  read-all` and `notification clear` require an explicit UUID command key and an
  unrestricted CLI Session; clear only when the User requests it. Retain the key
  after an ambiguous outcome so retrying cannot change newer entries. Read category
  preferences with `notification preferences get`; update only requested fields
  through `notification preferences update --expected-version <version> --preferences <json> --idempotency-key
  <uuid>`. Project-scoped Sessions can read admitted targets, while Project Read
  Tokens cannot access personal notifications. Do not claim scheduled reminders,
  external delivery, or live Gateway push from this durable inbox.

- When the User asks to associate a Task with supporting resources, use
  `work-item resource-link list|add|remove` with explicit Project and Task identities.
  A `spec` target uses its stable `--spec-id`, optionally `--spec-project-id`;
  `document` and `other` targets use a User-authored name and HTTP/HTTPS locator.
  Adds and removals take an explicit UUID command key; retain it after an ambiguous
  outcome. Removal also takes the association's opaque expected version. Read
  reverse Task references through `spec work-items`, following its cursor when
  present. Both endpoints require current access in the same Workspace and Session
  scope. A link records reference metadata and leaves Task completion, Spec
  publication, and external content authorization independent.

- Use `specflow project list` before choosing a Project; never infer a hidden current
  Project. Every newly created Project belongs to exactly one owning Workspace, and
  Workspace Membership is the only source of Project permissions.
- Discover Workspaces with `specflow workspace list` and create one with `specflow
  workspace create --name <name>` when the User asks for a new container. Select one
  Workspace's Projects with `specflow project list --workspace-id <workspaceId>` —
  an explicit, stateless filter combinable with `--status`; an unknown or
  inaccessible Workspace returns an empty list, and a Session approved for a
  Project subset never lists Projects outside that scope.
- Administer Workspace membership and Roles only when the User asks. `specflow
  workspace member list|search|add|set-role|remove` governs who holds access —
  `search` reads the identity directory and `add` provisions the selected User
  by exact issuer+subject identity, including before first login; there is no
  invitation path. `specflow workspace role list|create|update|delete` manages
  statement sets: pass `--statements` as a JSON resource-to-actions object, a
  Role never exceeds the caller's own grants, `Owner` is immutable, and a Role
  still assigned cannot be deleted. Member writes and Role writes take the
  resource's opaque `version` as `--expected-version`; reread deliberately
  after `Resource Changed`.
- Project Creation requires an owning Workspace, a User-chosen immutable ID of 2-10
  letters, and a User-chosen Spec Language whose labels every Spec in the
  Project uses. Ask for whichever is not supplied, then run `specflow project create
  --name <name> --project-id <id> --workspace-id <workspaceId> --spec-language
  <code>` with a supported Spec Language code: `en` or `zh-CN`.
- Archive, Trash, or Restore only when the User's task requires that lifecycle
  change. Pass the opaque version returned by Project discovery or context, and
  reread deliberately after `Resource Changed` or an ambiguous transport outcome.
  A Trashed Project surfaces only to an Admin through `project list --status
  Trashed`, and Restore always lands it on Archived — never directly on Active.
- Use the singular resource commands shown by `specflow --help`. Success is one JSON
  object on stdout. Diagnostics and the final Skill Error are NDJSON on stderr.
- Organize Capability and Spec resources, persist only bounded Source References, and
  edit Spec or Glossary Working Drafts through the logical CLI commands. Do not
  implement a collaboration protocol or connect to the collaboration gateway.
- Use `proposal create-spec` or `proposal create-glossary` only when preview-before-apply
  is useful. Bind it to the exact logical baseline you read, report only available
  Agent revision/model and Source Reference IDs, and use `proposal list`, `apply`, or
  `discard` as independent resource operations. Direct `spec edit` and `glossary edit`
  remain the default and may report the same bounded provenance fields.
- Treat `Resource Changed` from Proposal apply as a protected Human edit: reread the
  Working Draft and Proposal, then require deliberate conflict resolution. Never
  convert it into a blind direct edit or silently recreate the Proposal.
- Apply the current Workspace Role to Finding operations. Never attempt
  to turn a Permission Denied result into broader authority.
- Before any Spec Publish or Rollback, request explicit User confirmation immediately before
  invoking the command. Apply the same rule before any Glossary Publish or Rollback.
  The CLI accepts no confirmation proof: never claim that SpecFlow verified or recorded confirmation.
- Read external sources with the Agent's own authorized tools. You must never request, read, or store external source credentials in SpecFlow, and do not send external source bodies to SpecFlow.
- Perform one resource operation at a time. The Skill is not a task workflow,
  orchestration service, or durable Agent session.

## Authoring Specs

Before deciding Spec boundaries, use current Project context already supplied by the
task. When authoring against SpecFlow, read any missing Capability tree, Published
Glossary, and relevant existing Specs through the CLI. Use that context to choose one
of four outcomes: create a Spec, update or reuse an existing Spec, avoid a duplicate,
or report a conflict that needs resolution.

For each new Spec, write its title and all authored Spec prose (titles,
Goals, Rules, Scenario lines, and explanatory table content) in the User's language.
Use the User's explicit output-language request first, then their established
language preference, and otherwise the language of their own task instructions.
Reference material and this Skill do not determine the Spec's prose language.
Use Published Canonical Terms verbatim even when the surrounding prose uses
another language, and preserve literal values.

Use the Project Spec Language for section headings and line labels;
it governs syntax, not the language of the Spec prose. English Spec prose in a
`zh-CN` Project uses Chinese labels; Chinese Spec prose in an `en`
Project uses English labels. When no Project language is supplied,
use the supported Spec Language matching the Spec prose.
Keep the Project language setting unchanged.

The Published Glossary, obtained together with the Spec Language from the
Project context read, is the only normative vocabulary for Spec authoring. Treat
Glossary Working Draft entries like undefined terms: usable, never normative.
When the Published Glossary defines the concept a requirement refers to, write
the Canonical Term in Title, Goal, Rule, Scenario, and line text even when the
requirement uses a different word for the same meaning. Substituting a
requirement synonym is not a blocking Question.

When the requirement uses a term the Published Glossary defines with a meaning
that differs from its Definition, ask one blocking Question in the compact form
below and draft nothing for the affected goal until the answer arrives. When the
requirement governs, write the Spec per the requirement and report that the
named Glossary Entry now disagrees with it; do not edit the Glossary or create a
Terminology Finding.

A material term the Published Glossary lacks never blocks drafting and never
causes a Glossary Working Draft edit or Glossary Proposal on the Agent's own
initiative. Materiality follows the Terminology Finding definition: the term
must affect behavioral interpretation, so an unfamiliar ordinary word is not
sufficient. When an existing Spec read for context disagrees with the Published
Glossary, report the Spec and the Glossary Entry, and create a Terminology
Finding only when the User asks. Keep each required conflict report
self-contained: retain both source meanings or concrete conflicting values, even
when a Question also quotes them. When reporting an authoring outcome to the
User, list the Canonical Term substitutions made, the undefined material terms
suggested as Glossary candidates, and the existing Specs that disagree with the
Published Glossary.

When a provided Capability owns the goal's business object and changed state, use
that placement. Otherwise create the Spec without `--capability-id`; Unassigned is
not a hidden Capability. Move an existing Spec to Unassigned with `spec update
--capability-id none` and its observed version. Choose one existing Capability when
organizing later; an actor's account does not determine placement.

Use Example Mapping before writing Spec Content:

1. Identify each distinct User goal by the outcome the User wants to complete, not by
   each step, command, or state on the way to that outcome.
2. List the business Rules governing each goal.
3. Give each Rule concrete success, rejection, failure, and boundary Examples.
4. Record unresolved Questions instead of inventing answers.

Map one User goal to one Spec with one Title and Goal. Keep that goal's success, rejection,
failure, and boundary paths in the same Spec. Split independent goals into separate
Specs even when they share a page, API, actor, or implementation; shared
surfaces are not a reason to merge goals. A behavior is an independent goal only when
it has a useful completion outcome apart from the end-to-end journey.

A step that only creates pending work and the later authorized step that accepts,
rejects, or realizes it remain one end-to-end goal when the requirement describes one
business result. A handoff between actors does not by itself create another goal.

A setting and the behavior it enables or disables remain one goal when the setting
has no useful outcome apart from controlling that behavior. Keep enabling, disabling,
and the resulting execution or suppression in the same Spec.

For example, starting checkout, completing payment, and handling a declined payment
remain one purchase Spec. Viewing past orders is a separate goal even on the same
page.

Write canonical Markdown in this fixed order: Title, Goal, optional Rules,
optional Shared Preconditions, Scenarios, and optional Open Questions. Goal is one
paragraph saying who wants what and why. Rules are numbered normative statements;
they have no IDs. Shared Preconditions are a bullet list that holds for every
Scenario. Each Scenario has a heading, an optional explanation, and ordered
Precondition, Action, or Outcome lines. At least one Outcome is required. One
optional pipe table records example values. Open Questions are a numbered list;
they never block Publish and are supplied to Review as context.

Use `#` for the Title, `##` for sections, and `###` for each Scenario heading.
English line labels are `Given`, `When`, and `Then`, followed by `: `.
Chinese sections are `目标 / 规则 / 共同前提 / 情形 / 待确认`; line labels are
`前提 / 操作 / 结果`, followed by `：`, as in `- 操作：顾客确认使用已保存的卡。`.
Sentences use natural language without step-matching rules. Escape structural
prefixes in authored text with a backslash and escape pipes inside table cells.
Use one blank line between blocks and exactly one trailing newline.

For example, an English Spec after Scenario ID assignment reads:

```markdown
# Pay for an order

## Goal

A customer pays for an order to complete checkout.

## Rules

1. The customer must be charged at most once.

## Shared Preconditions

- The order is unpaid.

## Scenarios

### PAY-123-4 Pay with a saved card

- Given: The customer has a saved card.
- When: The customer confirms payment.
- Then: The order is paid.

## Open Questions

1. How long may payment confirmation take?
```

Every Scenario carries a stable Spec-scoped Scenario ID in its heading, such as
`PAY-123-4`, that SpecFlow assigns, never the Agent. When editing a Working Draft,
preserve each existing Scenario ID verbatim: never invent, renumber, reorder, or
hand-assign Scenario IDs, and never put test-case-document numbering into Scenario
titles. Keep the ID when reordering or editing a Scenario inside the same Spec; when
copying a Scenario from another Spec, remove its Scenario ID before saving so
assignment issues fresh IDs. After editing and before Publish, run
`specflow spec assign-scenario-ids --project-id <project-id> --spec-id <spec-id>`
to fill missing IDs and repair invalid, duplicate, or foreign ones while leaving
valid IDs unchanged. Refer to scenarios by their Scenario ID in questions,
findings, and reports. Spec Content has no tags.

Read Markdown with `specflow spec read --project-id <project-id> --spec-id
<spec-id>`: `workingDraftSource` holds the current Draft and
`currentRevision.content` holds Published Content. Start a Draft when needed with
`specflow spec draft --project-id <project-id> --spec-id <spec-id>
--expected-version <version>`. Write it with `specflow spec edit
--project-id <project-id> --spec-id <spec-id> --content <markdown>`; its response
contains `draft.content`. Content that does not parse as canonical Markdown is
rejected as a whole with `Invalid Operation` diagnostics and leaves the Working
Draft unchanged; correct the reported lines and send the full content again.
Project context returns `specLanguage`. A Spec Proposal
uses `proposal create-spec --project-id <project-id> --spec-id <spec-id>
--baseline-content <baseline> --proposed-content <markdown>` and carries
`baselineContent` and `proposedContent`. Keep the baseline exactly as read.

Ask the smallest focused Question before editing only when a missing goal, acting
authority, or business policy prevents a correct Spec boundary, Rule, or observable
outcome without choosing among plausible answers. Otherwise continue directly without
asking or recording a Question. Keep details abstract when the requested behavior is
already clear without them. A stated actor is sufficient unless multiple plausible
authority levels would change the behavior. Stop asking once every goal, required
authority, and outcome-changing policy is known; wording and other reversible
authoring choices do not block drafting.

Phrase each blocking Question as one direct choice using the requirement's own domain
terms and the same language as the requirement. Use the compact form that matches the
missing decision: who may perform the named action for authority; after the named
state, whether the named action is allowed and how rejection is handled for policy;
whether named goal A and named goal B are the same goal or independent goals for a
boundary; or, for a meaning conflict between a requirement and a term the Published
Glossary defines, "the Published Glossary defines the named Canonical Term as the
quoted Definition; this requirement uses it as the quoted meaning; which governs, the
Glossary or the requirement?". That conflict form asks only the one governing choice
and never asks whether the Glossary should change. Replace every generic placeholder
with the exact actor, action, object, goal, or term from the requirement; never
return template wording literally. Do not replace the choice
with a menu of examples or a broader process question. When the current
step asks only for clarification, return the blocking Questions and no Specs or
Spec Content until the answers are supplied.

## Stable failure recovery

Handle the final `error.reason` exactly:

- `Authentication Failed`: stop and ask the User to authenticate again.
- `Project Not Accessible`: stop; do not probe the Project with another identifier.
- `Permission Denied`: stop; the current User Role does not allow the operation.
- `Resource Not Found`: reread the selected Project directory or resource identity.
- `Resource Changed`: reread the resource before deliberately reapplying the User's
  intent with its new opaque version.
- `Invalid Operation`: correct the domain input; never auto-restore, auto-publish, or
  bypass the stated rule. When `error.diagnostics` is present, each entry names the
  `reason`, `message`, and the `line`/`column` of one problem in the Markdown
  content. For `scenario-id-*` reasons on Spec Publish, run `specflow spec
  assign-scenario-ids --project-id <project-id> --spec-id <spec-id>` to repair the
  Working Draft, then retry the Publish. For `scenario-id-*` reasons on Spec
  Rollback, the stored Revision cannot be repaired in place: read its source, save
  it to the Working Draft, run `specflow spec assign-scenario-ids`, and Publish
  instead. Never hand-edit Scenario IDs; assignment is the only repair path.
- `Temporary Failure`: retry only when `retryable` is true, and honor `retryAfter` when
  present.

Disabled Users, revoked or expired Sessions, Role downgrade, Project Archive, and
stale expected versions are authoritative current-state failures. Do not reuse cached
authority or silently broaden the Session's Project scope.
