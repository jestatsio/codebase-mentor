# Contributing to Codebase Mentor

Thanks for helping make onboarding docs that AI agents can actually trust. Contributions of every size are welcome — typo fixes, new agent adapters, example ONBOARDING.md files, protocol improvements.

## Ground rules

- **Edit canonical sources, never generated files.** The protocol lives in `core/mentor-protocol.md` (full) and `core/mentor-protocol-compact.md` (condensed). The authoring kit lives in `template/`. The onboard workflow is handwritten in `skills/onboard/SKILL.md`. The `GENERATED` array in `scripts/sync-adapters.sh` lists generated skills, adapters, and bundles. After editing a source, run:

  ```bash
  scripts/sync-adapters.sh
  ```

  CI fails the PR if generated files are out of date (`scripts/sync-adapters.sh --check`).

- **The accuracy contract is the product.** Changes to the protocol must preserve its core property: every architecture claim is backed by a source read in the current session, and missing evidence is declared, never papered over. PRs that weaken this will be declined.

- **Keep the compact protocol compact.** `core/mentor-protocol-compact.md` feeds project instruction snippets. Aim for about 2 KB so the host project's own instructions retain room in the agent's context budget.

- **Keep each skill self-contained.** Onboard has adjacent copies of the template, authoring guide, and full protocol. Update their canonical sources and regenerate, so installing only that skill remains useful.

## Adding an adapter for a new agent

1. Add a generation block to `scripts/sync-adapters.sh` that wraps one of the two core docs in the agent's expected format (frontmatter, markers, file naming).
2. Add the output path to the `GENERATED` array.
3. Add an install case to `install.sh` (`--agent <name>`), idempotent on re-run.
4. Add an install section to `docs/INSTALL.md`, citing the agent's official docs for the format.
5. Run `scripts/sync-adapters.sh` and commit sources + generated output together.

## Contributing an example ONBOARDING.md

Real-world examples live in `onboarding/<repo-name>/ONBOARDING.md`. Follow the seven-section structure from `template/ONBOARDING.md`, cite symbols with file paths or configuration/document anchors, and verify claims against the target checkout. Include the source repository and revision so readers understand the example's scope. Attribute human rationale and mark unresolved context as TODOs. Add a row to `onboarding/README.md`.

## Development checks

For protocol and packaging changes, start with:

```bash
scripts/sync-adapters.sh --check   # generated files up to date
bash scripts/validate-package.sh  # plugin identities and required bundles
bash scripts/test-install.sh      # isolated installation smoke checks
shellcheck install.sh scripts/*.sh # shell hygiene
claude plugin validate --strict . # Claude marketplace validation
```

For MCP changes, run `npm ci` and `npm test` in `mcp/` and verify the packed package. For site changes, run `mkdocs build --strict`. The current validation workflow is the reference for required CI checks.

## Releases

The plugin and optional MCP package have separate versions and delivery paths.

1. Add release notes under the plugin version in `CHANGELOG.md`.
2. Keep `.claude-plugin/plugin.json`, the plugin entry in `.claude-plugin/marketplace.json`, `.codex-plugin/plugin.json`, and root `plugin.json` at that same version. The Codex marketplace catalog points to the plugin and has no separate version field.
3. Regenerate artifacts and pass the release checks before tagging the reviewed commit as `v<plugin-version>`. `.github/workflows/release.yml` creates the GitHub Release.
4. If releasing the MCP package, update `mcp/package.json` and its lockfile together, test the package contents, and publish separately. Confirm the exact version in the npm registry before describing it as available.

After ownership or URL changes, check the repository homepage, badges, installation links, and live documentation site. A repository redirect does not establish a working Pages site.

## Pull requests

- Small, focused PRs review faster.
- Describe what changed and why; link related issues.
- CI must be green (validation workflow runs on every PR).

## Questions

Open a GitHub issue — there's a template for bugs, adapter requests, and example submissions.
