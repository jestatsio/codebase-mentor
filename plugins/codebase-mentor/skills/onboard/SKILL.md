---
name: onboard
description: Set up Codebase Mentor once for a repo, draft an ONBOARDING.md and focused subsystem guides from source, check setup status, or remove managed setup instructions. Use for repo setup, onboarding drafts, and automatic context use in Codex, Claude Code, or IBM Bob.
---

# Set Up Codebase Mentor

Help agents understand the repository's design before making changes. Draft a short entry map, link useful existing docs and focused subsystem guides, and connect the selected agents to that context through their project instructions. This skill also works independently of the mentor skill.

Resolve bundled references relative to this skill's directory, never the user's repository. Before drafting, read `ONBOARDING.template.md`, `AUTHORING_GUIDE.md`, `SUBSYSTEM_GUIDE.md`, and `mentor-protocol.md`. For setup, status, or removal, also read `SETUP.md`.

## Choose the requested action

- **“Set up Codebase Mentor for this repo”:** perform the full flow below. The request authorizes local context documents and instruction entries for the selected repository and agents. Default to the current client when it is known, and state that choice. Configure other clients only when requested.
- **“Draft an ONBOARDING.md” or an explicit draft-only request:** draft and verify context without changing agent instructions. Preserve the existing generator workflow. If a map already exists and the request does not say to revise it, ask whether to improve it or scan it before writing.
- **“Is Mentor set up correctly here?”:** follow the read-only status procedure in `SETUP.md`. Do not draft, repair, create directories, or change files.
- **“Remove Mentor setup”:** remove only the selected managed instruction entries as described in `SETUP.md`. Preserve the map, subsystem guides, manual instructions, and installed skills.

Installing a skill alone does not authorize repo setup. Never change global agent settings or configure every installed client merely because it is available.

## Rules

- **Read before claiming:** read every named source artifact this session. For behavioral claims, read the relevant body or configuration, not only search matches.
- **Use durable anchors:** include symbols with file paths, or file headings and configuration keys where there are no functions or classes.
- **Keep evidence distinct:** label source-observed behavior, documented decisions, developer-confirmed rationale, and unresolved assumptions. Source alone cannot establish historical intent. Surface conflicts between documented constraints and behavior.
- **Preserve project knowledge:** reuse existing documents at their established paths. Make focused changes; do not regenerate over human edits, replace useful guides, or create a competing map.
- **Keep the entry map short:** target 400–800 words in the existing seven-section format. Move deeper detail to explicit links where useful. Existing longer maps do not need migration.
- **Declare gaps:** retain explicit TODOs for unsupported content. Attribute rationale and record verification scope and source revision when available. A draft is useful even when the developer skips the interview.
- **Bound the interview:** ask at most three targeted questions across the entire setup, including all subsystems and any setup clarifications. Do not reset the allowance for each guide or continuation. Use existing answers; never invent an answer to fit the limit.

## Step 1 — Discover the project and existing context

1. Use the source root the developer selected, otherwise the current repository root. Identify the current client or explicitly selected clients. State the project and selected clients before modifying files.
2. Inspect existing project instructions and their applicable parent and nested instructions. Follow `SETUP.md` to identify which instruction files each selected client actually uses; a familiar filename is not sufficient.
3. Check an explicitly supplied map path, existing setup pointers, and `ONBOARDING.md`, `docs/ONBOARDING.md`, and `doc/ONBOARDING.md` within the selected root. Reuse one authoritative map. If candidates conflict, explain the paths and resolve the choice before writing or activating. Do not silently choose the first map or delete the others.
4. Read the map's explicitly linked subsystem guides and relevant existing architecture, contribution, decision, and testing docs. Reuse useful documentation in place.
5. Identify project type, entry points, responsibilities, and meaningful subsystem boundaries from build files, configuration, source, and tests. Trace one representative execution path, reading each hop. For a documentation or configuration project, trace how an edit reaches its consumer.
6. Read examples of common changes and their tests. Find constraints that would make a plausible generic change wrong, such as generated sources, ordering requirements, compatibility boundaries, or different validation rules in superficially similar paths.

## Step 2 — Draft from evidence

Prepare a useful source-based draft before asking for missing rationale. Keep existing verified content; propose focused corrections to stale claims. Use the bundled root template's seven sections: purpose, layer map, execution lifecycle, domain vocabulary, common change recipes, high-signal files, and known gotchas.

