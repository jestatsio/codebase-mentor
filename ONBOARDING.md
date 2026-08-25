# ONBOARDING.md — codebase-mentor

**Owner:** Eric Hare
**Review cadence:** every release, or after any change to `core/` or `scripts/`
**Last reviewed:** 2026-07

---

## 1 — Codebase Purpose

This repo authors and distributes the *source-grounded codebase mentor*: a protocol that makes AI coding agents answer architecture questions with evidence read from current source. It contains no application code — its "product" is generated instruction artifacts (skills, rules, snippets) plus the installers and CI that deliver and protect them. Consumers are AI agents (Claude Code, Codex, Cursor, Copilot, AGENTS.md readers) and the teams that install into them.

## 2 — Layer Map

Artifacts flow through five layers, canonical first:

| Layer | Responsibility | Key artifact |
|---|---|---|
| Canonical sources | The protocol and authoring kit humans edit | `core/mentor-protocol.md`, `core/mentor-protocol-compact.md`, `template/` |
| Generator | Deterministically derives every distribution artifact | `scripts/sync-adapters.sh` |
| Distribution artifacts | What agents actually load (never hand-edited) | `skills/*/SKILL.md`, `adapters/*` |
| Packaging & install | How artifacts reach machines | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `install.sh`, `mcp/` (the `codebase-mentor-mcp` npm package) |
| Automation | Drift protection and releases | `.github/workflows/validate.yml`, `.github/workflows/release.yml`, `examples/github-actions/` |

## 3 — Execution Lifecycle

**Representative execution:** a maintainer changes the protocol wording.

1. **Edit:** the maintainer edits `core/mentor-protocol.md` (full) and/or `core/mentor-protocol-compact.md` (feeds the small adapters). Generated files are never touched directly.
2. **Regenerate:** `scripts/sync-adapters.sh` rebuilds `skills/codebase-mentor/SKILL.md` (wrapper header + core body via its `core_body()` helper), all three `adapters/` files, the bundled template copies, and the `mcp/bundled/` canonical copies.
3. **Gate:** CI's `validate.yml` runs `sync-adapters.sh --check`, which regenerates into a temp dir and diffs against the committed files — any drift fails the PR.
4. **Deliver:** merged changes reach users through three paths: the Claude Code plugin (`.claude-plugin/` manifests), `install.sh` (its `install_agent()` dispatches per `--agent`; `upsert_block()` replaces marker-fenced blocks idempotently), and `npx skills add`.
5. **Release:** tagging `vX.Y.Z` triggers `release.yml`, which refuses to publish unless the tag matches the `version` in `.claude-plugin/plugin.json`, then publishes the matching `CHANGELOG.md` section.

## 4 — Domain Vocabulary

| Term | Definition |
|---|---|
| **Accuracy contract** | The protocol's core rule: every architecture claim an agent makes must be backed by a symbol or file read in that session. Defined in `core/mentor-protocol.md`. |
| **Symbol anchor** | A class/method name used as a citation instead of a line number, because line numbers rot. |
| **Mode** | One of the four agent behaviors: Mentor, Change Guide, Reconcile, Scan. |
| **Canonical source vs generated file** | Files under `core/` and `template/` are edited by humans; `skills/` bodies and `adapters/` are outputs of `scripts/sync-adapters.sh`. |
| **Adapter** | A thin per-agent wrapper around the compact protocol (AGENTS.md snippet, Cursor `.mdc` rule, Copilot instructions block). |
| **Upsert markers** | The `codebase-mentor:begin`/`codebase-mentor:end` comments that let `install.sh`'s `upsert_block()` replace a block on re-run instead of duplicating it. |

## 5 — Common Change Recipes

### Recipe A — Change the protocol wording

1. Edit `core/mentor-protocol.md`; mirror the change in `core/mentor-protocol-compact.md` if it affects the condensed rules.
2. Run `scripts/sync-adapters.sh`.
3. Commit sources and regenerated files together.

### Recipe B — Add an adapter for a new agent

1. Add a generation block in `scripts/sync-adapters.sh` wrapping `core/mentor-protocol-compact.md` in the agent's format.
2. Append the output path to the `GENERATED` array in the same script.
3. Add a case to `install_agent()` in `install.sh` (idempotent on re-run).
4. Document it in `docs/INSTALL.md`; regenerate and commit.

### Recipe C — Cut a release

1. Move `CHANGELOG.md` Unreleased notes under a new version heading.
2. Bump `version` in `.claude-plugin/plugin.json` to match.
3. Tag `v<version>` and push the tag — `release.yml` publishes the GitHub Release.

### Recipe D — Add an example ONBOARDING.md

1. Create `onboarding/<repo-name>/ONBOARDING.md` following `template/ONBOARDING.md`.
2. Add a row to the table in `onboarding/README.md`.

## 6 — High-Signal Files by Question Type

| Question type | Where to start |
|---|---|
| "What exactly does the protocol tell an agent to do?" | `core/mentor-protocol.md` |
| "Why did this generated file change / fail CI?" | `scripts/sync-adapters.sh` (the `GENERATED` array and `--check` mode) |
| "How does installation work for agent X?" | `install_agent()` in `install.sh`; `docs/INSTALL.md` |
| "How do teams roll this out?" | `docs/TEAM_SETUP.md` |
| "Where do the evaluation claims come from?" | `evaluation/SCORECARD.md` |
| "What ships in the plugin?" | `.claude-plugin/plugin.json`, `skills/` |
| "What does the MCP server expose?" | `mcp/src/index.ts`; its `mcp/bundled/` copies come from `scripts/sync-adapters.sh` |

## 7 — Known Gotchas

### Never edit generated files

**Rule:** anything in `adapters/`, the protocol body of `skills/codebase-mentor/SKILL.md`, the bundled template copies, and the `mcp/bundled/` copies are outputs of `scripts/sync-adapters.sh`.
**Why:** the generator is the single source of truth; hand edits diverge silently.
**What breaks:** CI's `sync-adapters.sh --check` fails the PR; if it slipped through, the next regeneration would erase the edit.

### The compact protocol has a size budget

**Rule:** keep `core/mentor-protocol-compact.md` around 2 KB.
**Why:** it is injected into consumers' `AGENTS.md`, and Codex caps combined AGENTS.md content at 32 KiB per repo — the snippet must stay a good citizen of that budget.
**What breaks:** oversized snippets crowd out the host repo's own agent instructions or get truncated.

### SKILL.md frontmatter must stay minimal

**Rule:** only `name` (lowercase, hyphens) and `description` in `skills/*/SKILL.md` frontmatter.
**Why:** the same file is parsed by Claude Code, Codex, and the `skills` CLI; nonstandard keys risk breaking the strictest parser.
**What breaks:** the skill silently fails to load in some agents, or `npx skills add` rejects the repo.

### Upsert markers are load-bearing

**Rule:** the `codebase-mentor:begin`/`end` comment lines in the agents-md and copilot snippets must survive any rewording.
**Why:** `upsert_block()` in `install.sh` finds and replaces the block by those markers.
**What breaks:** re-running the installer appends a duplicate block instead of replacing, corrupting users' AGENTS.md / copilot-instructions files.

### Release tag and plugin version are coupled

**Rule:** `git tag vX.Y.Z` only after setting `.claude-plugin/plugin.json` `version` to `X.Y.Z` (Recipe C order).
**Why:** `release.yml` hard-fails on mismatch, and Claude Code's plugin auto-update keys off the manifest version.
**What breaks:** the release job exits 1; or, with a stale manifest version, installed plugins never see the update.
