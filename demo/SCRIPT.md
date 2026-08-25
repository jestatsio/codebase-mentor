# Demo Script — Source-Grounded Codebase Mentor

> **Total target runtime:** ~5 minutes  
> **Format:** Screen recording with voiceover. Three clips, each self-contained but designed to cut together.
>
> Works with any agent that runs the skill — Claude Code, Codex, Cursor, or IBM Bob (where this demo was first recorded). Below, "the agent" means whichever one you're recording.

---

## Pre-recording checklist

Before you hit record on any clip:

- [ ] Agent session is **fresh** (no prior conversation in context)
- [ ] Terminal font size ≥ 16pt, line width ~110 chars — readable at 1080p
- [ ] `data-api` source clone is accessible at a path the agent can read
- [ ] The codebase-mentor skill is installed (e.g. `~/.claude/skills/codebase-mentor/SKILL.md` for Claude Code)
- [ ] `onboarding/stargate-jsonapi/ONBOARDING.md` is in scope for Clips 2 and 3 (place it at the root of the session's working directory, or point the agent to it explicitly)
- [ ] Verify Section 3 of `onboarding/stargate-jsonapi/ONBOARDING.md` contains the deliberately inaccurate sort-validation claim (the blockquote after the main lifecycle description) — needed for the Clip 2 refusal scene
- [ ] Microphone level tested; no background noise

## Recording-day fallback envelope

Agent responses are non-deterministic. If a clip does not produce the expected verdict on the first take:

**Clip 2 (the refusal):** If the agent confirms the stale claim rather than refuting it, prompt: *"Please check the source — specifically `FindOneCommandResolver.resolveCollectionCommand()` — and verify where `sortClause.validate()` is actually called."* This gives the skill's Reconcile mode the anchor it needs.

**Clip 3 Part B (Change Guide):** If the response is a prose description rather than a numbered checklist, prompt: *"Can you give me that as an ordered checklist of files and methods to touch?"* The content will be the same; the format may differ between runs.

**If a full take fails:** Re-run in a fresh session (context accumulation can suppress tool calls in long sessions). Do not patch together responses from different sessions — the source-read tool calls are the evidence trail.

---

## Clip 1 — The Gap (1:00–1:15)

**What this clip shows:** The baseline problem. A generic agent answering T4 with no skill, no source, no doc — and producing the exact wrong answer.

**Voiceover tone:** Matter-of-fact. You're not mocking the tool; you're setting up the contrast.

### Setup (do not record)

Open a fresh agent session. Do **not** install or activate the codebase-mentor skill. Do not provide any source or doc.

### Shot sequence

**[RECORD]**

*Voiceover as you type the question:*
> "Here's the starting point. A generic agent — no skill, no source. A junior developer walks in with a real design question."

Type and send:
```
I want to share some logic between a collection operation and a table operation to avoid code duplication. Is that a good idea?
```

Wait for the response. The agent will recommend sharing, mention the base `Operation<SchemaT>` interface, and give implementation suggestions.

*Voiceover over the response:*
> "Reasonable-sounding answer. Mentions the base interface, suggests utility classes, talks about composition over inheritance. A junior developer would follow this — and create exactly the bug the team has seen before."

**[PAUSE for 2 seconds]**

*Voiceover:*
> "The problem: collections use a shredded denormalized schema with fixed Cassandra columns. Tables map one-to-one to CQL. Sharing concrete operation code silently breaks both. The answer isn't 'do it carefully' — it's a flat no, for specific technical reasons. A generic agent doesn't know that. It can't."

**[CUT]**

---

## Clip 2 — The Refusal (1:30–1:45)

**What this clip shows:** The agent correcting a deliberately stale claim in the ONBOARDING.md — citing the source file that contradicts it. This is the "almost nobody demos a confident evidenced no" moment.

**Voiceover tone:** Calm and precise. Emphasise that the agent isn't just refusing — it's citing source.

### Setup (do not record)

- Open a fresh agent session with the codebase-mentor skill active and `onboarding/stargate-jsonapi/ONBOARDING.md` in scope.
- Have the `data-api` source readable.
- Confirm the inaccurate sort-validation claim is present in Section 3 of `onboarding/stargate-jsonapi/ONBOARDING.md` (the blockquote beginning "According to the API documentation, sort options are validated...").

### Shot sequence

**[RECORD]**

*Voiceover:*
> "Now with the skill and the doc. Same session setup a team would use day-to-day."

Type and send:
```
The ONBOARDING.md says sort options are validated in SortClause.validate() before the resolver runs, as a pre-check in the processor pipeline. Is that still accurate?
```

Wait for the response. The skill's Reconcile mode will:
1. Extract the claim and the symbol `SortClause.validate()`
2. Open `FindOneCommandResolver.java` in source
3. Locate `resolveCollectionCommand()` and find that `sortClause.validate()` is called *inside* the resolver method, not before it
4. Return a **Stale** verdict

*Voiceover as the agent reads the source (show the tool calls):*
> "Watch what happens. The agent opens the source — not a cached index, not pre-training. The actual current file."

*Voiceover over the Stale verdict:*
> "Verdict: Stale. The ONBOARDING.md claim is wrong — and the agent says so, cites the method, explains the discrepancy. This is the accuracy contract working. Source is the truth; the doc is the map. When they disagree, source wins."

**[PAUSE for 2 seconds]**

*Voiceover:*
> "Almost nobody demos a confident, evidenced 'no'. This matters more than the yes case — a stale doc that an AI agent confidently confirms is worse than no doc at all."

**[CUT]**

---

## Clip 3 — The Answer (2:00–2:30)

**What this clip shows:** The full T4 contrast back-to-back, then a Change Guide run on T1. This is the headline result.

**Voiceover tone:** Slightly warmer here — this is the payoff.

### Part A — T4 with skill + doc (~1:00)

**Setup (do not record):** Same session as Clip 2, or a fresh session with skill + doc active.

**[RECORD]**

*Voiceover:*
> "Same question that opened the demo. Now with the skill and the ONBOARDING.md."

Type and send:
```
I want to share some logic between a collection operation and a table operation to avoid code duplication. Is that a good idea?
```

Wait for the response. The agent will:
- State a clear "No"
- Cite Section 7 of the ONBOARDING.md (Known Gotchas)
- Explain the shredded column schema vs CQL column split
- Name the failure modes: `ClassCastException`, silent no-op
- Reference `DocumentShredder.shred()` as a concrete example

*Voiceover:*
> "Flat no. With the precise technical reason — shredded columns versus CQL columns. With the failure mode — ClassCastException, or a silent wrong-path CQL INSERT. A developer reading this knows exactly what would break. They don't need to go find a senior engineer."

**[PAUSE]**

*Voiceover:*
> "That answer is not in the source. You can read every file in the codebase and never find a comment that says 'don't share this.' The ONBOARDING.md is where the why lives."

### Part B — Change Guide T1 (~1:00)

**[RECORD — continue same session or open fresh with skill + doc]**

*Voiceover:*
> "Now a change task. A developer needs to add a new sort type."

Type and send:
```
I need to add a new sort type to the Data API. Where do I start?
```

Wait for the response. The agent will follow Recipe B from the ONBOARDING.md and produce an ordered five-step checklist:
1. Extend `SortClauseUtil`
2. Add branch in `FindOneCommandResolver.resolveCollectionCommand()`
3. Add factory method on `FindCollectionOperation`
4. Update `SortClause.validate()`
5. Update `MeteredCommandProcessor.getVectorTypeTag()`

*Voiceover as the checklist appears:*
> "Five ordered steps. Every step names the exact class and method to touch. Step 2 even notes that `FindCommandResolver` needs the same branch if the sort applies to multi-document find — not just findOne. Step 5 catches the metrics tag that's easy to forget."

*Voiceover at end:*
> "A junior developer could open those files and follow this. No architecture walkthrough required. That's the break-even: one to two new hires in, and the 2–4 hour authoring cost has paid for itself."

**[CUT]**

---

## Suggested edit / cut order

If you're producing a single 5-minute video:

1. **0:00–1:10** — Clip 1 (the gap): intro voiceover + Arm 1 T4 response
2. **1:10–1:20** — Title card: "Source-Grounded Codebase Mentor"
3. **1:20–2:45** — Clip 2 (the refusal): skill + doc activated, stale claim correction
4. **2:45–5:00** — Clip 3 Part A (T4 with doc) + Part B (Change Guide T1)
5. **5:00–5:10** — End card: evaluation results (1.3 → 3.5 → 4.7, delta +1.2)

---

## End card text

> **Evaluation results (5 tasks × 3 criteria × 3 arms)**
> Arm 1 — Generic agent: **1.3 / 5**
> Arm 2 — Skill + source, no doc: **3.5 / 5**
> Arm 3 — Skill + source + ONBOARDING.md: **4.7 / 5**
> Delta (Arm 2 → Arm 3): **+1.2**
> *(Author-scored against pre-written rubric. Raw outputs at `evaluation/SCORECARD.md`.)*
>
> Source is the truth. ONBOARDING.md is the map.

---

## Voiceover script (continuous read-through)

For a single take or for review before recording:

---

*[Over Clip 1 setup]*
Here's the starting point. A generic agent — no skill, no source. A junior developer walks in with a real design question.

*[After Arm 1 T4 response]*
Reasonable-sounding answer. Mentions the base interface, suggests utility classes, talks about composition over inheritance. A junior developer would follow this — and create exactly the bug the team has seen before. The problem: collections use a shredded denormalized schema with fixed Cassandra columns. Tables map one-to-one to CQL. Sharing concrete operation code silently breaks both. The answer isn't "do it carefully" — it's a flat no, for specific technical reasons. A generic agent doesn't know that. It can't.

*[Opening Clip 2]*
Now with the skill and the doc. Same session setup a team would use day-to-day.

*[As the agent reads the source in Clip 2]*
Watch what happens. The agent opens the source — not a cached index, not pre-training. The actual current file.

*[Over the Stale verdict in Clip 2]*
Verdict: Stale. The ONBOARDING.md claim is wrong — and the agent says so, cites the method, explains the discrepancy. This is the accuracy contract working. Source is the truth; the doc is the map. When they disagree, source wins. Almost nobody demos a confident, evidenced "no". This matters more than the yes case — a stale doc that an AI agent confidently confirms is worse than no doc at all.

*[Clip 3 Part A — same T4 question with doc]*
Same question that opened the demo. Now with the skill and the ONBOARDING.md. Flat no. With the precise technical reason — shredded columns versus CQL columns. With the failure mode — ClassCastException, or a silent wrong-path CQL INSERT. A developer reading this knows exactly what would break. They don't need to go find a senior engineer. That answer is not in the source. You can read every file in the codebase and never find a comment that says "don't share this." The ONBOARDING.md is where the why lives.

*[Clip 3 Part B — Change Guide T1]*
Now a change task. A developer needs to add a new sort type. Five ordered steps. Every step names the exact class and method to touch. Step 2 even notes that FindCommandResolver needs the same branch if the sort applies to multi-document find. Step 5 catches the metrics tag that's easy to forget. A junior developer could open those files and follow this. No architecture walkthrough required. That's the break-even: one to two new hires in, and the 2–4 hour authoring cost has paid for itself.
