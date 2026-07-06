---
name: source-audit
description: Bidirectional audit of the source↔compiled gap. Mode 1 (decompile direction): classify each artifact's Band-A method as sourced / divergent / orphaned / pure-glue against PRINCIPLES.md — finds what to lift from compiled artifacts into source. Mode 2 (compile direction): for each agent-design-relevant PRINCIPLES.md entry, check which artifacts should implement it but don't — finds what to apply from source into compiled artifacts. Default: run both modes and report together. Step 1 of the lift loop; shipping an orphan is /add-principle.
allowed-tools:
  - Bash
  - Read
  - Agent
---

# Source audit (bidirectional source↔compiled gap)

Audit the gap between framework **source** (`PRINCIPLES.md`) and **compiled artifacts**
(agents, skills, commands, `CLAUDE.md`) in both directions:

- **Mode 1 — decompile direction** (artifacts → source): find Band-A methods that live only in
  artifacts and should be lifted into `PRINCIPLES.md`.
- **Mode 2 — compile direction** (source → artifacts): find `PRINCIPLES.md` entries that should
  shape existing artifacts but don't yet.

Default: run both. Either mode can be requested alone by naming it in the prompt.

---

## Inputs

- **target** — one surface per run: a directory (`.claude/agents`, `.claude/skills`,
  `.claude/commands`) or a file (`CLAUDE.md`).
- **source** — default: this framework's `PRINCIPLES.md` at the plugin root — locate it
  **read-only** with `bin/principles-repo.sh path`. Or the user names their own source doc.

---

## Step 1 — Read both sides

Run in parallel:

1. **Read the source** (`PRINCIPLES.md`) in full. Note every `###` entry — these are the
   dedup baseline for Mode 1 and the conformance checklist for Mode 2.
2. **Read the target** artifacts in full. List files, then read each.

---

## Mode 1 — Decompile direction (artifacts → source)

*Find Band-A methods that live only in artifacts and should be lifted into source.*

### Band classification

For each artifact, classify its content into three bands (judge Band A only):

- **Band A** — portable, environment/service-agnostic method (survives moving to another org).
- **Band B** — service bindings (Jira / GitHub / Notion / Slack / `gh` / MCP).
- **Band C** — harness/workspace wiring (repo paths, allowlist shapes, `scratch/`, protocol step
  numbers, orchestration of specific named agents/commands).

### Per-artifact verdict (Band A only)

- **sourced+conformant** — core method maps to a named source entry.
- **sourced-but-divergent** — maps but extends/diverges; name the entry + describe the divergence.
- **orphaned** — real portable method, no source entry; state it in one sentence.
- **borderline** — some portable method but the counterfactual-absence gate is genuinely
  ambiguous (obvious once stated, or mostly rhymes an existing entry); flag for human judgment.
- **pure-glue** — negligible Band A (mostly Band B/C orchestration); excluded from denominator.
- **platform-fact** — the text describes a structural impossibility enforced by the
  harness/runtime (e.g. a tool absent from the agent's `tools:` list, a runtime constraint),
  not a behavioral choice the model could make. Excluded from the lift worklist; the artifact
  is documenting reality, not enforcing a rule.
- **hook-covered** — the pattern is already intercepted by a harness hook that auto-handles
  the case and tells the agent what to do (e.g. a PostToolUse hook that saves large MCP
  responses to `scratch/` and returns a `Read(...)` pointer). The artifact is documenting
  what the hook does; the hook is the enforcement mechanism. Excluded from the lift worklist.

**Discipline:** only call something sourced/redundant if you can **name** the covering entry
("vaguely similar" ≠ covered). Apply the **counterfactual-absence gate** — if removing a
candidate wouldn't bite because an entry already covers it, it's not a lift; if only *part* is
uncovered, note that the lift should **reference** the covering entry, not restate it.

**Platform-fact gate** — before calling something orphaned, ask: *"If this rule were removed
from the artifact, could the model violate it?"* If no (the harness makes it structurally
impossible), tag it `platform-fact` and exclude it from the lift worklist. A rule repeated
across many artifacts can still be a platform fact — frequency of documentation ≠ behavioral
rule.

**Hook-covered gate** — before calling something orphaned, check whether a hook already
intercepts the pattern at the harness level and provides the fix inline (e.g. the denial
message of a PreToolUse hook, or a PostToolUse hook that rewrites the response). If yes,
tag it `hook-covered` and exclude it from the lift worklist — the hook is the mechanism, not
the doc. Check `.claude/hooks/` (or equivalent) before concluding a repeated pattern is
undocumented.

### Mode 1 output

(1) Table of orphaned / divergent / borderline only (just count sourced+conformant and pure-glue).
(2) Aggregate counts + denominator (total − pure-glue).
(3) **Lift worklist** ranked most-portable-first: each with a target source section and any
⚠️ entangled flag (Band A fused with Band C — still lift, but needs careful manual pass).
(4) Already-sourced note: which artifact maps to which entry (auditable dedup).

---

## Mode 2 — Compile direction (source → artifacts)

*Find PRINCIPLES.md entries that should shape existing artifacts but don't yet.*

### Step 2a — Filter to agent-design-relevant entries

Not every principle governs how artifacts should be built. Filter `PRINCIPLES.md` to entries
that carry **design implications for agents, skills, or commands**. The three signal categories:

