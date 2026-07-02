---
name: lift-audit
description: Audit a set of AI-config artifacts (a .claude/agents|skills|commands directory, or CLAUDE.md) for portable methods worth lifting into the framework source — classify each artifact's Band-A method as sourced / divergent / orphaned / pure-glue against PRINCIPLES.md, apply the counterfactual-absence gate, and return a ranked lift worklist. Step 1 of the lift loop. Advisory — the caller trust-but-verifies before acting.
allowed-tools:
  - Bash
  - Read
  - Agent
---

# Lift audit (source-coverage)

Find methods that live only in an artifact and should be lifted into the framework
**source** (`PRINCIPLES.md`). This is Step 1 of the lift loop (see the project's
`LIFT.md`); shipping an orphan is `/add-principle` (Step 3).

## Inputs
- **target** — one surface per run: a directory (`.claude/agents`,
  `.claude/skills`, `.claude/commands`) or a file (`CLAUDE.md`).
- **source** — the doc to dedup against. Default: this framework's `PRINCIPLES.md`
  at the plugin root — locate it **read-only** with `bin/principles-repo.sh path`
  (unguarded; the author-mode write-guard is only for `/add-principle`). Or the
  user names their own source doc.

## Step 1 — read the source (dedup baseline)
`Read` the source doc IN FULL and note every `###` entry. An artifact whose method
already maps to an entry is **not** an orphan — this baseline is what stops
reworded twins.

## Step 2 — dispatch the audit (subagent, main thread)
Fan-out reading is noisy — dispatch a `general-purpose` subagent with the rubric
below over the target. Run this from the **main thread** (a skill that spawns must
not itself be a subagent).

**Bands (classify content; judge Band A only):**
- **Band A** — portable, environment/service-agnostic method (survives moving to
  another org).
- **Band B** — service bindings (Jira / GitHub / Notion / Slack / `gh` / MCP).
- **Band C** — harness/workspace wiring (repo paths, allowlist shapes, `scratch/`,
  protocol step numbers, orchestration of specific named agents/commands).

**Per-artifact verdict (Band-A only):**
- **sourced+conformant** — core method maps to a named source entry.
- **sourced-but-divergent** — maps but extends/diverges (name entry + divergence).
- **orphaned** — real portable method, no source entry (state it in one sentence).
- **pure-glue** — negligible portable method (mostly Band B/C orchestration);
  excluded from the denominator.

**Discipline:** default to the least-surprising verdict; only call something
sourced/redundant if you can **name** the covering entry ("vaguely similar" ≠
covered). Apply the **counterfactual-absence gate** — if removing a candidate
wouldn't bite because an entry already covers it, it's not a lift; if only *part*
is uncovered, note that the lift should **reference** the covering entry, not
restate it.

**Return:** (1) a table of orphaned/divergent/borderline only (just count the
sourced/glue majority); (2) aggregate counts + denominator (total − pure-glue);
(3) an **orphan worklist** ranked most-portable-first, each with a target source
section and any ⚠️entangled flag; (4) an already-sourced note (which artifact maps
to which entry — auditable dedup).

## Step 3 — trust-but-verify, then feed the ledger
The subagent's verdicts are **advisory**. Re-check each orphaned/divergent finding
against the source yourself before acting — a subagent audit over-/under-calls
(expect to overturn some). Then:
- add survivors to `LIFT.md`'s ①/②/③ buckets;
- ship each via `/add-principle`;
- record skips / pure-glue in the exclusion list **with reasons**.

Entangled orphans (Band A fused with Band C) still lift — the method core usually
abstracts cleanly once the wiring is generalized to **e.g.**; flag them so the
decompile gets a careful manual pass, not a mechanical move.
