---
hide:
  - navigation
  - toc
---

<div class="mentor-hero" markdown>

<img class="mentor-mark" src="assets/logo.png" alt="Codebase Mentor logo: an open book with code brackets and a guiding path" width="136" height="136">

<p class="mentor-eyebrow">CODEBASE MENTOR <span>BY JESTATS</span></p>

# Your repo's design.<br>In your agent's context.

Set up once. Give your agent the design constraints, examples, and tests<br>
it needs to make changes that fit your repository.

[Get started](install.md){ .md-button .md-button--primary }
[View on GitHub](https://github.com/jestatsio/codebase-mentor){ .md-button }

<p class="mentor-caption">Claude Code · Codex · IBM Bob · Open skills<br>No extra API key or service needed for skills.</p>

</div>

<div class="mentor-grid" markdown>

<div class="mentor-card" markdown>

### Capture the important context

Draft a short repo map from source, then answer up to three questions about the design decisions source cannot explain.

</div>
<div class="mentor-card" markdown>

### Guide everyday changes

Native project instructions point agents to the relevant subsystem guide, valid examples, and constraints before substantive work.

</div>
<div class="mentor-card" markdown>

### Keep context useful

When relevant claims drift, review a focused correction. Existing documents and human rationale stay under your control.

</div>

</div>

## Set up your repository

Install for [your agent](install.md), open your repository, and ask:

```text
Set up Codebase Mentor for this repo.
```

Mentor reads existing instructions, documentation, source, and tests. It reuses or drafts an `ONBOARDING.md`, adds up to three focused guides where deeper context is missing, and connects your selected agents through small project instruction entries. It asks up to three targeted questions across the whole setup.

Then start a fresh session and ask for an ordinary change. Check that your agent reads the relevant context and verifies its claims against source. **“Is Mentor set up correctly here?”** reports configured files separately from observed use; configuration alone does not prove activation.

You can also use the mentor directly without setup or a map: **“Use Codebase Mentor to trace one important execution path in this repo.”** To [draft documents](authoring.md) without changing project instructions, ask for a draft only.

## Install where you already work

Install the native plugin directly from [Codebase Mentor’s repository](https://github.com/jestatsio/codebase-mentor), which includes the `codebase-mentor` marketplace.

=== "Claude Code"

    Run inside Claude Code:

    ```text
    /plugin marketplace add jestatsio/codebase-mentor
    /plugin install codebase-mentor@codebase-mentor
    ```

=== "Codex"

    Run with a current Codex CLI:

    ```bash
    codex plugin marketplace add jestatsio/codebase-mentor
    codex plugin add codebase-mentor@codebase-mentor
    ```

    Or add `jestatsio/codebase-mentor` in the Codex app's plugin interface and choose **Codebase Mentor** from **Codebase Mentor by JEStats**.

=== "IBM Bob"

    From the repository you want to understand:

    ```bash
    curl -fsSL https://raw.githubusercontent.com/jestatsio/codebase-mentor/main/install.sh | bash -s -- --agent bob --project
    ```

    Installs both skills in `.bob/skills/`.

[All installation options, updates, and troubleshooting →](install.md)

Already installed from `jestats-plugins` or as direct skills? Follow [switching installation methods](install.md#switching-installation-methods) to keep one copy per agent.

## The doc is the map. Source is the truth.

A short `ONBOARDING.md` points your agent toward the right source and scoped subsystem guides. It records constraints, examples, tests, and attributed rationale. The mentor protocol asks the agent to verify behavior and distinguish documented decisions from unresolved questions.

<div class="mentor-evidence" markdown>

**Architecture and change guidance require source evidence read in the current session.**

Missing evidence stays visible. Proposed maintenance changes need review unless already authorized. A small task should need only the context relevant to that task.

</div>

These are instructions to your agent, not a guarantee of correctness. Review the cited source before acting. The [original case study](evaluation.md) explains what was evaluated and its limits.

## Built to share with your team

- [Create a repo map and focused guides](authoring.md) that preserve the nuances of your design.
- [Roll it out](team-setup.md) through native plugins or committed project skills.
- [Review real examples](examples.md) from services, libraries, and a workflow application.
- [Catch doc drift in CI](ci.md) with an optional scheduled scan.

<div class="mentor-signoff" markdown>

An open source tool from [JEStats](https://jestats.io). Created by [Eric Hare](https://github.com/erichare). MIT licensed.

</div>
