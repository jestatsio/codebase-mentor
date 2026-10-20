# Codebase Mentor v1.3.0 — Release scope

**Status:** Implemented locally on October 20, 2026. All 15 client scenarios have passing evidence, including targeted retests after a guide-recovery fix. See [the v1.3 results](../evaluation/v1.3/RESULTS.md) for exact coverage and limitations. Publication remains a separate step.
**Prepared:** October 20, 2026.
**Baseline:** Latest published plugin release at scoping was v1.2.2. Source baseline: `d85ba66c30ee4af98486ec6fbd0e313681942884`.

## Release outcome

Set up a repository once, then have agents use its design context during ordinary work. An agent should understand why the repository works the way it does before applying a generic solution.

The primary user is an individual developer working in an existing repository. Codex, Claude Code, and IBM Bob are equal release priorities.

### Decisions confirmed during scoping

- Context should be used automatically after setup.
- Setup should draft from source, then ask up to three targeted questions.
- The central failure to prevent is agent-written code that misses the nuances of the repository's design.
- Mentor should notice relevant documentation drift and propose a small update for review.
- Large repositories should also receive focused guides for important subsystems.

### Proposed boundaries

Keep the skills-based, local-file product. Use one short entry map that links to existing documentation and focused subsystem guides drafted during setup. Preserve the existing skills and explicit mentoring workflows. These implementation boundaries are scope recommendations.

## What changes for the user

1. Install Mentor using the existing path for the chosen agent.
2. Ask: **“Set up Codebase Mentor for this repo.”**
3. Mentor reads existing instructions, docs, representative source, and tests. It drafts or improves the repo map, identifies important subsystems that need deeper guides, and asks at most three questions about consequential unknowns.
4. Setup drafts those focused guides, connects the selected agents to the entry map through their project instructions, and reports what changed and how to verify the next session.
5. In a fresh session, ask an ordinary question or request a change without mentioning Mentor. The agent follows the entry map to relevant subsystem context, checks current source, and continues the task.
6. If a relevant map entry has become stale, Mentor explains the discrepancy and proposes a focused correction for review.

The everyday interaction should stay concise. Mentor should surface a design constraint when it changes a decision, without adding a separate architecture report to every coding task.

## Required features

### 1. One guided setup, including an honest status check

Extend the existing `onboard` skill instead of introducing another setup skill.

- Identify the selected project and existing map. Reuse its location and human-authored content.
- Read existing instructions and linked docs before drafting. Avoid another copy of facts already maintained elsewhere.
- Produce a useful source-based draft before interviewing the developer.
- Identify important subsystems from architecture boundaries, representative execution paths, and the developer's likely work. Show the selected areas and draft focused guides where existing documentation is insufficient. Proposed first-pass budget: at most three new guides, prioritizing consequential design constraints. List important areas not yet covered and support later expansion on request. Avoid generating one document per directory.
- Ask at most three targeted questions across the whole setup, chosen from gaps that could lead to incorrect changes. Do not restart the question allowance for each subsystem. Allow unanswered questions to remain clearly marked.
- Add the smallest project instruction entry needed by each selected agent. Keep repository context in the shared context documents.
- Repeat setup without duplicating instructions, maps, or subsystem guides, and without replacing unrelated text. Handle partial setup and conflicting maps with a clear next step.
- Support **“Is Mentor set up correctly here?”** as a read-only request. Report the project, authoritative map, configured instruction entry, missing or conflicting files, and unresolved context.
- Distinguish **configured files** from **observed use in a fresh session**. Do not claim that file presence proves activation.
- Document update and removal behavior. Removing Mentor's managed instructions must preserve the repo map and user content.

Setup authorizes local configuration for the selected repository and agents. It does not require configuring every supported agent on the machine or changing global preferences.

**Acceptance:** A developer can complete setup without learning operating modes or choosing a new storage architecture. A second setup preserves their edits and creates no duplicate entries.

### 2. Automatic context use during ordinary work

Add a brief instruction entry that guides the agent to the repo map before substantive repository work. The map should associate subsystem guides with relevant paths and kinds of changes. Follow only the links relevant to the task; a change crossing subsystem boundaries may need more than one guide.

