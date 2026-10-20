# v1.3 verification results

The v1.3.0 implementation and local package are ready on `fix/repo-context-1.3`.
Local verification passed, and all **15 client scenarios have passing evidence**.
The [frozen scenarios](README.md) define the expected behavior. Nothing has been
published.

| Client | Design constraint | Stale guide | Small edit | Existing setup | Subsystem choice |
| --- | --- | --- | --- | --- | --- |
| Codex | Pass | Pass | Pass | Pass | Pass |
| Claude Code | Pass | Pass | Pass | Pass | Pass |
| IBM Bob | Pass | Pass after fix | Pass | Pass | Pass |

The first Bob stale-guide run failed: it implemented the code correctly but
skipped the missing guide and proposed no documentation corrections. The fix
makes focused guide recovery explicit before falling back to source. Stale-guide
and small-edit scenarios were then repeated successfully in **all three clients**.
The other three scenarios carry forward their initial passing results; they were
not rerun after this focused instruction change. Original failures and interrupted
attempts remain in the client records.

## Candidate

- Source base: `d85ba66c30ee4af98486ec6fbd0e313681942884`.
- Initial candidate `git diff --binary` SHA-256:
  `86779d8175dab5d64d4da62dfc2ab787efb5e0f1e8cabf7142de3cef522705a0`.
- Corrected candidate `git diff --binary` SHA-256:
  `a8cb2dcd9c05517c9b0a3c772ab3b026e8a96a196999c7fe9fc769a91d7c6645`.
  Both cover tracked changes only; client records separately hash installed new
  files and fixtures.
- Validated local archive: `dist/codebase-mentor-1.3.0.zip`.
- Archive SHA-256:
  `b7bbd8634952fc740d78d542a8b1f2d45497f73cca73dd25fbc80140bac7937f`.
- Version metadata was advanced to 1.3.0 after acceptance. All **11 shipped skill
  files** were compared by SHA-256 against the corrected candidate's installed
  inventory and match byte for byte. Final metadata and generated package checks
  passed. Superseded local 1.2.2 development ZIPs were removed.
- No release, registry publication, or CI run is claimed.

## Local verification observed

All checks below ran on macOS on October 20, 2026.

| Command | Observed result |
| --- | --- |
| `python3 -B -m unittest discover -s tests -p 'test_*.py'` | 34 tests passed on Python 3.15.0. Covers all three clients, preservation, repeat setup/removal, custom maps, conflicts, partial failures, unsafe paths, and simulated Windows path/reparse behavior. |
| `UV_PYTHON_INSTALL_DIR=/private/tmp/mentor-python UV_CACHE_DIR=/private/tmp/mentor-uv-cache uv run --no-project --python 3.9 python -B -m unittest discover -s tests -p 'test_*.py'` | Same 34 tests passed on the minimum supported Python series. |
| `bash scripts/test-install.sh` | All seven integration groups passed, including all six installer targets, paths with spaces, repeat installs, permissions, invalid inputs, marker conflicts, symlinks, and download failures. |
| `bash scripts/package-plugin.sh` | Manifest and generated-file validation passed; ZIP inventory, source bytes, assets, and checksum passed. |
| `bash scripts/sync-plugin-directory.sh --check` | All 18 directory-package files match. |
| `shellcheck install.sh scripts/*.sh` | Passed. |
| `git diff --check` | Passed. |
| `claude plugin validate --strict .` and `claude plugin validate --strict .claude-plugin/plugin.json` | Both passed. |
| `claude plugin validate --strict /private/tmp/mentor-v130-package-uoxpu80z` | Unpacked 1.3.0 ZIP passed. Validator suggested adding a marketplace install example to its README; this was advisory. |
| `uv --cache-dir /tmp/codebase-mentor-uv-cache run --no-project --with-requirements docs/requirements.txt mkdocs build --strict` | Documentation built successfully. |
| `mypy --cache-dir /tmp/codebase-mentor-review-mypy --follow-imports=skip skills/onboard/setup_repo.py tests/test_setup_repo.py evaluation/v1.3/fixture` | Passed for five Python source files, observed by the Python reviewer. |
| `python3 -m unittest discover -s tests -v` in the unchanged acceptance fixture | Two baseline tests passed. This is fixture validation, not client acceptance. |

Additional local checks parsed all six workflow YAML files with `yaml.safe_load`
and checked 64 local Markdown file targets with no missing files. The latter
does not validate heading fragments and does not replace the CI link checker.

From `mcp/`, `npm ci`, `npm run typecheck`, and `npm test` passed; the smoke suite
reported **30 assertions**. `npm --cache /private/tmp/mentor-npm-cache pack
--dry-run` passed and listed ten files, including the new subsystem reference.
The explicit temporary cache avoided a permission problem in the user's existing
npm cache. The optional MCP package remains independently versioned at 0.2.0.

Code and Python reviews found no remaining concrete blockers after fixes.
Security review verified rejection of simulated Windows junction/reparse targets
and ancestors. Native Windows execution remains unverified.

## Client evidence

Each client's record distinguishes startup failures, model behavior, independent
function checks, and configuration from observed context use. Complete traces
remain in the local temporary artifact directories recorded there.

- [Codex record](CODEX_RESULTS.md): all five scenarios passed on 0.163.0 with
  configured `gpt-6.1-sol` / `xhigh`. The initial run passed 22 independent checks;
  corrected-candidate regressions passed six more. The server's exact model
  revision was not exposed.
- [Claude Code record](CLAUDE_RESULTS.md): all five scenarios passed on
  2.1.304 with `claude-opus-5-5`, including 45 independent behavior/preservation
  assertions and 19 fixture tests. Seven complete successful transcripts cover
  the five tasks plus initial and repeated setup. Corrected-candidate regressions
  passed 14 more assertions and five fixture tests. The earlier login failure is
  retained separately.
- [IBM Bob record](BOB_RESULTS.md): all five behaviors have passing evidence on
  2.0.6 through its editor integration, including the corrected stale-guide case.
  Independent verification passed 41 function assertions across the runs, plus
  file-preservation checks. Bob did not expose its underlying model identity.
  Two early collectors missed terminal receipts after capturing final responses;
  later retests and repeated setup have complete receipts. All temporary folder
  trust entries were removed while preserving existing entries.

The acceptance fixture is deliberately small and has two subsystems. These runs
cannot establish reliability across arbitrary repositories or demonstrate the
quality of generated guides for a large repository. No broad improvement claim
is made.
