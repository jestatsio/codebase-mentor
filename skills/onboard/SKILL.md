---
name: onboard
description: Generate a draft ONBOARDING.md by reading current source and asking the developer for missing rationale, gotchas, and ownership. Use when asked to create, generate, or bootstrap an onboarding map for a codebase.
---

# Generate an ONBOARDING.md Draft

Create a concise map of the selected project, with source evidence for its structure and behavior. Read the three files bundled beside this SKILL.md before drafting: `ONBOARDING.template.md`, `AUTHORING_GUIDE.md`, and `mentor-protocol.md`. This skill can be installed independently of the mentor skill.

Use the source root specified by the developer, otherwise the current repository root. Check `ONBOARDING.md`, `docs/ONBOARDING.md`, and `doc/ONBOARDING.md` within that root, as well as any document path the developer supplied. If a map exists, identify it and ask whether to revise it or run a freshness scan unless the developer already made that choice. Preserve the existing location. Do not create a competing root map or overwrite human edits silently.

## Rules

- **Read before claiming:** read every named source artifact this session. For behavioral claims, read the relevant body or configuration, not only search matches.
- **Use durable anchors:** include symbols with file paths, or file headings and configuration keys where there are no functions or classes.
- **Separate facts and proposals:** verify existing anchors. Label proposed new names and cite the existing example or extension point behind the recipe.
- **Keep it short:** aim for 400–800 words. Use fewer vocabulary entries and recipes when the project is small.
- **Declare gaps:** leave an explicit `<!-- TODO: what is missing -->` for unsupported content. Attribute human-provided rationale. Do not turn it into a claim that source established.

## Step 1 — Read the project

1. Identify the project type from build files, configuration, and directory layout.
2. Find its entry points: a function, route, CLI command, workflow job, or build step.
3. Trace one representative execution path through current source, reading each hop. For a documentation or configuration project, trace how an edit reaches its consumer.
4. Identify the responsibilities along that path and the source anchors that define them. Do not impose layers that the project does not have.
5. Read existing examples of common changes. Use them to propose recipes, with unresolved dependencies called out.

## Step 2 — Draft from evidence

Follow the bundled template:

- **Purpose:** who uses the project, what it does, and what it produces.
- **Layer map:** the main responsibilities and a source anchor for each.
- **Execution lifecycle:** the traced path, with one verified anchor per hop.
- **Domain vocabulary:** the project-specific terms needed to follow the path.
- **Common change recipes:** a few ordered checklists grounded in existing examples.
- **High-signal files:** the best starting points for likely questions.

## Step 3 — Fill the human context

Use the agent's available question tool or plain conversation. Ask only for information not already supplied, grouping the questions when practical:

1. **Gotchas:** what mistakes recur in review, why the rules exist, and what breaks when violated. Include source-observable failure modes only after checking them. If none are known, leave a TODO for a senior reviewer.
2. **Ownership:** the person or team responsible, review cadence, and review date.
3. **Representative path:** whether the traced path is the one a new engineer most needs. Trace a different path if requested.

If the developer asks for a draft without an interview, keep missing context as TODOs rather than blocking or inventing answers.

## Step 4 — Write and verify

1. Write a new map to the selected project's `ONBOARDING.md`, or revise the existing map at its established location when requested. Replace template placeholders with verified content or explicit TODOs.
2. Follow **Mode 4 — Scan** in the bundled `mentor-protocol.md`. Fix stale claims in your new draft. Report unverifiable claims and incomplete coverage, and retain human-context TODOs. Never describe an incomplete scan as fully current.
3. Report the document path, word count, sections completed, remaining TODOs, and scan coverage. The developer owns the final review of rationale and gotchas.
