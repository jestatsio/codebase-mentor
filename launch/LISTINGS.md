# Distribution checklist

The repository ships its own Claude Code and Codex marketplaces. Third-party directory acceptance is separate from plugin installation. No external listing or approval is implied by these files.

## Reusable listing copy

- **Name:** Codebase Mentor
- **Publisher:** JEStats
- **Repository:** https://github.com/jestatsio/codebase-mentor
- **Documentation:** https://jestatsio.github.io/codebase-mentor/
- **Description:** Architecture answers, change plans, and onboarding docs grounded in the source your coding agent reads. Claude Code and Codex plugins, IBM Bob skills, and open agent adapters.
- **License:** MIT
- **Category:** Developer tools / documentation / onboarding
- **Logo:** `site/docs/assets/logo.png` (see `docs/BRAND.md`)

## Before announcing a release

1. Verify native plugin installs against the public default branch.
2. Verify the Bob project installer from a clean directory.
3. Verify the documentation site and repository homepage after ownership or URL changes.
4. Check manifest versions, release notes, and generated artifacts.
5. If publishing the optional MCP package, separately verify npm ownership, package contents, and an actual registry install. It is currently unpublished.
6. Record external directory submissions and their outcomes separately. Check each directory's current submission requirements before submitting.

Skills CLI discovery, GitHub Releases, documentation deployment, marketplace acceptance, and npm publication are independent results.
