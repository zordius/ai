---
description: Run source-audit across all plugin automations (agents/ and skills/) in parallel and present a consolidated bidirectional gap report — what to lift from compiled into source, and what to apply from source into compiled.
allowed-tools: Bash, Read, Agent
---

# Full Source Audit

Run a complete bidirectional source↔compiled audit of all plugin automations.

## Step 1 — Locate plugin root

```bash
bin/principles-repo.sh path
```

Use the printed path as `{root}` for all subsequent steps.

## Step 2 — Audit all surfaces in parallel

Invoke the `zordius-ai:source-audit` skill for **each surface in parallel**:

| Surface | Target |
|---|---|
| Agents | `{root}/agents/` |
| Skills | `{root}/skills/` |

Source doc (PRINCIPLES.md) is at `{root}/PRINCIPLES.md` for both runs.

Spawn two independent `general-purpose` agents, each following the `source-audit`
skill steps for its assigned surface. Both agents receive the same source doc path.

## Step 3 — Aggregate and present

Merge the two reports into one consolidated view:

```markdown
# Source Audit: Full Plugin Sweep

## Surface: agents/

### Mode 1 — Lift worklist
{orphaned / divergent / borderline findings from agents/}

### Mode 2 — Apply worklist
{conformance gaps from agents/}

---

## Surface: skills/

### Mode 1 — Lift worklist
{orphaned / divergent / borderline findings from skills/}

### Mode 2 — Apply worklist
{conformance gaps from skills/}

---

## Combined — Top actions (ranked by impact)

### Lift (highest portability first)
1. {artifact} — {Band A summary} → target: {PRINCIPLES.md §N}

### Apply (most impactful gap first)
1. {artifact} — missing {principle}: {what to add}

## Recommended next steps
1. {first action} — {why}
2. {second action} — {why}
```

## Rules

- **Advisory only** — present all findings before acting on any.
- **Dedup across surfaces** — if the same principle gap appears in both agents/ and skills/,
  merge into one finding in the combined section.
- **Trust-but-verify** — subagent verdicts are advisory; flag any that seem over-called
  before presenting to the user.