1. **Agent behavior rules** — principles an agent should follow in its own operation
   (e.g. "Advisory role boundary for analysis agents", "Don't punt the homework onto the consumer",
   "Pre-flight read before mutating a configured system").
2. **Construction patterns** — method patterns that describe how to build an automation
   (e.g. "Conform new components to the system's type taxonomy", "Tiered resolution: cache first",
   "Coverage-gap analysis against intent axes").
3. **Source/compiled architecture rules** — how artifacts should relate to source
   (e.g. "Durable lessons land in the source", "Layer the source by purpose").

Discard discipline rules that govern the *human/session level* (Fact discipline, Scope discipline,
Abbreviation discipline) — they belong in `CLAUDE.md`, not in agents.

These three categories are the audit's **intent axes** — track per-category gap counts during
Step 2b to populate the coverage matrix in the output.

### Step 2b — Check each filtered entry against the target artifacts

For each filtered entry, scan the artifacts and ask:
*Should any artifact here implement this principle — and does it?*

A principle "applies" to an artifact when the artifact's job brings the principle's domain into
play. An artifact that never mutates anything doesn't need the pre-flight-read principle; an
agent that analyses and advises does need the advisory-role-boundary principle.

Verdicts per (entry, artifact) pair:

- **applied** — artifact already reflects the principle. The conformance bar depends on the entry's type marker:
  - `[rule]` — the behavioral pattern is present in the artifact's steps or rules.
  - `[method]` — the method's steps are **executed** and their results appear in the output format; merely labelling the concept ("this is advisory") or citing the principle by name is not sufficient — check that each step of the method produces visible output.
  - `[taxonomy]` — the full classification system is enumerated and applied; a partial or referenced taxonomy is a gap.
- **gap** — artifact should reflect the principle but doesn't; state what's missing in one sentence.
- **not-applicable** — principle's domain doesn't touch this artifact's job.

### Mode 2 output

(1) Filter summary: how many PRINCIPLES.md entries are agent-design-relevant out of total.
(2) **Conformance gap table**:

| Principle entry | Artifact | Verdict | What's missing |
|---|---|---|---|
| {entry name} | {artifact name} | gap / applied / n/a | {one sentence if gap} |

(3) **Apply worklist** ranked most-impactful-first: each gap with the artifact to update and the
specific change implied by the principle.

---

## Step 3 — Combined output and next actions

```markdown
# Source Audit: {target}

## Mode 1 — Lift worklist (artifacts → source)

### Findings
| Artifact | Verdict | Notes |
|---|---|---|
| {name} | orphaned / divergent / borderline / sourced / pure-glue / platform-fact / hook-covered | {one line} |

**Counts**: {orphaned} orphaned, {divergent} divergent, {borderline} borderline,
{sourced} sourced+conformant, {glue} pure-glue / {denominator} auditable

### Orphan / Divergent Worklist (ranked)
1. {artifact} — {Band A summary} → target section: {PRINCIPLES.md §N} [⚠️ entangled?]

*(If no orphaned / divergent findings: state explicitly — "No findings — all artifacts sourced+conformant." Never leave the worklist empty.)*

## Mode 2 — Apply worklist (source → artifacts)

### Filter
{N} of {total} PRINCIPLES.md entries are agent-design-relevant.

### Coverage matrix

| Intent axis | Filtered entries | Gaps found | Coverage |
|---|---|---|---|
| Agent behavior rules | {count} | {count} | none / partial / full |
| Construction patterns | {count} | {count} | none / partial / full |
| Source/compiled architecture rules | {count} | {count} | none / partial / full |

### Conformance gaps
| Principle | Artifact | What's missing |
|---|---|---|
| {entry} | {artifact} | {gap description} |

### Apply Worklist (ranked)
1. {artifact} — missing {principle}: {what to add}
   **Pain point**: {what breaks or degrades without it; which intent axis it underserves}
   **Gate** — Context: {in play?} | Probability: {near-zero / low / real} | Consequence: {advisory / meaningful / severe}
   **Verdict**: act / skip / defer — {one-sentence reason}

*(If no gaps: state explicitly — "No findings — all principles applied." Never leave the worklist empty.)*

## Recommended next steps
1. {first action} — {why first}
2. {second action} — {why second}
```

---

## Step 4 — Trust-but-verify, then act

Both modes are **advisory**. Re-check each finding before acting:

- **Mode 1 orphans/divergents** → add survivors to `LIFT.md`'s ①/②/③ buckets; ship each
  via `/add-principle`; record skips with reasons.
- **Mode 2 gaps** → the Apply Worklist carries a three-axis gate verdict per item; act on
  **act** verdicts, record reasons for **skip**/**defer**. If the gate is absent for any item,
  run it now across three axes:
  1. **Context** — is the artifact in a position where this principle's domain is in play?
  2. **Probability** — how likely is the gap to manifest in practice? Near-zero (trusted input,
     empirically never triggered) → skip.
  3. **Consequence** — what degrades or breaks? Advisory-only / recoverable → deprioritize;
     silent failure or propagated misinformation → act.

  Act when probability is real AND consequence is meaningful. Record every skip with a reason —
  a silent skip is indistinguishable from an overlooked finding.

Entangled orphans still lift — the method core usually abstracts cleanly once the Band C wiring
is generalized to **e.g.**; flag them so the decompile gets a manual pass, not a mechanical move.
