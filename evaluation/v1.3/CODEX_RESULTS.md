# Codex v1.3 acceptance

Observed on October 20, 2026. This is fixture acceptance, not a comparative
benchmark or a reliability estimate.

Candidate 1 passed all five scenarios. Candidate 2 passed fresh stale-routing
and small-edit regressions after the shared guide-recovery instructions changed.
The other three outcomes carry forward from candidate 1; they were not rerun
against candidate 2.

## Candidate 1 and environment

- Base commit: `d85ba66c30ee4af98486ec6fbd0e313681942884`.
- Tracked candidate diff SHA-256:
  `86779d8175dab5d64d4da62dfc2ab787efb5e0f1e8cabf7142de3cef522705a0`.
- The diff hash excludes new untracked files. All 11 installed skill files,
  including the new helper and references, have individual SHA-256 hashes in
  `/private/tmp/mentor-v13-codex-20261020/candidate-skills-sha256.json`.
  That inventory's SHA-256 is
  `79fa4a54d14e11e4c0025f9c3e9f74881d012b269efd26f8cabf9d25580a7bcc`.
- Client: `codex-cli 0.163.0`.
- Selected model: the existing `gpt-6.1-sol` configuration, reasoning `xhigh`.
  No model override was supplied. JSON event output does not identify a
  server-side model revision.
- Native entry: root `AGENTS.md`, using the candidate's managed setup block.
  Project skills were installed with
  `bash <candidate>/install.sh --agent codex --project`.
- Each task used a fresh session and its own synthetic repository. Sessions used
  `--no-daemon -a never exec --sandbox workspace-write --ephemeral --json`.
  Per-invocation flags disabled plugins, hooks, apps, memories, chronicle,
  subagents, and configured MCP servers. Native project instructions and skill
  discovery stayed enabled. Global user instructions and skills remained
  available, so these runs do not isolate Mentor from every user preference.
- The outer execution sandbox prevented Codex's local app server from starting.
  Reviewed execution outside that outer sandbox succeeded; the nested Codex
  session retained its `workspace-write` sandbox.

Exact commands, prompts, complete raw JSONL output, stderr, final messages, exit
codes, and pre-run file hashes are stored under
`/private/tmp/mentor-v13-codex-20261020/`. These are local artifacts, not committed
portable transcripts. Temporary fixture initialization invoked the workstation's
existing Vault Radar Git hook. No product repository commit or global
configuration change was made by this evaluation.

## Candidate 1 outcomes

| Scenario | Outcome | Observed evidence |
| --- | --- | --- |
| Design constraint | Pass | `1-design/task.jsonl`: automatically selected the installed Mentor skill, read the root map, ingestion guide, source, and tests. `get_many` preserves order, duplicates, exact IDs, and missing positions. Five independent checks passed; the fixture suite passed 5 tests. |
| Stale guide and routing | Pass after environment retry | `2-stale-retry/task.jsonl`: recovered the actual guide and `get_event`, proposed both routing and anchor corrections, and left context documents unchanged. Five independent checks passed; the fixture suite passed 5 tests. |
| Small edit | Pass | `3-small/task.jsonl`: read entry context and README, with no subsystem guide or unrelated source scan. Only the requested typo changed. One independent preservation check passed; the fixture suite passed 2 tests. |
| Existing repo setup | Pass after environment retries | `4-existing-retry/setup-first.jsonl`, `setup-repeat.jsonl`, and `task.jsonl`: both manual files and all map/guide content preserved; only Codex's entry configured; fresh repeat setup changed nothing. The count task automatically read the map, ingestion guide, and current source. Seven independent checks passed; the fixture suite passed 4 tests. |
| Subsystem choice | Pass | `5-subsystem/task.jsonl`: read the ingestion guide, source, and tests; did not read the delivery guide or copy its normalization. Four independent checks passed; the fixture suite passed 6 tests. |

All five scenarios passed **22 independent checks**. Their fixture
suites were independently rerun with
`PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v`, passing
5, 5, 2, 4, and 6 tests respectively. Client-added tests are separate from the
independent checks.

Independent output is in `independent-completed-tests.txt`,
`independent-stale-tests.txt`, `independent-setup-tests.txt`, and each scenario's
`independent-fixture-tests.txt`. The stale-case verification command was
`python3 /private/tmp/mentor-v13-codex-20261020/verify-additional.py StaleTests`.
The setup/count verification command was
`python3 /private/tmp/mentor-v13-codex-20261020/verify-additional.py SetupTests`.

## Candidate 2 regressions

The corrected candidate has tracked diff SHA-256
`a8cb2dcd9c05517c9b0a3c772ab3b026e8a96a196999c7fe9fc769a91d7c6645`,
against the same base commit. Its 11-file installed skill inventory is
`/private/tmp/mentor-v13-codex-v2-20261020/candidate-skills-sha256.json`, with
SHA-256 `daf1343984a2cf9f8056e5b1d4ed557a38d7ce7d189ea91e0e09731d5b8661a3`.
Both scenarios used newly prepared copies, the same frozen prompts, the same
client/configured model, and the same native entry and isolation flags. Raw
traces and commands are under `/private/tmp/mentor-v13-codex-v2-20261020/`.

| Scenario | Outcome | Observed evidence |
| --- | --- | --- |
| Stale guide and routing | Pass | `2-stale/task.jsonl`: read the root entry and map, searched documentation for the moved guide, recovered `ingestion.md`, and verified the stale symbol against source. Implemented exact membership and created an unapplied patch fixing both the root link and guide references. Five independent checks passed, including unchanged context files; the fixture suite passed 6 tests. |
| Small edit | Pass | `3-small/task.jsonl`: read the skill/root entry and README, with no subsystem-guide or source scan. Only the requested typo changed; the independent preservation check passed. |

The two regressions passed **6 independent checks**:

```bash
python3 /private/tmp/mentor-v13-codex-v2-20261020/verify-regressions.py StaleTests
python3 /private/tmp/mentor-v13-codex-v2-20261020/verify-regressions.py SmallEditTests
```

The stale fixture's independent rerun used
`PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -v`.
The proposed documentation patch is preserved at
`/private/tmp/mentor-v13-codex-v2-20261020/2-stale/proposed-context.patch`.
Both regression sessions completed on their first model attempt.

## Interrupted attempts

The first stale-routing and setup sessions stopped with
`failed to load workspace requirements` after the client's own reconnect
attempts. The global MCP configuration changed externally while they ran:
`skillroute` was present during preparation and absent afterward. Reusing its
disable override then produced `invalid transport in mcp_servers.skillroute`.
Refreshing the disable list from current configuration allowed stale-routing
acceptance to complete. These interruptions are not behavioral failures.

The next setup attempt returned
`Selected model is at capacity. Please try a different model.` After a cooldown,
one retry using the same configured model completed setup, repeat setup, and the
fresh coding task. No different model was substituted. Initial harness quoting
and outer-sandbox failures are also retained alongside the complete task traces.
No candidate 1 scenario remains environment blocked.
