# IBM Bob acceptance results

**All five behaviors have observed passes.** The initial candidate passed four
scenarios and failed stale-guide recovery. The corrected candidate passed fresh
stale-guide and small-edit retests. The other three scenarios were not repeated
because the change addressed missing-guide recovery. This is fixture acceptance,
not a reliability rate or comparative benchmark.

## Results

| Scenario | Initial candidate | Corrected candidate | Evidence |
| --- | --- | --- | --- |
| Design constraint | Pass | Not repeated | Read the root map, ingestion guide, source, and tests. `get_many` preserves order, repeated IDs, exact case/whitespace, and `None` for misses. Five unit tests and three independent contract assertions passed. |
| Stale guide and routing | Behavioral failure | Pass | Initially skipped the guide and proposed no corrections. The retest recovered the real guide, proposed changing the root's `ingestion-old.md` link to `ingestion.md` and its `lookup_event` references to `get_event`, and preserved all context files. Three unit tests and ten independent identity assertions passed. |
| Small edit | Pass | Pass | Both runs changed only `recieve` to `receive` in README. No unrelated source/guide reads or full-scan claim. The retest has a clean terminal protocol response. |
| Existing repo setup | Pass | Not repeated | Conversational setup added only `.bob/rules/codebase-mentor.md`; both human instruction files and all existing context remained byte-identical. Repeat conversational setup changed zero files and left one managed block. A fresh task read map, ingestion guide, source, and tests before implementing `count_events`. Three unit tests and four independent assertions passed. |
| Subsystem choice | Pass | Not repeated | Read ingestion context and relevant source/tests without reading the delivery guide. `remove_event` preserves exact IDs. Three unit tests and fourteen independent assertions passed. |

All coding tasks used the ordinary prompts in the frozen rubric without naming
Mentor or its documents. The two setup sessions used the prescribed conversational
setup prompt, including the selected client and skipped interview. No context
corrections were silently applied.

Independent checks used `{"AbC": {"n": 1}, "abc": {"n": 2}, " AbC ": {"n": 3}}`,
misses, empty inputs, and, for membership, a stored `None` value. The evaluator
separately reran `python3 -m unittest discover -s tests -v` in each coding fixture.
Unit-test totals above are per scenario, not cumulative confidence measures.

## Candidate identity

Both candidates use base commit
`d85ba66c30ee4af98486ec6fbd0e313681942884` plus uncommitted changes.

| Candidate | Frozen tracked diff SHA-256 | Installed skill inventory SHA-256 |
| --- | --- | --- |
| Initial | `86779d8175dab5d64d4da62dfc2ab787efb5e0f1e8cabf7142de3cef522705a0` | `20e8216949b29a26623f481810a094eb4052e40eb457cb02256e243bcabdf186` |
| Corrected | `a8cb2dcd9c05517c9b0a3c772ab3b026e8a96a196999c7fe9fc769a91d7c6645` | `c6dfb4b6ff1ca540ca15bba7c9569873e4b1cbc041179f7c6909b4511326fa62` |

The tracked diff hashes exclude untracked files. Each installed inventory contains
all 11 skill files, including the helper and new references. Inventory hashes are
SHA-256 of sorted, compact JSON mapping each installed path to its content hash.
Complete per-file hashes and each fixture's pre-session state are preserved in the
local metadata files. The corrected candidate strengthens missing-guide recovery
in the native setup entry and protocol.

## Client and session configuration

Observed behavioral runs used **Bob Shell 2.0.6, commit `88346061a`**, through its
supported Agent Client Protocol server, protocol version 1, in default `agent`
mode. No model override was supplied. The underlying model identity is **not
exposed by these ACP traces**; the configured `session.model` field was unset.
This limits model-specific reproducibility, and no model identity is inferred.

Each run started a new Bob process and new session with:

```bash
bob acp --disable-mcp --disable-subagents --trust
```

Only the known synthetic fixture path was opened in each process. Native project
instructions remained enabled. Unrelated MCP integrations and subagents were
disabled; other existing user configuration remained in place. Tool permissions
were approved once only for inspected fixture setup, reads, edits, and test
commands. No global auto-approval flag was used.

The initial five fixtures were installed using
`bash /Users/erichare/GitHub/codebase-mentor/install.sh --agent bob --project`.
The installed helper configured only Bob for scenarios 1, 2, 3, and 5. Scenario 4
used conversational setup and repeat setup. The two corrected-candidate retests
used fresh fixture copies and the corrected installed files.

Scoped folder trust was required by Bob. The seven new fixture trust entries were
removed after the runs by reading the latest trust store and deleting only the
new entries. All other current entries were preserved and verified. No credential
change, new login, or license acceptance was performed by the evaluator.

## Artifacts

Local artifact directory: `/private/tmp/mentor-v13-bob-l3lxybim/`.
Temporary artifacts are not committed and should be retained separately if needed
for long-term reproducibility.

- `metadata.json`, `candidate.diff`, `resumed-client-metadata.json`: initial
  candidate, installed hashes, fixture paths, and observed client version.
- `1-design-acp.protocol.jsonl`, `2-stale-acp.protocol.jsonl`,
  `3-small-acp.protocol.jsonl`, `4-count-acp.protocol.jsonl`,
  `5-subsystem-acp.protocol.jsonl`: original ordinary-task traces.
- `4-setup-first-acp.protocol.jsonl`, `4-setup-repeat-acp.protocol.jsonl`:
  conversational setup traces; `4-after-setup.json` and
  `4-after-repeat-setup.json` prove repeat setup changed zero files.
- `v2/metadata.json`, `v2/candidate.diff`: corrected candidate and fresh fixtures.
- `2-stale-v2-acp.protocol.jsonl`, `3-small-v2-acp.protocol.jsonl`: corrected
  candidate retests, both ending with `stopReason: end_turn`.
- `*-independent-tests.log`, `independent-results.json`,
  `v2/2-independent-tests.log`, `v2/independent-results.json`: independently
  observed test results and contract checks.
- `independent_contracts.py`: rerunnable evaluator checks; **41 function
  assertions passed**, plus both small-edit and repeated-setup checks.
- `trust-before-resumed.json`, `trust-cleanup-resumed.json`: seven narrowly scoped
  grants and verified removal, preserving existing entries.

Protocol logs preserve raw messages received from Bob and the client's requests,
including permission decisions. The initial small-edit and first-setup collectors
stalled after capturing Bob's final response because their line reader buffered
the terminal protocol reply. They were stopped after the tasks had finished; those
two traces lack the terminal receipt. The collector was corrected before later
runs. The small-edit retest and repeated setup have complete terminal receipts;
the first setup's file diff and tool/final-response evidence are retained.

## Initial environment blockers

Before the user signed in, Bob 2.0.1 (`e6a3e508`) could not start a model task:

- `bob run` exited 1 with `Bob API key is required. Set BOB_API_KEY environment variable.`
- An ACP attempt to reuse existing SSO returned `Authentication required`
  (`-32000`). No `authenticate` or model prompt request was sent in that probe.
- The probe's single temporary fixture trust entry was removed and verified.

Those attempts were environment blocks, not behavioral failures. The user then
signed in through Bob. Subsequent ACP sessions identified Bob 2.0.6 and reused
that authentication successfully. The original failed startup logs, protocol
probes, and cleanup evidence remain in the artifact directory.
