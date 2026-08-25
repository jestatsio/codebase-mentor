# ONBOARDING.md — [PROJECT NAME]

<!--
  FILL-IN INSTRUCTIONS
  ────────────────────
  Replace every [PLACEHOLDER] and <!-- TODO: ... --> marker with real content.
  Use symbol anchors throughout — class names, method names, interface names.
  Do NOT use line numbers; they rot with every edit. Symbol names survive.
  Target length: 400–800 words total. Brevity beats completeness.
  See template/AUTHORING_GUIDE.md for section-by-section guidance and worked examples.
-->

---

## Document Owner

<!-- TODO: Name the person responsible for keeping this document accurate.
     Include their team and a review cadence. This is non-optional.
     Example: "Owner: Jane Smith (Data Platform). Reviewed every 6 months or after any
     major architectural change. Last reviewed: 2025-01." -->

**Owner:** [FULL NAME] ([TEAM NAME])
**Review cadence:** [e.g., "every 6 months, or after any major architectural change"]
**Last reviewed:** [YYYY-MM]

---

## 1 — Codebase Purpose

<!-- TODO: One to three sentences. What does this service/library do?
     Who calls it? What does it return? Avoid jargon the reader might not know yet.
     If you need to define jargon, add it to Section 4 (Domain Vocabulary) instead. -->

