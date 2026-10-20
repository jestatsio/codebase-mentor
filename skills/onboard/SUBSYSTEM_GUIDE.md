# [SUBSYSTEM NAME] — Design and Change Guide

<!--
  Use this for a focused guide explicitly linked from the root ONBOARDING.md.
  Reuse useful existing docs instead of generating another copy. For a new guide,
  docs/mentor/<subsystem>.md is a suggested location, not a required schema.
  Keep only detail that changes implementation decisions; aim for 300–600 words.
  Read relevant source and tests before drafting. Replace placeholders with verified
  content or specific open questions. Preserve human edits on later setup runs.
-->

**Scope:** [RESPONSIBILITIES, PATHS, AND KINDS OF CHANGES]
**Outside this scope:** [NEARBY RESPONSIBILITIES OWNED ELSEWHERE; link existing guides if useful]
**Verification:** [DATE, source revision if available, and exactly which source/tests were read or run]
**Unverified:** [IMPORTANT AREAS OR CLAIMS NOT CHECKED]

## Responsibilities and boundaries

[One short paragraph describing what this subsystem owns and its entry point.]

| Boundary | Contract and evidence |
|---|---|
| [CALLER OR NEIGHBOR] | [INPUT/OUTPUT OR INVARIANT; symbol and file path; changes that require checking both sides] |

## Design constraints and rationale

### [CONSEQUENTIAL CONSTRAINT]

- **Rule and scope:** [WHAT MUST REMAIN TRUE; applicable paths, behavior, and exceptions]
- **Observed behavior:** [SOURCE/TEST SYMBOL AND FILE supporting the behavior]
- **Rationale:** [DECISION DOC AND HEADING, or DEVELOPER WHO CONFIRMED IT; use "Unknown" if unavailable]
- **Consequence:** [WHAT BREAKS IF VIOLATED; identify whether observed, tested, or attributed]
- **Open question:** [UNRESOLVED ASSUMPTION OR CONFLICT; omit if none]

<!-- Add only supported constraints. Source alone cannot establish historical intent.
     Surface conflicts between current behavior and documented decisions. -->

## Safe change pattern

**Task:** [COMMON CHANGE]
**Example:** [EXISTING SYMBOL AND FILE; why it fits this task]
**Limits:** [WHEN THIS EXAMPLE DOES NOT APPLY; misleading sibling pattern if relevant]

1. [CHANGE AT A VERIFIED EXTENSION POINT; label any new name "Proposed"]
2. [RELATED CONTRACT OR CALL SITE TO CHECK]
3. [TEST COVERING THE EXPECTED BEHAVIOR AND FAILURE CASE]

## Verification and traps

| Check | Command and working directory | Prerequisites |
|---|---|---|
| [FOCUSED TEST OR BUILD; source file defining it] | `[EXACT COMMAND]` from `[DIRECTORY]` | [TOOLS, fixtures, services; no credentials] |

**Known traps:** [SPECIFIC FAILURE MODE and evidence; omit unsupported guesses]
**Result:** [COMMANDS ACTUALLY RUN AND RESULTS, or "Commands identified from project tooling; not run"]

## Maintenance

Check this guide when [RELEVANT CONTRACT, ENTRY POINT, OR BOUNDARY] changes. If paths or scope change, review the root map's routing entry too. Propose a focused correction for approval unless already authorized; preserve rationale and unrelated text. Record checked scope without declaring unchecked areas current.
