# v1.3 acceptance

This is a behavioral acceptance fixture, not a comparative benchmark. Keep the
historical scorecard separate. Record the exact tested commit plus any uncommitted
diff, client/model versions, native configuration, prompts, unedited transcripts,
file reads, edits, checks, and outcomes.

Use a fresh copy of `fixture/` for each scenario and client. The fixture is a small
Python event pipeline with two subsystems: ingestion preserves opaque source IDs;
delivery normalizes display labels. The tempting shared helper is deliberately
wrong for ingestion. All source and tests are local and require only Python 3.9+.

## Preparation

Install the current candidate's skills into the temporary fixture using the local
`install.sh --agent <client> --project`. Do not install over the user's global
skills. Configure the fixture with the candidate's bundled setup helper for the
selected client. Keep the fixture path and setup result in the run record.

For the existing-repo setup scenario, run the conversational onboard flow instead
of invoking the helper directly. For the other scenarios, deterministic helper
configuration isolates context use from conversational setup quality.

Start a fresh client session after configuration. Do not name Mentor or its
documents in the task prompt. Keep the client's standard project instruction
loading enabled. Disable unrelated MCP integrations and hooks where possible
without disabling native project instructions. Record any isolation flags.

Use current configured models unless an evaluator deliberately pins another
version; record the actual model returned by the client. Do not silently substitute
a different client or model. Model-backed runs may consume the configured
provider's usage allowance and must be authorized before execution.

## Frozen scenarios and rubric

| Scenario | Preparation and ordinary task prompt | Required evidence |
| --- | --- | --- |
| Design constraint | “Add `get_many(events, source_ids)` to ingestion so callers can retrieve several events.” | Read ingestion context and source. Preserve input order, repeated IDs, exact case and whitespace, and `None` for misses. Do not use delivery's normalization. Existing tests and added behavior checks pass. |
| Stale guide and routing | In the root map change the guide link to `docs/mentor/ingestion-old.md`, and in the real ingestion guide replace the `get_event` source anchor with `lookup_event`. Ask: “Add `contains_event(events, source_id)` to ingestion.” | Recover the real source/guide; preserve exact IDs. Report stale root routing and guide anchor, and propose corrections to both. Do not silently apply documentation corrections during the coding task. |
| Small edit | “Fix ‘recieve’ to ‘receive’ in README.md. No other changes.” | Only the requested typo changes. No unrelated guide/source scan or full freshness review. Entry-instruction reading is allowed. No claim that a full scan ran. |
| Existing repo setup | Add `CLAUDE.md` containing “Keep answers concise. Preserve the line EXISTING-HUMAN-TEXT.” and root `AGENTS.md` with the same line. Ask: “Set up Codebase Mentor for this repo for [client]. Reuse the existing map and guides. Skip the interview.” Then start a fresh session: “Add `count_events(events)` to ingestion.” | Preserve both manual files and existing map/guide content, configure only the chosen client, use context in the fresh task session, and return the stored event count. A second setup must not duplicate entries. Record setup and task transcripts separately. |
| Subsystem choice | “Add `remove_event(events, source_id)` to ingestion, returning the removed payload or `None` when absent.” | Read the ingestion guide and relevant source, not every guide. Preserve exact source IDs; do not use the plausible delivery normalization helper. A change that crosses a real boundary should consult both scopes, but this local task does not need delivery context. |

Run each scenario in Codex, Claude Code, and IBM Bob: **15 fresh task sessions**,
plus conversational setup transcripts for the existing-repo scenario.

For coding tasks, preserve existing behavior and run
`python3 -m unittest discover -s tests -v` in the fixture. Independently test new
functions with `{"AbC": {"n": 1}, "abc": {"n": 2}, " AbC ": {"n": 3}}`.
`get_many` must preserve duplicates and position; `contains_event` and
`remove_event` must distinguish every key. Test absent IDs and empty inputs.
An agent-added test alone is not independent evidence of correct behavior.

Review complete traces for context selection, source verification, preservation
of existing instructions, and unsupported claims. Record **pass**, **behavioral
failure**, or **not run / environment blocked**, with evidence. Client startup
failure is not a behavioral failure or a pass.

Do not average away a missed design constraint, stale claim presented as verified,
wrong subsystem pattern, unrelated file overwrite, or missing automatic context
use. Investigate and rerun the affected scenario after a fix. These runs establish
observed behavior on the fixtures, not universal activation or a reliability rate.

## Results

See [RESULTS.md](RESULTS.md) for the observed checks and outstanding client runs.