[PLACEHOLDER: Describe what this codebase does, who its callers are, and what it produces.
Example: "This service accepts JSON API requests from the Stargate coordinator and executes
them against an Apache Cassandra cluster, returning JSON responses. It is the sole path for
document-model and table-model operations on the cluster."]

---

## 2 — Layer Map

<!-- TODO: List the major architectural layers in order, from the API surface inward.
     For each layer, name the key class or interface that defines that layer's contract.
     Use symbol anchors — class names, not file paths or line numbers. -->

The codebase is organized into the following layers, outermost first:

| Layer | Responsibility | Key symbol |
|---|---|---|
| [LAYER NAME] | [WHAT THIS LAYER DOES] | `[ClassName or InterfaceName]` |
| [LAYER NAME] | [WHAT THIS LAYER DOES] | `[ClassName or InterfaceName]` |
| [LAYER NAME] | [WHAT THIS LAYER DOES] | `[ClassName or InterfaceName]` |
| [LAYER NAME] | [WHAT THIS LAYER DOES] | `[ClassName or InterfaceName]` |
| [LAYER NAME] | [WHAT THIS LAYER DOES] | `[ClassName or InterfaceName]` |

<!-- TODO: Add or remove rows. Five layers is typical; some codebases have three, some have seven. -->

---

## 3 — Execution Lifecycle

<!-- TODO: Trace one representative execution path (request, job run, batch) from entry to completion.
     Name the method and class at each hop. Do NOT paraphrase the code — name it.
     A new engineer should be able to follow this walkthrough and find each step in source.
     For a pipeline/job-based codebase, trace one full job run or one record through the stages. -->

**Representative execution:** [OPERATION NAME — e.g., "findOne", "daily sync run", "POST /items", "processOrder"]

1. **Entry:** `[EntryClass].[entryMethod]()` receives the request and [WHAT HAPPENS HERE].
2. **[LAYER NAME]:** `[ClassName].[methodName]()` [WHAT HAPPENS — one clause].
3. **[LAYER NAME]:** `[ClassName].[methodName]()` [WHAT HAPPENS — one clause].
4. **[LAYER NAME]:** `[ClassName].[methodName]()` [WHAT HAPPENS — one clause].
5. **[LAYER NAME]:** `[ClassName].[methodName]()` [WHAT HAPPENS — one clause].
6. **Response:** [WHAT IS RETURNED AND TO WHOM].

<!-- TODO: Add steps as needed. Each step must name a real class and method. -->

---

## 4 — Domain Vocabulary

<!-- TODO: Define terms that have a project-specific meaning different from their
     everyday meaning, or that a new engineer would need to know to read the source.
     Keep each definition to one or two sentences. Link to the key class if there is one. -->

| Term | Definition |
|---|---|
| **[Term]** | [Definition. Include the key class name if one embodies this concept.] |
| **[Term]** | [Definition.] |
| **[Term]** | [Definition.] |
| **[Term]** | [Definition.] |
| **[Term]** | [Definition.] |

<!-- TODO: Aim for 5–10 terms. More than 15 is a sign the section is becoming a glossary
     rather than a vocabulary; cut the terms a new engineer will look up themselves. -->

---

## 5 — Common Change Recipes

<!-- TODO: List 3–5 common change tasks. For each, provide an ordered checklist of
     classes/methods to touch, in the order they should be touched.
     Write these as imperative steps: "Add X to Y", "Implement Z in W".
     Use symbol anchors. Do NOT explain the implementation — point to where it goes. -->

### Recipe A — [TASK NAME, e.g., "Add a new command"]

1. [IMPERATIVE STEP — e.g., "Create a new `[CommandName]` class implementing `[InterfaceName]`"]
2. [IMPERATIVE STEP — name the class/method to update]
3. [IMPERATIVE STEP — name the class/method to update]
4. [IMPERATIVE STEP — name the class/method to update]

### Recipe B — [TASK NAME, e.g., "Add a new sort type"]

1. [IMPERATIVE STEP]
2. [IMPERATIVE STEP]
3. [IMPERATIVE STEP]
4. [IMPERATIVE STEP]

### Recipe C — [TASK NAME, e.g., "Add a new error code"]

1. [IMPERATIVE STEP]
2. [IMPERATIVE STEP]
3. [IMPERATIVE STEP]

<!-- TODO: Add Recipe D, Recipe E etc. as needed.
     If a recipe has more than 8 steps, consider splitting it into two recipes. -->

---

## 6 — High-Signal Files by Question Type

<!-- TODO: For each common question a new engineer might ask, name the class (or small
     set of classes) most likely to answer it. Do NOT list every file in the package —
     that is noise. Pick the one or two best entry points per question. -->

| Question type | Where to start |
|---|---|
| "How does [COMMON OPERATION] work?" | `[ClassName].[methodName]()` |
| "Where does [CONCEPT] live?" | `[ClassName]` |
| "How do I handle [ERROR TYPE]?" | `[ClassName]` |
| "What controls [BEHAVIOR]?" | `[ClassName]` |
| "Where is [FEATURE] configured?" | `[ClassName or config file symbol]` |

<!-- TODO: Add rows. The goal is to answer the five questions a new engineer asks most
     often in their first two weeks, not to catalogue the entire codebase. -->

---

## 7 — Known Gotchas

<!-- TODO: This is the most important section. List invariants and negative-space rules
     that are NOT visible from reading the source — things a senior engineer would mention
     in a code review but that aren't captured in a comment or test.

     Format each gotcha as: what the rule is, why it exists, what breaks if you violate it.
     If there is a key class that enforces or embodies the rule, name it.

     Do NOT just list "be careful with X". Explain the consequence. -->

### [Gotcha title — e.g., "Renaming a resolver class breaks saved client flows"]

**Rule:** [STATE THE INVARIANT — what must never change, or what must always be done together]
**Why:** [EXPLAIN THE REASON — one or two sentences]
**What breaks:** [NAME THE CONSEQUENCE — be specific]

---

### [Gotcha title — e.g., "Collection and table paths are intentionally separate"]

**Rule:** [STATE THE INVARIANT]
**Why:** [EXPLAIN THE REASON]
**What breaks:** [NAME THE CONSEQUENCE]

---

### [Gotcha title — e.g., "Task-level retry and driver-level retry are independent"]

**Rule:** [STATE THE INVARIANT]
**Why:** [EXPLAIN THE REASON]
**What breaks:** [NAME THE CONSEQUENCE]

---

<!-- TODO: Aim for 3–6 gotchas. If you can't think of any, interview a senior engineer
     who has reviewed PRs on this codebase — ask "what mistakes do you keep catching in review?"
     That answer is this section. -->