For each important change recipe or constraint, include the scope, consequence, valid implementation example and its limits, relevant source and tests, and verification command with prerequisites. Verify commands against project configuration or existing docs; do not run arbitrary commands merely because an existing map lists them.

Choose important subsystems by architecture boundaries, execution paths, and likely work, not by directory count. A small repository may need no separate guides. For a larger one:

- Show which areas need deeper context and why. Reuse useful existing guides before drafting new ones.
- Draft **at most three new subsystem guides** during initial setup, using `SUBSYSTEM_GUIDE.md`. Default genuinely new guides to `docs/mentor/<subsystem>.md`; retain existing or explicitly chosen paths.
- Give each guide a focused scope, responsibilities, design constraints and attributed rationale, valid examples, change and verification steps, known traps, and cross-subsystem contracts. Avoid repeating the root overview.
- Link each guide explicitly from the root map with its relevant paths and kinds of changes. These links select useful context; they do not establish an instruction hierarchy or make a nested document override other guidance.
- List important areas not yet covered in the root map as gaps. Offer later expansion on request; do not silently exceed the initial budget or use repeated setup to expand into deferred areas. Existing guides linked in place do not count as newly drafted guides.

## Step 3 — Ask about consequential gaps

Use the available question tool or plain conversation. Show the source-based draft or a concise summary with its paths first. Ask only about gaps that could cause an incorrect implementation. Spend no more than the remaining allowance of three questions for the whole setup.

Prefer a question tied to evidence: “These two paths use different validation. Is the separation intentional, and what would break if they shared it?” Avoid a generic questionnaire when source or existing docs already supplies the answer. Ownership, review cadence, or alternate paths can remain TODOs when a design decision is more consequential.

Attribute answers to the developer. Preserve unanswered questions as TODOs. If the developer asks for no interview, continue from evidence without asking. A conflicting map choice or unsafe write must remain unresolved if it cannot be settled within the user's instructions; report the concrete next step instead of guessing.

## Step 4 — Write and verify the context

1. Write the new map, or update the authoritative map and relevant existing guides at their established locations. Replace placeholders with verified content or explicit TODOs. Review the diff to confirm human rationale and unrelated text remain intact.
2. Follow **Mode 4 — Scan** in `mentor-protocol.md` over the entry map and explicitly listed subsystem guides. Fix stale claims introduced in the draft. Report which documents and claims were checked, skipped, or unverifiable. A partial scan cannot establish that all context is current.
3. Check the root-to-guide links, scope descriptions, source anchors, and documented verification commands. Record commands actually run and their results separately from commands only found in configuration.

## Step 5 — Connect the selected agents

Skip this step for draft-only requests. Follow `SETUP.md` to add or reuse the smallest effective native instruction entry. When Python 3 is available, use the adjacent `setup_repo.py` for deterministic status and managed-file operations; otherwise follow the native file-edit procedure. The helper configures pointers only. It does not draft documentation, judge existing manual instructions, or prove client behavior.

Inspect status and existing instruction content before writing. Repeated setup must preserve the same authoritative map and guides, avoid duplicate pointers, and leave unrelated instructions untouched. Diagnose partial setup, shadowed entries, disabled rules, and malformed markers before repairing anything.

## Step 6 — Report and verify the next session

Report the project, map and guide paths, new or reused instruction entries per selected client, relevant coverage and gaps, remaining questions, and verification actually observed. Give the entry map's word count without rewriting it merely to meet the target.

Label file configuration as **configured**, **partial**, **conflicting**, or **not configured**, as appropriate. Label fresh-session use as **observed** only when a recorded fresh session actually read the relevant map and guide during an ordinary task without mentioning Mentor. Otherwise say **not yet observed**.

Provide a concrete fresh-session check: start in the selected repo, request an ordinary small change that touches a documented constraint, and check that the agent reads the relevant context, verifies it against source, preserves existing instructions, and chooses the right implementation. A session launched in a subdirectory should also be checked when that is the developer's normal workflow. File presence, plugin validation, and the current setup session do not prove automatic use.

Explain maintenance in one sentence: during ordinary work, check relevant claims and propose a focused correction for review when they drift; apply it only when the user authorizes that update. Stay quiet when no relevant drift is found. Rerunning setup can update the managed entry, and removing setup preserves the context documents.
