---
hide:
  - navigation
  - toc
---

<div class="mentor-hero" markdown>

<img class="mentor-mark" src="assets/logo.png" alt="Codebase Mentor logo: an open book with code brackets and a guiding path" width="136" height="136">

<p class="mentor-eyebrow">CODEBASE MENTOR <span>BY JESTATS</span></p>

# New codebase.<br>A clearer way in.

Understand the architecture. Find the right place to change it.<br>
Ask your coding agent for answers grounded in the source it actually reads.

[Get started](install.md){ .md-button .md-button--primary }
[View on GitHub](https://github.com/jestatsio/codebase-mentor){ .md-button }

<p class="mentor-caption">Claude Code · Codex · IBM Bob · Open skills<br>No extra API key or service needed for skills.</p>

</div>

<div class="mentor-grid" markdown>

<div class="mentor-card" markdown>

### Find your bearings

“How does this request reach the database?” Follow an execution path with links to the files and symbols that matter.

</div>
<div class="mentor-card" markdown>

### Plan your next change

“Where do I add a new endpoint?” Find the closest working example, relevant tests, and the gotchas your team knows.

</div>
<div class="mentor-card" markdown>

### Check what changed

“Is our onboarding doc still true?” Compare its claims with current source and get a report of drift and missing evidence.

</div>

</div>

## Start with one question

Install for [your agent](install.md), open any repository, and paste:

```text
Use Codebase Mentor to trace one important execution path in this repo.
Explain it to a new contributor. Cite the files and symbols you read,
and flag anything you cannot verify.
```

You can start without an `ONBOARDING.md`. The mentor works from source. When you want to capture the design decisions and pitfalls source does not explain, ask the **onboard** skill to [draft your team's map](authoring.md).

## Install where you already work

The native plugins are available through **JEStats Plugins**, hosted at `jestatsio/screamingfrog-plugin`.

=== "Claude Code"

    Run inside Claude Code:

    ```text
    /plugin marketplace add jestatsio/screamingfrog-plugin
    /plugin install codebase-mentor@jestats-plugins
    ```

=== "Codex"

    Run with a current Codex CLI:

    ```bash
    codex plugin marketplace add jestatsio/screamingfrog-plugin
    codex plugin add codebase-mentor@jestats-plugins
    ```

    Or add `jestatsio/screamingfrog-plugin` in the Codex app's plugin interface and choose **Codebase Mentor** from **JEStats Plugins**.

=== "IBM Bob"

    From the repository you want to understand:

    ```bash
    curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent bob --project
    ```

    Installs both skills in `.bob/skills/`.

[All installation options, updates, and troubleshooting →](install.md)

Already using a standalone marketplace or direct skills? Follow [switching installation methods](install.md#switching-installation-methods) to keep one copy per agent.

## The doc is the map. Source is the truth.

A short `ONBOARDING.md` points your agent toward the right code and records the context your team cares about. The mentor protocol asks it to read those anchors, verify behavior, and distinguish facts from unresolved questions.

<div class="mentor-evidence" markdown>

**Every architecture or change-guidance claim must be backed by a symbol or file read in the current session.**

Missing evidence should be visible. A stale doc should be corrected with evidence. A proposed new symbol should be clearly labeled as a proposal.

</div>

These are instructions to your agent, not a guarantee of correctness. Review the cited source before acting. The [original case study](evaluation.md) explains what was evaluated and its limits.

## Built to share with your team

- [Create an onboarding map](authoring.md) with seven concise sections and a named owner.
- [Roll it out](team-setup.md) through native plugins or committed project skills.
- [Review real examples](examples.md) from services, libraries, and a workflow application.
- [Catch doc drift in CI](ci.md) with an optional scheduled scan.

<div class="mentor-signoff" markdown>

An open source tool from [JEStats](https://jestats.io). Created by [Eric Hare](https://github.com/erichare). MIT licensed.

</div>