For a normal change, the agent should establish:

- Which subsystem owns the behavior and where the change belongs.
- Which existing implementation is the closest valid example.
- Which design constraints, exceptions, and failure modes apply.
- Which source and tests support the intended approach.
- Which verification command is appropriate and what it requires.

Then continue the requested work. A small, isolated edit should require proportionally little context. Do not run a full repository scan or reread unchanged evidence before every action.

Native project instructions are the delivery mechanism; actual client behavior still needs verification:

| Client | Proposed setup approach | Compatibility issue to check |
| --- | --- | --- |
| Codex | Add or reuse a short managed entry in the effective project instructions. | `AGENTS.override.md`, nested instructions, and size limits can affect what loads. [Official guidance](https://developers.openai.com/codex/guides/agents-md) |
| Claude Code | Reuse the effective project instruction surface and avoid duplicate entries. | Current versions can read `AGENTS.md`, but existing `CLAUDE.md` files and settings affect that behavior. Use a compatible native entry where needed. [Official guidance](https://code.claude.com/docs/en/memory#agentsmd) |
| IBM Bob | Reuse effective workspace instructions or add a small dedicated rule. | Bob supports workspace `AGENTS.md` and `.bob/rules/`; settings and rule order affect loading. [Official guidance](https://bob.ibm.com/docs/ide/configuration/rules) |

These approaches were selected from client documentation during scoping. The linked results now record the tested client versions, native surfaces, observed behavior, and limitations.

**Acceptance:** Fresh sessions in all three clients use relevant repo context during ordinary tasks without an explicit Mentor invocation. Existing project instructions remain effective.

### 3. Context that captures design nuance

Improve the existing map and change recipes, and add focused subsystem guides. Keep the root's seven-section format compatible with existing maps.

The most valuable entries should answer:

| Context | What the agent needs |
| --- | --- |
| Design constraint | What must remain true, which area it applies to, and the consequence of violating it. |
| Rationale | Why the design exists, attributed to an existing decision document or the developer who confirmed it. |
| Valid example | The nearby implementation worth following, including when it is not applicable. |
| Change recipe | The relevant source, tests, verification command, and prerequisites. |
| Known uncertainty | What source cannot establish and what still needs human input. |

Do not infer historical intent from implementation alone. Separate observed behavior, documented decisions, developer-confirmed rationale, and unresolved assumptions. If a documented constraint and current behavior conflict, surface the conflict before treating either as settled.

For this repository, a concrete example is that distributed skill and adapter files are generated. A plausible edit to an installed-looking file can disappear on regeneration. Useful context tells the agent which canonical source to change, why the copies exist, and how to check them.

The default entry map should be short enough to read routinely: retain the existing 400–800 word target and move deeper detail to relevant links where useful. Existing longer maps remain supported. Do not migrate existing documents merely to fit a word count.

Subsystem guides are included in this release:

- Each guide names its scope, relevant paths, responsibilities, important boundaries, local design decisions, valid examples, tests, and known traps. Include cross-subsystem contracts where a local change can affect another area.
- Reuse a useful existing guide in place. For genuinely new guides, propose `docs/mentor/<subsystem>.md` as the default location and link it explicitly from the root map. Custom paths remain valid; users need no configuration file.
- Keep each guide focused on information that changes implementation decisions. Do not repeat the root overview or inventory every source file.
- Distinguish source-verified claims, attributed rationale, and open questions. Record the verification scope and source revision when available.
- Treat drafted guides as maintainable project documentation, not disposable outputs that setup overwrites on regeneration.
- Resolve guide relevance through the root map's explicit links and scope descriptions. Do not assume every nested document overrides broader guidance. Conflicting claims require source verification or human clarification; context documents do not override the user's instructions.
- A small repository may need no subsystem guides. A large repository starts with the highest-value areas within the initial guide budget; uncovered areas must remain visible. Existing useful guides may be linked without counting as newly drafted guides.

Suggested setup questions should be specific to findings, such as “These two paths look similar but use different validation. Is that separation intentional?” Generic questionnaires should not consume the three-question allowance when source already answers them.

**Acceptance:** In a task where a generic solution violates a documented design constraint, the agent identifies and respects the constraint, uses the correct source/example, and explains the consequential choice. In a repository with multiple subsystems, it selects the relevant guide and avoids applying an inappropriate sibling subsystem's pattern.

### 4. Focused maintenance with reviewable updates

Check claims relevant to the current task while using them. At task completion, use the changed source and the root or subsystem entries consulted to identify likely documentation updates.

- Recover from stale source anchors through current source inspection.
- Propose a small diff for affected context; wait for approval before applying the proposed maintenance update unless the user already authorized it.
- Preserve human rationale and unrelated content. A code change alone does not invalidate the reason behind an older decision.
- Keep root-to-guide links and scope descriptions current when subsystem boundaries change. Propose updates to the affected guide and any affected index entry together.
- State which entries were checked. A focused check cannot mark the whole map current.
- Stay quiet when no relevant drift is found.
- Keep the existing explicit full scan for comprehensive reviews. Extend its default document set to the entry map plus the subsystem guides explicitly listed by that map, whether reused or newly drafted. Do not recursively crawl every link in those documents. Report documents and claims checked, skipped, or unverifiable; a partial scan must not claim complete coverage. An explicitly requested document-only scan stays limited to that document. Scheduled scanning remains optional.

The current [freshness issue #19](https://github.com/jestatsio/codebase-mentor/issues/19) is a useful acceptance case: the map refers to a removed installer function and incompletely describes generated artifacts. Reproduce and verify those findings against the pinned evaluation checkout.

**Acceptance:** A stale entry is not repeated as verified fact. The agent offers an accurate, focused correction while preserving unrelated context.

## Scope limits and compatibility

Defer these from v1.3:

- A hosted service, vector database, embeddings, repository index, or background daemon.
- A new CLI product or dashboard. Start with conversational setup and status; add deterministic helpers only where they improve correctness.
- Automatic rewriting of persistent context during ordinary work.
- An exhaustive recursively generated hierarchy, automatic discovery of arbitrary nested maps, cross-repository context, or a new required document schema. Focused subsystem guides linked from the root are in scope.
- New scheduled automation or a requirement for CI secrets.
- Publishing the optional MCP server or adding semantic search and section retrieval to it.

Continue supporting existing explicit skills and portable adapters. Current maps must work without migration. Ordinary plugin installation should not silently rewrite a project's instructions; the new repo setup flow performs that work. Preserve the existing behavior of explicitly requested adapter installs, which already write Cursor rules or managed Copilot/AGENTS.md entries.

MCP remains optional and independently versioned. There is an existing discovery mismatch: the protocol checks root, `docs/`, and `doc/` and accepts an explicit map path, while MCP searches upward for the first root-named map. Track that parity fix separately; do not include MCP in v1.3's automatic-context promise.

## Implementation sequence

| Slice | Main files | Result and dependencies |
| --- | --- | --- |
| 1. Define useful task context | `core/mentor-protocol.md`, compact variant, `template/ONBOARDING.md`, `template/AUTHORING_GUIDE.md`, new subsystem-guide reference under `template/` | Task preparation, root-to-subsystem routing, design constraints, useful test references, and focused drift behavior. Establish these rules before wiring automatic use. |
| 2. Complete repo setup and activation | `skills/onboard/SKILL.md`, adapter generation in `scripts/sync-adapters.sh`, installer/helpers where needed | Root and subsystem drafts, one three-question interview, safe native entries, repeat setup, and read-only status. Highest uncertainty: existing instruction configurations across three clients. |
| 3. Verify file operations and distributions | `scripts/test-install.sh`, `scripts/validate-package.sh`, generated bundles and plugin directory | Preserve existing content, handle conflicts and partial setup, and keep every shipped copy current. |
| 4. Prove everyday behavior and document it | New evaluation fixtures/results, `README.md`, installation/team guides, site docs | Fresh-session evidence for all three clients, a short setup example, and accurate compatibility claims. |
| 5. Prepare the release | `CHANGELOG.md`, plugin manifests, release package | Set plugin version to 1.3.0 after acceptance. Validate generated artifacts and the packaged install paths. Publishing remains a separate action. |

Prefer one end-to-end prototype through all three clients before expanding the documentation or introducing helpers. It should expose activation problems early.

## Release evidence

### Deterministic checks

Deterministic tests cover installer and shared helper discovery/write behavior: existing files, repeat operations, partial state, conflicts, managed-entry removal, and preservation of user text. Validate distribution of the new guide reference and any helper-managed links. Retain coverage for existing adapters. Conversational setup, subsystem selection, and actual root/subdirectory launch behavior need recorded client runs; file-operation tests alone cannot establish those outcomes.

Use the repository's existing checks, extending their assertions where setup behavior changes:

```bash
scripts/sync-adapters.sh --check
bash scripts/validate-package.sh
bash scripts/test-install.sh
bash scripts/package-plugin.sh
bash scripts/sync-plugin-directory.sh --check
shellcheck install.sh scripts/*.sh
claude plugin validate --strict .
mkdocs build --strict
```

Also run the applicable workflow checks and packaged-plugin validation from CI. If shared changes affect MCP bundles, run `npm ci`, `npm run typecheck`, `npm test`, and `npm pack --dry-run` from `mcp/`.

### Behavioral checks

Use fresh sessions with ordinary task prompts that do not mention Mentor. A minimum acceptance matrix is five scenarios in each of the three clients, for 15 fresh task sessions, plus their setup transcripts:

1. A coding change where the repo's design constraint rules out a plausible generic implementation.
2. A task with a stale subsystem claim or moved source anchor and an affected root routing entry. Confirm that the proposed maintenance update covers both documents.
3. A small isolated task where broad scanning is unnecessary.
4. Setup in an existing repo, then a fresh-session task confirming that the map and original instructions both remain useful.
5. A task that requires a particular subsystem guide, with a plausible but inappropriate pattern documented in a sibling subsystem. Confirm selective reading, correct scope, and appropriate handling of cross-subsystem boundaries.

Include a small repository and a repository with multiple subsystems. Record exact client/model versions, source commits, configuration, prompts, complete traces, context reads, user interventions, and task outcomes.

Before running, define the expected constraint, relevant source, acceptable implementation, and verification for each task. Release blockers include missing automatic context use, violating the designated design constraint, choosing the wrong subsystem guidance, presenting a stale claim as verified, or overwriting unrelated instructions. Investigate failures rather than averaging them into an aggregate score. Fifteen sessions are acceptance evidence, not a reliability estimate.

For any improvement claim, compare with a source-capable baseline using the same model, repository revision, task, and tool access. Keep existing non-Mentor instructions in both conditions. Preserve full traces and report setup cost, extra context reads, correctness, and repeated user corrections. Freeze the rubric and repeat the comparison before making a broad effectiveness claim. Leave the historical scorecard intact.

## Remaining decisions and risks

- Important subsystem selection and the proposed three-guide initial budget need validation: shallow guides miss nuance, while exhaustive generation delays first use and increases maintenance. Prototype selective guide creation in a repository with multiple subsystems and record uncovered areas.
- Minimum supported client versions and exact tested surfaces must be set during the activation prototype. Documentation support alone is insufficient.
- Source cannot supply all design rationale. Setup must remain useful when the developer skips a question, without inventing an answer.
- Richer context may add overhead or distract the agent. Small-task acceptance and recorded context reads should detect that.
- No delivery-date estimate is committed. The three-client prototype should establish the remaining effort before scheduling the release.

## Evidence behind this scope

At the source baseline, the [onboard skill](../skills/onboard/SKILL.md) drafted, interviewed, and verified a map without connecting it to subsequent sessions. The [protocol](../core/mentor-protocol.md) already required current source evidence; this release extends how that behavior serves ordinary coding tasks. The [template](../template/ONBOARDING.md) already contained rationale and gotchas, and this release strengthens their use and specificity.

The [installer regression suite](../scripts/test-install.sh) checks file behavior. The [existing scorecard](../evaluation/SCORECARD.md) records the limitations of the historical evaluation. Neither establishes fresh-session automatic use in the proposed release.

The scoping pass inspected repository sources, GitHub release/main/issue state, and the official client documentation linked above. See the results linked at the top for subsequent implementation checks; the scope itself is not evidence that acceptance has passed.
