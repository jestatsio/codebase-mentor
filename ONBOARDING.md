# ONBOARDING.md — Codebase Mentor

**Owner:** Eric Hare (JEStats)
**Review cadence:** every release or change to the protocol, packaging, or installer
**Last reviewed:** 2026-10
**Verification scope:** source inspection of protocol, setup, generation, installer, and validation paths on `d85ba66c30ee` plus working changes. Fresh-session client behavior remains unverified.

## 1 — Codebase Purpose

Codebase Mentor helps agents use repository design context during ordinary work, explain architecture, and check documentation against current source. It ships skills, native project setup, portable adapters, and an optional TypeScript MCP server. The protocol guides the client model; it does not mechanically guarantee answer quality.

## 2 — Layer Map

| Responsibility | Source anchor |
|---|---|
| Evidence rules | `core/mentor-protocol.md` and `core/mentor-protocol-compact.md` |
| Authoring and native setup | Handwritten `skills/onboard/SKILL.md`, `SETUP.md`, and `main()` in `setup_repo.py` beside it; `template/` |
| Artifact generation | `core_body()` and `GENERATED` in `scripts/sync-adapters.sh` |
| Plugin distribution | Root manifests; allowlist in `scripts/package-plugin.sh`; `scripts/sync-plugin-directory.sh` |
| Fallback installation | `stage_agent()`, `install_skills()`, and `upsert_block()` in `install.sh` |
| Optional MCP server | `mcp/src/index.ts`, `mcp/package.json` |
| Validation and delivery | `.github/workflows/validate.yml`, `docs.yml`, and `release.yml` |

**Focused references:** use [native setup](skills/onboard/SETUP.md) for instruction discovery and preservation, [authoring guidance](template/AUTHORING_GUIDE.md) for context quality, and [installation](docs/INSTALL.md) for distribution choices. No dedicated MCP subsystem guide is included; start with [its README](mcp/README.md) and source.

## 3 — Execution Lifecycle

**Representative execution:** a maintainer changes the evidence rules.

1. Edit `core/mentor-protocol.md` and mirror applicable changes in the compact variant.
2. Run `scripts/sync-adapters.sh`. Its `core_body()` builds the mentor skill. Other generation blocks update adapters and bundles beside both skills and under `mcp/bundled/`.
3. Run `scripts/sync-adapters.sh --check`, then `bash scripts/sync-plugin-directory.sh` to rebuild `plugins/codebase-mentor/` from the release archive.
4. Run relevant validation and installer tests. `validate.yml` checks both generated surfaces.
5. Installation supplies skills. A separate setup request drafts context and configures selected project instructions. Fresh-session observation establishes use. Publishing through `release.yml` and optional MCP publication remain separate actions.

## 4 — Domain Vocabulary

| Term | Meaning |
|---|---|
| **Accuracy contract** | Claims need evidence read this session, defined in `core/mentor-protocol.md`. |
| **Anchor** | A symbol plus file path, or a file heading/configuration key that locates evidence. |
| **Generated artifact** | An output in `GENERATED` in `scripts/sync-adapters.sh`, or the package-derived `plugins/codebase-mentor/` folder. |
| **Setup entry** | Small native instruction pointer managed by `setup_repo.py`, separate from legacy adapter markers. |
| **Configured / observed** | Instruction files exist / a fresh task session actually used the relevant context. |

## 5 — Common Change Recipes

### Change the protocol or authoring kit

1. Edit `core/` or `template/`; edit onboard's handwritten workflow and helper in `skills/onboard/`.
2. Run `scripts/sync-adapters.sh` and `bash scripts/sync-plugin-directory.sh`.
3. Run `bash scripts/validate-package.sh` and `bash scripts/sync-plugin-directory.sh --check`; include generated copies with source changes.

### Add an adapter

1. Add its generation block and output path to `GENERATED` in `scripts/sync-adapters.sh`.
2. Update `stage_agent()` and the final dispatch in `install.sh`, preserving user content. Exercise `bash scripts/test-install.sh`.
3. For native setup behavior, update `skills/onboard/setup_repo.py` and run `python3 -m unittest discover -s tests -p 'test_*.py' -v`.
4. Update `docs/INSTALL.md` and its site counterpart. Docs require `docs/requirements.txt`; run `mkdocs build --strict`.

### Prepare a release

1. Add the version's notes to `CHANGELOG.md`.
2. Synchronize plugin versions in `.claude-plugin/plugin.json`, the entry in `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and root `plugin.json`.
3. Regenerate both distribution surfaces and run validation plus documented client acceptance before a release. Tagging or dispatching `release.yml` publishes; obtain authorization first.
4. MCP versions in `mcp/package.json` and its lockfile are independent. Test and verify its publication separately.

## 6 — High-Signal Files

| Question | Start here |
|---|---|
| What rules does the agent receive? | `core/mentor-protocol.md` |
| Why did drift validation fail? | `GENERATED` in `scripts/sync-adapters.sh`; `scripts/sync-plugin-directory.sh` |
| Can onboard work alone? | `skills/onboard/SKILL.md` and its adjacent bundles |
| How does agent installation work? | `stage_agent()` and `install_skills()` in `install.sh`, `docs/INSTALL.md` |
| What does MCP expose? | `mcp/src/index.ts`, `mcp/README.md` |
| What supports effectiveness claims? | Provenance and limitations in `evaluation/SCORECARD.md` |

## 7 — Known Gotchas

- **Edit canonical sources:** never edit `plugins/codebase-mentor/` directly. Both generation scripts overwrite outputs; some root skill files are handwritten.
- **Keep bundles together:** onboard needs adjacent templates, protocol, `SETUP.md`, and optional `setup_repo.py`. Keep installer and package allowlists synchronized.
- **Keep adapters compact:** instruction files share the host agent's context budget. Avoid duplicating the full protocol in every project instruction file.
- **Preserve markers:** legacy `codebase-mentor:begin/end` and native `codebase-mentor:setup:begin/end` have different owners. Removal preserves context documents.
- **Separate releases from availability:** matching plugin versions and a GitHub Release do not establish npm publication, client installation success, or a live docs deployment. Verify each delivery path used.
