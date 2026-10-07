# Distribution and directory submissions

Codebase Mentor is published by JEStats. Its GitHub marketplace catalogs, release
archive, documentation site, and official directory listings have separate
publication steps. These instructions do not establish that a submission has
been accepted or that a directory listing is live.

## Listing copy

- **Name:** Codebase Mentor
- **Publisher:** JEStats
- **Version:** 1.2.2
- **Subtitle:** Understand unfamiliar code
- **Repository:** https://github.com/jestatsio/codebase-mentor
- **Documentation:** https://jestatsio.github.io/codebase-mentor/
- **Support:** https://github.com/jestatsio/codebase-mentor/issues
- **Privacy:** https://github.com/jestatsio/codebase-mentor/blob/main/PRIVACY.md
- **Description:** Trace how code works, find where a change belongs, draft an onboarding map, and check documentation against current source. The codebase-mentor and onboard skills ask your coding agent to read relevant files, cite its evidence, and flag what it cannot verify. Start with or without ONBOARDING.md. Requires access to the source you want to understand. Review generated answers and drafts before acting.
- **License:** MIT
- **Category:** Developer Tools
- **Logo:** [logo.png](../site/docs/assets/logo.png)

## Build the release

From the repository root:

```bash
bash scripts/validate-package.sh
bash scripts/test-install.sh
bash scripts/package-plugin.sh
bash scripts/sync-plugin-directory.sh
```

The package script writes `dist/codebase-mentor-1.2.2.zip` and its
`.zip.sha256` checksum. It includes the portable, Codex, and Claude manifests,
both skills with their references, the logo, a short installed-user README, and
the license, and the privacy policy. It excludes the optional MCP server and development files.
`scripts/validate-package.sh dist/codebase-mentor-1.2.2.zip` verifies the exact
inventory, source bytes, manifest asset paths, skill discovery, and checksum.

`plugins/codebase-mentor/` is the generated GitHub submission folder. Its 14 files
match the release ZIP byte for byte. Edit the root source files, run
`scripts/sync-plugin-directory.sh`, and commit the regenerated folder alongside
the changes. CI and the release workflow run `scripts/sync-plugin-directory.sh
--check` to reject drift. The check creates a temporary ZIP and never changes the
generated folder or published release artifacts.

The Release workflow checks the requested version, validates the distribution,
builds the ZIP, validates the extracted Claude plugin, and attaches the ZIP and
checksum to the GitHub Release. Publish the release at the tested commit.

## Repository marketplaces

Codebase Mentor’s repository contains its own `codebase-mentor` catalogs. Users
add `jestatsio/codebase-mentor` and install
`codebase-mentor@codebase-mentor` in either agent.

- Codex: `.agents/plugins/marketplace.json` points to the local plugin root (`./`), with `AVAILABLE` installation, `ON_USE` authentication, and the Developer Tools category.
- Claude: `.claude-plugin/marketplace.json` points to the local plugin root (`./`). Keep its version aligned with the plugin manifests.

Publish the tested repository changes, then verify a fresh install from the
public repository before describing the catalog entry as available. These
catalogs are independent of official directory review.

## OpenAI directory

Use the [OpenAI Plugins dashboard](https://platform.openai.com/plugins) and the
[official submission guide](https://developers.openai.com/plugins/deploy/submission).

1. Select the owning organization and project and the verified JEStats developer identity.
2. Upload the tested release ZIP. Root `plugin.json` carries the preferred portable metadata, with a matching Codex compatibility manifest.
3. Resolve required metadata and skill scan findings. The subtitle and display name must each stay within 30 characters.
4. Submit the selected version for review and complete the required attestations.
5. After approval, select Publish plugin and verify the public listing.

This release contains only skills. It does not need MCP review cases, reviewer
credentials, or an MCP demo recording. An MCP connection cannot currently be
added to an existing skills-only listing. The optional local MCP package is a
separate distribution and is not included in this submission.

## Anthropic directory

Use the [Claude developer portal](https://claude.ai/directory/manage) and the
[official submission guide](https://claude.com/docs/plugins/submit). Run the
[directory checklist](https://claude.com/docs/plugins/pre-submission-checklist)
against the exact commit you submit.

1. Select Plugin bundle. Use `jestatsio/codebase-mentor`, plugin path `plugins/codebase-mentor`, and tracked branch `main`. Submit the generated package folder so the scan covers the same skills-only files as the release ZIP.
2. Validate, then inspect the listing populated from the generated folder's `.claude-plugin/plugin.json` and README. Push fixes and revalidate if the source changes.
3. Read the bundled privacy policy, complete data-handling questions, and verify the submission contact email. The plugin has no server or telemetry. Its skills ask the host agent to read repository files and, when requested, write onboarding documentation. The host agent's own processing and retention are governed by that host. Answer personal-data and age questions for the actual intended use.
4. Review the compliance acknowledgements and update settings, then submit. A paid Claude plan and a connected GitHub account with repository push access are required.
5. Follow the scan and reviewer outcome. Request publication when the version passes and verify the live listing separately.

Anthropic's directory distributes to Claude and Claude Code through account
sync. It is separate from the `claude-plugins-official` GitHub marketplace, whose
listing path is an Anthropic partner contact according to the
[Claude Code publishing guide](https://code.claude.com/docs/en/plugins/publish).

## Record publication evidence

Record the tested commit, release tag, ZIP checksum, marketplace commit, fresh
install results, and documentation URL. For each directory, record its submission
identifier, submitted version, review status, and public listing URL once live.
Do not describe a successful local validator or an uploaded draft as acceptance.
