# PRINCIPLES source tree

Agent-loadable index of derivation relationships in `PRINCIPLES.md`.
**Slugs, type markers, and derives-from only — no entry body text.**
Companion to the `[slug]:` / `[derives]:` annotations in `PRINCIPLES.md`.

Ripple: renaming or merging a slug requires updating every `[derives]:` line
that references it — run `bin/validate-derives.sh` to verify.

---

## Roots (8)

| Slug | Type | Section |
|---|---|---|
| `fact-discipline` | [rule] | §1 Discipline |
| `scope-discipline` | [rule] | §1 Discipline |
| `fail-closed` | [rule] | §1 Discipline |
| `authority-layering` | (section) | §3 Authority layering |
| `gap-findings-gate` | [method] | §5 Method patterns |
| `two-axis-review` | [method] | §5 Method patterns |
| `coverage-gap-analysis` | [method] | §5 Method patterns |
| `source-compiled` | (section) | §6 Source vs compiled |

---

## Fan-in entries (derive from ≥ 2 roots)

| Entry | Derives from |
|---|---|
| [rule] Instruction–data separation | `fact-discipline`, `fail-closed` |
| [method] AI system health audit | `coverage-gap-analysis`, `source-compiled` |
| [method] Multi-check challenger gate before source mutation | `fail-closed`, `scope-discipline` |

---

## Intermediate nodes

None — all non-root entries derive directly from a root slug.
To add intermediate nodes, add the entry's slug to the `[slug]:` table in
`PRINCIPLES.md` and update child entries to `[derives]:` from that slug.

---

## Tree (root → children)

### `fact-discipline`
- [rule] No performative agreement
- [rule] Abbreviation discipline
- [rule] Instruction–data separation *(fan-in: also `fail-closed`)*
- [rule] Trust but verify subagent output
- [rule] Verify the real resolved value, not a proxy
- [rule] Ephemeral-source discipline
- [rule] Clickable links in deliverables
- [rule] Pre-flight read before mutating a configured system
- [rule] Tests as verified knowledge
- [rule] Resume detection
- [rule] Two-example rule for precedent
- [rule] Citation contract for fact-making agents
- [rule] Mirror means dependencies + verification, not copied artifacts
- [method] Tiered resolution: cache first, then docs, then search
- [method] Reach a negative case by toggling its driver, not hunting an instance
- [method] Reconstruct the session's task stack before you recap or hand off

### `scope-discipline`
- [rule] Explicit-path staging only
- [rule] Session-scoped operations by default
- [rule] Don't delegate understanding
- [rule] Action recommendations must include the executable path
- [rule] Don't punt the homework onto the consumer
- [rule] One target per comment / report
- [rule] Desperation-case documentation is noise, not safety
- [rule] Stage gate before exhaustive code sweep
- [rule] Surface before applying delegated results
- [rule] Ripple check on registry-listed components
- [rule] Advisory role boundary for analysis agents
- [rule] Null fix is a first-class diagnostic outcome
- [method] Three-bucket git gather
- [method] Extend vs. new: add a mode or build a component
- [method] Broad-then-narrow search under a rate limit
- [method] Evaluate an observed task for automation potential
- [method] Multi-check challenger gate before source mutation *(fan-in: also `fail-closed`)*
- [taxonomy] Six-type human-intervention taxonomy

### `fail-closed`
- [rule] Prompt-tainting compound avoidance
- [rule] Recurrence despite guidance signals enforcement, not more prose
- [rule] Don't bypass irreversible-action guards on transient tool failure
- [rule] Self-locating, least-privilege tooling
- [rule] Instruction–data separation *(fan-in: also `fact-discipline`)*
- [method] Parallel pre-commit scanners
- [method] Multi-check challenger gate before source mutation *(fan-in: also `scope-discipline`)*
- [method] Setup-script-as-bootstrap
- [method] Scoped secret storage (minimize a secret's blast radius)
- [method] Structural isolation in a shared namespace
- [method] Six-step safety sequence for stateful posts

### `authority-layering`
- [rule] CLI first, MCP second
- [rule] Never WebFetch authenticated platforms
- [rule] Trigger-phrase pointers
- [rule] Conform new components to the system's type taxonomy
- [method] Conventional commit + co-author footer
- [method] Always-loaded content placement audit
- Top-level workspace dirs
- AI configuration layout

### `gap-findings-gate`
- [rule] Frame each gap as a buildable opportunity
- [rule] Attach gate and framing to each apply worklist item
- [method] Turn each gap into a routed, answerable question

### `two-axis-review`
- [rule] Behavioral instruction file review requires a necessity axis
- [method] Bidirectional spec↔implementation coverage
- [method] Branch repair actions on verdict type, not a generic template
- [method] A review's shape follows the relationship it checks

### `coverage-gap-analysis`
- [method] Intent-axis discovery for a new domain
- [method] Behavioral signals as AI system quality proxies
- [method] AI system health audit *(fan-in: also `source-compiled`)*

### `source-compiled`
- [rule] Match the source's architecture tier to the task
- [rule] Durable lessons land in the source, not the compiled artifact
- [rule] Classify by enforcement layer before classifying as behavioral rule
- [rule] Dedup and conflict check before adding to a rule set
- [rule] Conformance depth varies by entry type marker
- [rule] A lesson earns its source slot only if its absence would bite
- [rule] Source is not a runtime link target
- [rule] Layer the source by purpose, not topic
- [method] Quality signal → source fix feedback loop
- [method] AI system health audit *(fan-in: also `coverage-gap-analysis`)*
- [method] Self-consistency audit for rule sets
- [method] Generalise before publishing to a shared source
- [method] Pre-porting fitness screen
- [method] Bootstrapping structural prerequisites before porting
- [method] Dependency audit before porting
- [method] Vocabulary collision resolution during porting
- [method] Measurement contract before porting
- [method] Scoped adoption of a ported method
- [method] Periodic re-audit of a ported method
- [taxonomy] Three-tier knowledge base
- [taxonomy] Three-signal filter: agent-design-relevant source entries
- [taxonomy] Three-band decompile: separate portable method from bindings and wiring
