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

## Bidirectional coverage (spec ↔ realization)
- **Forward (spec → change)** — every requirement maps to a concrete reference in
  the change (code, better a test); classify covered / partial / not-covered.
- **Reverse (change → spec)** — every significant hunk maps to a requirement; one
  that doesn't is a **scope-creep candidate**. Exclude noise (formatting, dep
  bumps, generated files). An empty change is never a pass.

## Output
Findings grounded in the artifacts (cite where each lives); surface every conflict
with both sides rather than resolving it silently. Keep *what's missing*
(completeness / not-covered) separate from *what doesn't line up* (consistency /
scope-creep).
