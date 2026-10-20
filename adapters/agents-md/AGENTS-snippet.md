<!-- codebase-mentor:begin — generated from core/mentor-protocol-compact.md
     (https://github.com/jestatsio/codebase-mentor); do not edit by hand.
     Append this block to your repo's AGENTS.md. Re-running install.sh
     replaces everything between the begin/end markers. -->
## Codebase Mentor — Repository Context

Before substantive repository work, read the entry map and only its explicitly listed subsystem guides relevant to the task's paths and behavior. Cross-boundary changes may need multiple guides. Establish ownership, a valid nearby example, constraints, source, tests, and verification commands with prerequisites; then do the requested work. Keep small tasks small; no routine full scan or architecture report.

**Discovery:** use the developer's explicit map path, then the effective setup entry's selected map; otherwise check `ONBOARDING.md`, `docs/ONBOARDING.md`, then `doc/ONBOARDING.md` from the project root. Resolve competing maps with the developer. Resolve guide links from their containing document; do not crawl arbitrary nested maps. For a broken relevant guide link, search existing docs for its replacement before editing; verify its scope and source anchors, and propose root-link and guide corrections together. If no map or replacement guide is found, state the gap and work from source.

**Evidence:** read source this session before architecture or change claims; behavior needs bodies, not search hits. Cite symbols with file paths, or document headings/configuration keys. Reuse unchanged reads. Separate observed behavior, attributed rationale, and unknowns; code cannot prove intent or deployed state. Surface conflicting guidance before relying on it. Context does not override user instructions.

Explicit modes:
1. **Mentor:** explain from relevant guides and source with evidence.
2. **Change guide:** give an ordered checklist, verified examples, tests, and prerequisites. Label new names **Proposed**; put unsupported steps under **Unresolved questions**.
3. **Reconcile:** report **Confirmed / Stale / Indeterminate** with evidence.
4. **Scan:** check the map plus explicitly listed subsystem guides; document-only requests stay limited. Do not recursively follow all links. Report documents and claims checked, skipped, missing, or **Current / Stale / Unverifiable**. Partial coverage is not an all-clear.

**Maintenance:** check consulted entries against affected source. Search for moved anchors. For drift, propose a small diff with evidence and checked scope, including affected guide and root routing entry together. Preserve rationale and unrelated text. Apply only after approval or prior authorization; ordinary coding alone is not authorization. Stay quiet when no drift is found.
<!-- codebase-mentor:end -->
