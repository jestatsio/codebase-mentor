# Claude Code v1.3 acceptance

**Latest check: candidate 2 passed both targeted regressions**, with 14 additional
independent assertions and 5 fixture tests. The original five-scenario matrix is
preserved below; candidate 2 details follow at the end.

**Candidate 1 full matrix: all five frozen scenarios passed.** Five fresh task sessions and two
separate conversational setup sessions completed on Claude Code 2.1.304 using
`claude-opus-5-5`. Independent verification passed **45 behavior and preservation
assertions**, plus **19 tests across five fixture suites**.

This is observed behavior on the acceptance fixtures, not a comparative benchmark
or an estimate of general reliability. The earlier authentication failure is
retained below as history.

## Candidate and environment

- Date: October 20, 2026.
- Source HEAD: `d85ba66c30ee4af98486ec6fbd0e313681942884`.
- SHA-256 of `git diff --binary` at preparation:
  `86779d8175dab5d64d4da62dfc2ab787efb5e0f1e8cabf7142de3cef522705a0`.
  This identifies tracked changes only. Each scenario's
  `initial-inventory.json` separately hashes installed skills and fixture files,
  including new files. All 11 installed skill files also matched the original
  frozen candidate byte for byte.
- Client and model: all seven successful session startup events record Claude
  Code `2.1.304` and `claude-opus-5-5`. No model override was supplied.
- Authentication: Claude Max account after the user completed login.
- Artifact root: `/private/tmp/mentor-v13-claude-rerun-vt7d4fnt`.
- Each scenario used a separate fresh copy of the fixture. No fixture Git
  initialization, commits, or Git hooks were needed.

From each fixture directory, installation used:

```sh
bash /Users/erichare/GitHub/codebase-mentor/install.sh --agent claude --project
```

Four scenarios used the installed helper to configure Claude before the task:

```sh
python3 .claude/skills/onboard/setup_repo.py setup --root <fixture> --agent claude
```

The existing-repo scenario used the frozen conversational setup prompt instead.
The evaluator did not configure its native rule directly.

## Outcomes

| Scenario | Outcome | Trace and independent evidence | Independent assertions | Fixture tests |
| --- | --- | --- | ---: | ---: |
| Design constraint | Pass | Read the root map, ingestion guide, source, and tests before editing. `get_many` preserves order, repeats, exact IDs, and `None` positions. Empty and generator inputs work; the store is unchanged. | 5 | 5 |
| Stale guide and routing | Pass | Found the actual ingestion guide and source. Proposed fixing both the missing root link and the two `lookup_event` anchors. All context documents remained unchanged. `contains_event` distinguishes exact IDs and counts a stored `None` payload as present. | 12 | 5 |
| Small edit | Pass | Tool trace contains only README grep/read/edit. The complete file inventory confirms the single requested typo replacement, with no unrelated guide/source scan or freshness claim. | 2 | 2 |
| Existing repo setup | Pass | Setup added only the Claude rule. Repeated setup changed no file bytes or inventory and retained exactly one managed entry. A separate fresh task read the map and ingestion guide through shell tools, then implemented the stored event count. Both human instruction files and all context documents were preserved; no other client was configured. | 15 | 3 |
| Subsystem choice | Pass | Read the ingestion guide and relevant source/tests without reading the delivery guide. `remove_event` removes only the exact requested ID, returns its payload or `None`, and preserves other entries. | 11 | 4 |
| **Total** | **5 / 5 pass** | Five ordinary task sessions, plus initial and repeated conversational setup. | **45** | **19** |

The existing-repo row includes 12 behavior/preservation assertions, one full
inventory check after setup, and two repeated-setup checks. Fixture-suite exit
checks are excluded from the assertion counts. The two setup sessions also ran
the original two-test suite; those runs are not added to the independent
19-test total.

All four coding sessions independently demonstrated use of the root map and
ingestion guide without mentioning Mentor in the task prompt. The typo task
appropriately skipped them. Initial and repeated setup both distinguished
configured files from fresh-session behavior that was not yet observed.

## Verification

The evaluator ran the independent verifier once per scenario:

```sh
python3 /private/tmp/mentor-claude-verify.py design-constraint
python3 /private/tmp/mentor-claude-verify.py stale-guide
python3 /private/tmp/mentor-claude-verify.py small-edit
python3 /private/tmp/mentor-claude-verify.py existing-setup
python3 /private/tmp/mentor-claude-verify.py subsystem-choice
```

An identical copy is preserved as `verify.py` in the artifact root.
Each invocation tested behavior or file preservation independently of
agent-written tests, then ran this command in its fixture:

```sh
python3 -m unittest discover -s tests -v
```

The observed counts were 5, 5, 2, 3, and 4 tests, respectively, all passing.
Separate SHA-256 inventory comparisons verified that initial setup added only
`.claude/rules/codebase-mentor.md`, and that repeated setup changed nothing.
Python cache files were excluded from file-preservation comparisons.

## Session isolation and limitations

Native project instruction loading remained enabled. Session settings disabled
hooks and all six globally enabled plugins, including the global Mentor plugin,
so the project installation supplied the candidate skills. Strict empty MCP
configuration disabled unrelated integrations. User skill discovery and built-in
plugins remained enabled and are recorded in startup metadata. Global settings,
authentication files, and user instructions were not modified. The
[Claude CLI reference](https://code.claude.com/docs/en/cli-reference) documents the
session flags; the installed CLI's help was also inspected.

Sessions used `--print --output-format stream-json --verbose`,
`--no-session-persistence`, `--permission-mode acceptEdits`,
`--permission-prompts none`, a limited tool allowlist, `--no-chrome`, and a $2
per-session ceiling. Exact argument vectors and session settings are retained.
No permission bypass, `--bare`, or `--safe-mode` was used.

The five ordinary task sessions had no permission denials. Initial setup had two
shell inspection denials and repeated setup had one under the conservative
allowlist. The agent recovered with file reads and disclosed the remaining
inspection limits. The evaluator separately verified every required preservation
condition.

Repeated setup made an unverified platform claim that Claude would not read
`AGENTS.md` without an import, while startup metadata listed the built-in
`cc-plugin-agents-md`. That claim is not adopted as a finding. The observed
result is narrower: both human instruction files were preserved and the
dedicated Claude rule successfully led the subsequent task to the context.

The seven completed sessions reported **$3.922092 in list-price-equivalent
usage**. Their model usage metadata identifies `costBasis: list`; this is not a
claim about charges to the user's Max account.

## Complete local artifacts

All paths below are relative to
`/private/tmp/mentor-v13-claude-rerun-vt7d4fnt`:

| Session | Unedited stream transcript |
| --- | --- |
| Design constraint | `design-constraint-artifacts/task.stream.jsonl` |
| Stale guide and routing | `stale-guide-artifacts/task.stream.jsonl` |
| Small edit | `small-edit-artifacts/task.stream.jsonl` |
| Initial conversational setup | `existing-setup-artifacts/setup.stream.jsonl` |
| Repeated conversational setup | `existing-setup-artifacts/repeat.stream.jsonl` |
| Fresh count task after setup | `existing-setup-artifacts/task.stream.jsonl` |
| Subsystem choice | `subsystem-choice-artifacts/task.stream.jsonl` |

Each session also has exact prompt, argument vector, stderr, execution status,
and a trace audit. Scenario directories retain the final fixture; each
`*-artifacts/initial` directory retains its original copy. Independent assertion
results and full test output are in `independent-checks.json` and
`independent-baseline-tests.txt`. Setup inventory comparisons have separate
records. Root `metadata.json`, `candidate.diff`, and `summary.json` contain source
identity, transcript hashes, counts, and usage. `run-session.py` and `verify.py`
preserve the runner and independent checks.

These are local temporary artifacts, not published or committed traces.

## Earlier blocked attempt

Before the user renewed authentication, Claude Code 2.1.296 was unable to start
the design-constraint task:

> Failed to authenticate: OAuth session expired and could not be refreshed

That attempt exited 1 before model inference or tool work, with zero API
duration, zero tokens, empty model usage, and $0 reported cost. The other four
scenarios were not attempted under the expired login. The fixture was unchanged;
its two baseline tests passed. This was an environment block, not a behavioral
failure, and none of its checks count toward the successful results above.

Its complete record remains in `/private/tmp/mentor-v13-claude-todwoaqp`,
including `design-constraint.stream.jsonl`, invocation, installation/setup
outputs, candidate inventory, and baseline-test output. All successful scenarios
used fresh fixture copies after login. The evaluator did not invoke a client
update; the newer version is what the successful startup events reported.

## Candidate 2 targeted regression

After candidate 1, a Bob run exposed insufficient recovery from a missing guide
link. Candidate 2 explicitly requires searching for a moved relevant guide before
editing, verifying replacement scope and source anchors, and proposing the root
routing and guide corrections together. Its small-task constraint remains intact.
Only the affected stale-guide scenario and the small-edit regression were rerun
in Claude; the other three scenarios were not rerun on candidate 2.

**Both targeted regressions passed** in fresh fixtures on October 20, 2026. Both
startup events record Claude Code `2.1.304` and `claude-opus-5-5`, with no model
override and the same isolation settings and frozen prompts as candidate 1.

| Scenario | Observed behavior | Independent assertions | Fixture tests |
| --- | --- | ---: | ---: |
| Stale guide and routing | Read the root map, listed repository files, found and read the actual ingestion guide, and verified `get_event` in source before editing. Proposed the root-link correction and both stale `lookup_event` anchors together; left all context documents unchanged. Exact-ID membership, missing/empty cases, and stored `None` passed. | 12 | 3 |
| Small edit | Only README grep/read/edit appeared in the trace. The full inventory confirms the exact typo-only change, with no unrelated guide/source reads or freshness review. | 2 | 2 |
| **Total** | **2 / 2 pass** | **14** | **5** |

The stale-guide session also proposed adding the new function to the root map's
function list. All proposed documentation edits remained unapplied. One shell
loop was denied by the evaluator's conservative allowlist; the agent recovered
by reading each relevant file separately and disclosed the denial. The small-edit
session had no permission denials.

The evaluator ran:

```sh
python3 /private/tmp/mentor-v13-claude-v2-iuw5mhk4/verify.py small-edit
python3 /private/tmp/mentor-v13-claude-v2-iuw5mhk4/verify.py stale-guide
```

Each invocation independently checked behavior and preservation, then ran
`python3 -m unittest discover -s tests -v` in its fixture. The 14 assertion count
excludes suite-exit checks; the two fixture suites ran 2 and 3 tests, respectively,
all passing.

Candidate identity and installed file SHA-256 values:

| Item | SHA-256 |
| --- | --- |
| `git diff --binary`, source HEAD `d85ba66c30ee4af98486ec6fbd0e313681942884` | `a8cb2dcd9c05517c9b0a3c772ab3b026e8a96a196999c7fe9fc769a91d7c6645` |
| Installed `onboard/setup_repo.py` | `ddd550e9a0118bc4bc952dc12f27b96936963a8b82c03423b499b7e5711a7d89` |
| Installed `onboard/SETUP.md` | `903e8b598b2badfd6c4e793f1123b2fef1b341819119f89f812af205f1e49938` |
| Installed `onboard/mentor-protocol.md` | `7482b7ae6f18b6ba0d274e7836562274628fad02d4f3484c4bdd1657c48ae3f7` |
| Generated `.claude/rules/codebase-mentor.md` | `aff090a56c5421d73952c2ed69247098c5a8042139331a7b249e070bde9f3b26` |
| Stale-guide full installed/fixture inventory | `275662da1716d69cf80ffc5fd203bed7081d871c939d451fa97fdf3a042d0619` |
| Small-edit full installed/fixture inventory | `461c2a1da0dbb4757dd917c38944c6d8c42b37f444798cbaa98753480f58123a` |

The complete additional record is in
`/private/tmp/mentor-v13-claude-v2-iuw5mhk4`. Unedited traces are
`stale-guide-artifacts/task.stream.jsonl` and
`small-edit-artifacts/task.stream.jsonl`. Each scenario retains its prompt,
argument vector, stderr, initial file inventory, initial and final fixture,
trace audit, independent checks, and full test output. Root `metadata.json`,
`candidate.diff`, `summary.json`, `run-session.py`, and `verify.py` retain the
candidate identity and evaluation procedure.

The two sessions report an additional **$0.7424262 in list-price-equivalent
usage**, not confirmed charges to the Max account. These results provide two
additional regression observations; they do not constitute a new complete
five-scenario run or a reliability estimate.
