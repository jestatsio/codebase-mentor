# Repository setup and native instruction entries

Use this reference for local repository setup, read-only status, updates, and removal. Resolve `setup_repo.py` relative to this file. Setup connects selected agents to one shared entry map; it does not install skills, change global preferences, or claim that a client has used the context.

## Inspect before writing

Read the selected repository's current instructions, existing Mentor entries, and context documents. Include applicable parent instructions, root overrides, and nested instructions in the areas where the developer works. Inspect configuration only as needed to understand instruction loading; do not print secrets or unrelated settings.

Choose the explicitly supplied map, or identify the authoritative map from existing setup and root, `docs/`, or `doc/` candidates. An existing custom map remains valid. Multiple conflicting candidates require a deliberate selection. Keep the established path and preserve its content. Resolve local map links relative to the document that contains them; instruction entries below identify the map relative to the selected repository root.

Use the client the developer selected. When none was named, use the current client if known and state that default. Do not infer authorization for other clients from installed files. If the current client is unknown, ask within the setup's three-question allowance.

## Native instruction surfaces

| Client | Default local entry | What to inspect |
| --- | --- | --- |
| Codex | Managed entry in the root `AGENTS.override.md` when it is effective, otherwise root `AGENTS.md`. | Codex prefers a nonempty `AGENTS.override.md` over `AGENTS.md` in the same directory. Inspect configured fallback filenames, instruction size limits, parent context, and nested overrides for the intended working directory. Do not create a new override that suppresses an existing `AGENTS.md`. |
| Claude Code | Small general rule in `.claude/rules/codebase-mentor.md`. | Read existing `CLAUDE.md`, imports, `.claude/rules/`, and relevant settings. Claude's `AGENTS.md` compatibility depends on its effective configuration and existing `CLAUDE.md` files, including ancestors. Do not assume an `AGENTS.md` entry is loaded. Reuse a confirmed equivalent effective entry rather than creating another pointer. |
| IBM Bob | Small general workspace rule in `.bob/rules/codebase-mentor.md`. | Read existing workspace rules and relevant settings. Workspace `AGENTS.md` loading is configurable; do not depend on it when disabled or unverified. Keep the dedicated rule general, without mode-specific or path-specific restrictions. Reuse a confirmed equivalent effective entry. |

