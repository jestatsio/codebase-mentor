# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/). The shipping plugin manifests share
a version. The optional MCP package is versioned independently.

## [1.2.2] - 2026-10-07

### Added
- A privacy policy describing project-file access, generated documents, host-agent processing, and the absence of a JEStats backend or telemetry in the skills-only plugin.
- Privacy links in the OpenAI and Claude metadata, with the policy included in the release ZIP and installed-user README.
- A generated `plugins/codebase-mentor/` folder for directory submissions, containing exactly the release package files, with CI and release checks that reject drift.

### Changed
- Anthropic directory submissions now target the generated package folder, keeping repository development scripts and workflow examples outside the submitted plugin.

## [1.2.1] - 2026-10-07

### Changed
- Transferred the project to `jestatsio/codebase-mentor`, with a new Codebase Mentor logo and subtle JEStats branding.
- Rebuilt the README and documentation around first use, native Claude Code and Codex plugins, dedicated IBM Bob skills, troubleshooting, updates, and removal.
- Updated the portable, Claude, and Codex manifests and marketplace entries to plugin version 1.2.1.
- Added directory-ready metadata for OpenAI and Anthropic, with concise listing copy, JEStats publisher details, and source-first starter prompts.
- Clarified that Codebase Mentor works without an existing ONBOARDING.md and gives users a first source-backed question to try.
- Made the onboard skill self-contained and strengthened evidence, proposal, and existing-document handling.
- Corrected evaluation condition labels and documented normalized excerpts, confounding, and reproducibility limitations.
- Replaced the unpublished MCP npm install path with tested local build instructions. MCP 0.2.0 adds explicit project roots, bounded file reads, read-only tool hints, portable builds, and refreshed dependencies.

### Fixed
- Installer downloads are staged before writes, malformed marker blocks are rejected, explicit revisions are honored, and Bob/Codex skills use their native locations.
- Added installer regression checks, native plugin validation, docs builds on pull requests, and MCP CI coverage.
- Hardened release input handling and validated package contracts before release creation.
- Validate release ZIP contents, bundled references, matching metadata, and skill paths before uploading release assets.

### Added
- A reproducible skills-only plugin ZIP and SHA-256 checksum attached to GitHub Releases, with no optional MCP runtime or repository metadata.
- Publication instructions that separate JEStats marketplace distribution from official OpenAI and Anthropic directory review and publication.
- `mcp/` package: `codebase-mentor-mcp`, a zero-intelligence MCP stdio server exposing the bundled protocol (`codebase_mentor_get_protocol`, `codebase_mentor_get_onboarding`, `codebase_mentor_get_template` tools), the five mentor prompts (`mentor`, `change_guide`, `reconcile`, `scan`, `onboard`), and `codebase-mentor://` resources — the client model does the reasoning.
- `scripts/sync-adapters.sh` now generates byte-identical copies of the canonical sources into `mcp/bundled/`, covered by the `--check` drift gate.
- New example: `onboarding/docling/ONBOARDING.md` for the Docling document conversion library — a mainstream, non-DataStax codebase, authored and verified against live source.

## [1.1.1] - 2026-08-25

### Changed
- Rewrote `README.md` around install paths, the four operating modes, and the three-arm evaluation; moved the origin-story framing to the docs site's evaluation page.
- Removed the duplicate `data-api/ONBOARDING.md`; `onboarding/stargate-jsonapi/ONBOARDING.md` (byte-identical) is now the single home for the Stargate Data API reference implementation.
- Removed the planted stale claims from the AstraPy and Langflow example ONBOARDING.md files (corrected against live source); the deliberate inaccuracy now lives only in the Stargate Data API example used by the demo script.
- Moved the historical Bob Challenge build plan from `plan.md` to `docs/plan.md` with a provenance note.
- Rewrote `demo/SCRIPT.md` agent-neutrally ("the agent" instead of Bob); Bob-specific framing now lives only in the evaluation/origin materials.

## [1.1.0] - 2026-07-02

### Added
- Agent-neutral protocol core (`core/mentor-protocol.md` + compact variant) with generated adapters for AGENTS.md, Cursor, and GitHub Copilot; `scripts/sync-adapters.sh` keeps everything in sync (CI-enforced).
- `install.sh --agent claude|codex|cursor|copilot|agents-md|all` cross-agent installs; `npx skills add jestatsio/codebase-mentor` documented as the universal path.
- Per-agent install guide (`docs/INSTALL.md`) and documentation site (MkDocs Material, deployed to GitHub Pages) with a scripted terminal demo.
- MIT license, contributing guide, code of conduct, security policy, issue/PR templates.
- Repo CI (plugin validation, sync drift gate, shellcheck, link check) and tag-driven release workflow.
- Dogfooding: this repo's own `ONBOARDING.md` plus a weekly freshness-scan workflow (skips until an `ANTHROPIC_API_KEY` secret is set).
- Launch kit: ready-to-paste directory listings (`launch/LISTINGS.md`) and announcement drafts (`launch/LAUNCH_POST.md`).

## [1.0.0] - 2026-07-02

### Added
- Claude Code plugin packaging (`.claude-plugin/plugin.json` + `marketplace.json`) with two-command install.
- `codebase-mentor` skill: Mentor / Change Guide / Reconcile / Scan modes under a source-evidence accuracy contract.
- `/codebase-mentor:onboard` skill: generates an ONBOARDING.md draft from live source, interviews for gotchas, self-verifies with a freshness scan.
- Bundled ONBOARDING.md template + authoring guide.
- Example scheduled GitHub Action for ONBOARDING.md freshness scanning.
- Team rollout guide (`docs/TEAM_SETUP.md`) and `install.sh` fallback installer.

[1.2.2]: https://github.com/jestatsio/codebase-mentor/releases/tag/v1.2.2
[1.2.1]: https://github.com/jestatsio/codebase-mentor/releases/tag/v1.2.1
[1.1.1]: https://github.com/jestatsio/codebase-mentor/releases/tag/v1.1.1
[1.1.0]: https://github.com/jestatsio/codebase-mentor/releases/tag/v1.1.0
[1.0.0]: https://github.com/jestatsio/codebase-mentor/releases/tag/v1.0.0
