---
name: review
description: Review a set of artifacts by first identifying the relationship between them, then applying the matching review shape — parity+completeness for peers that should agree, bidirectional coverage for a spec and its realization. Use when reviewing a doc set, a spec vs an implementation, a PR against its ticket, or any artifacts that should line up.
---

# Review (relationship-driven)

Pick the review by the **relationship** between what you're reviewing, then run
its shape. (Condensed from PRINCIPLES.md §5 "A review's shape follows the
relationship it checks" / "Two-axis review of an artifact set" / "Bidirectional
spec↔implementation coverage" — read those for rationale.)

## Step 1 — name the relationship
- **Peers that should agree** — same kind, same level (**e.g.** a product spec and
  its technical design; EN vs JA copy; three platforms' take on one feature) →
  **Two-axis** (below).
- **A spec and its realization** — across an abstraction gap, one must satisfy the
  other (**e.g.** requirements/AC vs the code; a design vs the built UI) →
  **Bidirectional coverage** (below).
- **A behavioral instruction file** — an always-loaded operational doc (**e.g.**
  `CLAUDE.md`) → **Three-axis** (below).
- Other relationships (sequence, containment) generate their own checks the same
  way — name what "holds" means, then check it.

Wrong shape misfires: a spec-vs-code gap is not a "missing section"; peer
divergence is not "scope-creep".

## Two-axis review (peers)
Run **both** — they catch different defects:
- **Completeness** — each artifact vs its *expected structure* (a section
  checklist), not a gut "done"; flag missing sections, stray TBDs, unanswered
  standard questions (edge/error/empty states, all paths, copy).
- **Consistency** — cross-artifact parity: agree on every decision, value, scope?
  On a conflict, **name both sides, never silently reconcile**.

## Three-axis review (behavioral instruction file)
Run **all three** — completeness and consistency catch different defects; necessity
catches rules that are already enforced elsewhere:
- **Completeness** — each section vs its expected structure; flag missing guidance,
  stray TBDs, unanswered standard questions.
- **Consistency** — sections agree with each other and with the disciplines they
  define. On a conflict, **name both sides, never silently reconcile**.
- **Necessity** — for each rule or guidance block, ask: *if this were removed, would
  the agent's behavior change?* A rule structurally enforced by the runtime, harness,
  or capability boundary is a **platform-fact** — the agent cannot violate it
  regardless of documentation. Such rules add reading weight without behavioral
  coverage and are trim candidates. Apply the enforcement-layer test: *"Could the
  agent violate this rule if the doc didn't mention it?"* If no → platform-fact →
  trim candidate.

## Bidirectional coverage (spec ↔ realization)
- **Forward (spec → change)** — every requirement maps to a concrete reference in
  the change (code, better a test); classify covered / partial / not-covered.
- **Reverse (change → spec)** — every significant hunk maps to a requirement; one
  that doesn't is a **scope-creep candidate**. Exclude noise (formatting, dep
  bumps, generated files). An empty change is never a pass.
- Evidence-matching is heuristic (a test name matching the requirement, a marker
  comment, a touched function whose docs match) — best-effort; flag the unsure.

## Output
Findings grounded in the artifacts (cite where each lives); surface every conflict
with both sides rather than resolving it silently. Keep *what's missing*
(completeness / not-covered) separate from *what doesn't line up* (consistency /
scope-creep).

**Citation format**: every artifact reference is a clickable link — `[artifact name](path)` for docs, `path:line` for specific line references. Bare paths and uncited "see X" are not acceptable.

Each finding must include a **concrete next action** — the artifact, section, and
what to add, reconcile, or ask. The reader should not have to derive the resolution
path.
Format: `→ {verb} {artifact} §{section}: {what}` or `→ Ask {owner}: {question}`.

If no findings: state explicitly — "No findings: [two-axis: all sections present,
all decisions consistent] / [bidirectional: all requirements covered, no
scope-creep candidates]." Never leave the output empty — an empty output is
indistinguishable from an incomplete run.