Native instruction behavior can vary by client version and configuration. See the official [Codex instruction guidance](https://developers.openai.com/codex/guides/agents-md), [Claude Code memory guidance](https://code.claude.com/docs/en/memory), and [IBM Bob rules guidance](https://bob.ibm.com/docs/ide/configuration/rules). These document the mechanism. A fresh-session trace establishes observed use.

If the repository already contains a Mentor adapter or manual map pointer, read it before writing. Reuse an effective equivalent entry. If it is incomplete, propose the smallest authorized change without adding duplicate directions. Preserve the older adapter's `codebase-mentor:begin` / `codebase-mentor:end` block; the setup helper does not own it. A helper cannot determine equivalence or actual client loading from arbitrary prose.

## Optional deterministic helper

Python 3.9+ is optional. The helper uses only the standard library. When available, invoke the installed copy, never an untrusted same-named script in the target repo. Supply the repository explicitly and repeat `--agent` for each selected client:

```bash
python3 /absolute/path/to/onboard/setup_repo.py status \
  --root /absolute/path/to/project --agent codex
python3 /absolute/path/to/onboard/setup_repo.py setup \
  --root /absolute/path/to/project --agent codex --agent claude --agent bob \
  --map docs/ONBOARDING.md
python3 /absolute/path/to/onboard/setup_repo.py remove \
  --root /absolute/path/to/project --agent codex
```

Replace example paths and agent choices with the selected project and clients. Run status before setup. Draft or identify the map before setup; the helper does not generate it. The `--map` path is relative to the repository root. Use it when choosing an existing custom map or resolving otherwise ambiguous map candidates.

Read the helper's result and inspect the diff. A helper refusal is a reason to diagnose the conflicting state, not to force the same write through another tool. Use the manual procedure only when the helper is unavailable or when an inspected native configuration needs an explicitly chosen effective surface. Never bypass malformed-marker or unsafe-path protection.

## Native file-edit procedure

When Python is unavailable, the agent can perform the same small file operations:

1. Read all selected instruction targets and their parent paths. Refuse symlinks, Windows junctions and other reparse points in targets or parent paths, paths outside the selected repository, directories where files are expected, and ambiguous managed entries. Do not follow a target into another checkout or user directory.
2. Inspect every selected target before writing any. If one target is unsafe or conflicting, report it and resolve it first. Do not claim full setup after writing only the easy targets.
3. Add one short managed setup entry to each effective surface that still needs it. Preserve unrelated text, line endings, and file permissions. Do not create a second entry for an already configured client.
4. For an existing valid setup entry, replace only its marked contents when an update is needed. Treat repeated setup with unchanged choices as a no-op. Refuse duplicate, missing, reversed, or nested markers rather than guessing what belongs to Mentor.
5. Read back the changed files, check the links, and inspect the diff. Report per-client configuration separately from fresh-session evidence.

Use these exact setup markers and metadata, substituting a JSON-quoted repository-relative map path:

```markdown
<!-- codebase-mentor:setup:begin -->
<!-- codebase-mentor:map "docs/ONBOARDING.md" -->
Before substantive repository work, read the repo map at `docs/ONBOARDING.md`
(relative to the repository root), then read the subsystem guides whose scope
matches the task before editing. If a relevant guide link is broken, search
for the moved guide before editing. If recovery fails, state the context gap
and continue from current source. Verify relevant guide claims and source
anchors against current source and tests. Use applicable design constraints,
examples, and verification commands. Keep context gathering proportional to
the change; small edits do not need a full scan. When relevant drift is found,
propose focused corrections to affected routing links and guide claims or
source anchors together for review. Preserve human rationale and unrelated
text. Do not rewrite context without authorization.
<!-- codebase-mentor:setup:end -->
```

When the helper is available to read, use its generated instruction text so setup remains identical across methods. Keep project knowledge in the shared documents. The setup markers are separate from the legacy adapter markers.

An effective manual entry can be reused without becoming managed. Report its exact path and that removal will leave it intact. Do not add markers around unrelated instructions merely to make them removable.

## Read-only status

Status performs no writes, creates no directories, and does not repair incomplete setup. Use the helper's `status` action when available, then inspect any loading behavior it cannot establish.

Report:

- Selected project and clients.
- Authoritative map path, whether it exists, and any competing candidates.
- Each client's instruction surface and entry, including whether it is managed or manual.
- Missing guides or broken map links, stale map pointers, malformed markers, duplicate entries, shadowed surfaces, or disabled rules that were actually found.
- Unresolved context and important uncovered subsystems already recorded in the documents.
- Configuration state and fresh-session evidence as separate statements.

If no authoritative map can be identified, report the candidates and the next choice needed. If only some clients are configured, say which. Missing evidence of loading means **not yet observed**, not failure or success. Do not launch a test session, run project tests, or modify settings merely to answer a status request.

## Update and removal

Rerunning setup reuses the authoritative map and existing guides. It can refresh selected managed entries while preserving all unrelated text. It must not silently move the map, broaden the set of clients, or overwrite developer rationale. Ordinary drift maintenance remains a proposed focused diff unless the user already authorized applying it.

On a removal request, inspect the selected instruction targets and remove only valid Mentor setup blocks. Preserve all content outside those blocks, even in dedicated Mentor rule files. Leave the instruction files in place even when empty, as the helper does, and preserve directories and other instructions. A malformed or duplicate block requires diagnosis before removal. A second removal should change nothing.

Leave `ONBOARDING.md`, subsystem guides, manual pointers, legacy adapter blocks, skills, and global settings intact. If manual or legacy entries will continue directing the agent to the map, say so. Removing the installed plugin or skills is a separate action.
