# ONBOARDING.md — Codebase Mentor

**Owner:** Eric Hare (JEStats)
**Review cadence:** every release or change to the protocol, packaging, or installer
**Last reviewed:** 2026-10

## 1 — Codebase Purpose

Codebase Mentor gives coding agents instructions for explaining architecture, planning changes, and checking an onboarding map against current source. It ships skills and agent-specific adapters, plus an optional TypeScript MCP server. Claude Code and Codex have plugin manifests. IBM Bob and other skill-capable agents can use the skills directly. The protocol guides the client model, so its instructions are not a mechanical guarantee of answer quality.

## 2 — Layer Map

| Responsibility | Source anchor |
|---|---|
| Evidence rules | `core/mentor-protocol.md` and `core/mentor-protocol-compact.md` |
| Authoring workflow | `skills/onboard/SKILL.md` (handwritten), `template/` |
| Artifact generation | `core_body()` and `GENERATED` in `scripts/sync-adapters.sh` |
| Plugin distribution | `.claude-plugin/`, `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `plugin.json` |
| Fallback installation | `install_agent()` and `upsert_block()` in `install.sh` |
| Optional MCP server | `mcp/src/index.ts`, `mcp/package.json` |
| Validation and delivery | `.github/workflows/validate.yml`, `docs.yml`, and `release.yml` |

## 3 — Execution Lifecycle

**Representative execution:** a maintainer changes the evidence rules.

1. Edit `core/mentor-protocol.md` and mirror applicable changes in the compact variant.
2. Run `scripts/sync-adapters.sh`. Its `core_body()` builds the mentor skill. Other generation blocks update adapters and bundles beside both skills and under `mcp/bundled/`.
3. Run `scripts/sync-adapters.sh --check`. The `GENERATED` array identifies files compared against freshly generated output.
4. Run the relevant installer, manifest, and MCP checks. The `validate` workflow runs repository checks on pull requests.
5. Publish a reviewed plugin release through `release.yml`. Installing or updating a plugin supplies the skills to the agent. MCP package publication is a separate delivery step.

## 4 — Domain Vocabulary

| Term | Meaning |
|---|---|
| **Accuracy contract** | Claims need evidence read this session, defined in `core/mentor-protocol.md`. |
| **Anchor** | A symbol plus file path, or a file heading/configuration key that locates evidence. |
| **Mode** | Mentor, Change Guide, Reconcile, or Scan. Onboard is a separate authoring skill. |
| **Generated artifact** | An output listed in `GENERATED` in `scripts/sync-adapters.sh`. The handwritten onboard skill is not one. |
| **Upsert markers** | The `codebase-mentor:begin` and `codebase-mentor:end` comments used by `upsert_block()` to replace an installed snippet. |

## 5 — Common Change Recipes

### Change the protocol or authoring kit

1. Edit `core/` or `template/`. Edit the onboard workflow directly in `skills/onboard/SKILL.md`.
2. Regenerate with `scripts/sync-adapters.sh`.
3. Check drift and commit source changes with their generated copies.

### Add an adapter

1. Add its generation block and output path to `GENERATED` in `scripts/sync-adapters.sh`.
2. Add installation behavior in `install_agent()` and preserve existing user content.
3. Document installation in `docs/INSTALL.md` and exercise initial installation and reinstallation.

### Prepare a release

1. Add the version's notes to `CHANGELOG.md`.
2. Synchronize plugin versions in `.claude-plugin/plugin.json`, the entry in `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and root `plugin.json`.
3. Regenerate, run validation, then tag the reviewed commit as `v<plugin-version>` for `release.yml`.
4. For a separate MCP release, synchronize `mcp/package.json` and `mcp/package-lock.json`, test its packaged artifact, and verify registry publication independently.

## 6 — High-Signal Files

| Question | Start here |
|---|---|
| What rules does the agent receive? | `core/mentor-protocol.md` |
| Why did drift validation fail? | `GENERATED` in `scripts/sync-adapters.sh` |
| Can onboard work alone? | `skills/onboard/SKILL.md` and its adjacent bundles |
| How does agent installation work? | `install_agent()` in `install.sh`, `docs/INSTALL.md` |
| What does MCP expose? | `mcp/src/index.ts`, `mcp/README.md` |
| What supports effectiveness claims? | Provenance and limitations in `evaluation/SCORECARD.md` |

## 7 — Known Gotchas

- **Edit canonical sources:** generated copies are overwritten on regeneration. Use `GENERATED` to identify them, rather than assuming every file under `skills/` is generated.
- **Keep bundles together:** standalone onboard needs its template, authoring guide, and protocol beside `SKILL.md`. Missing companions break the drafting instructions.
- **Keep adapters compact:** instruction files share the host agent's context budget. Avoid duplicating the full protocol in every project instruction file.
- **Preserve upsert markers:** changing marker names prevents the installer from recognizing an existing snippet.
- **Separate releases from availability:** matching plugin versions and a GitHub Release do not establish npm publication, client installation success, or a live docs deployment. Verify each delivery path used.
