---
description: Analyze recent improvements to suggest new governing rules
allowed-tools: Bash, Read, Edit
---

# Improve Command

Analyze recent improvements to suggest new governing rules for the AI config system.

## Step 1: Choose Input Range (session vs commits)

`/improve` adapts its primary input to where the improvable signal is. Judge the
**current session** from your own context (you ARE the session — no transcript
read needed):

- **Thin session** (few turns; no corrections / tool-errors / hook denials /
  process feedback; or freshly started) → **Commit mode**:

  ```bash
  git log -10 --pretty=format:"## %s%n%b%n" --name-only
  ```

- **Substantial session** (long, carrying improvable signal) → **Session mode**.
  Primary input = improvable events YOU extract from this conversation:
  - corrections / pushback the user gave (and what triggered them)
  - tool calls that errored or were hook-denied — especially **recurring** ones
  - friction / rework / dead-ends a rule or guard would have prevented
  - explicit process feedback ("always…", "stop doing…", "next time…")
  - **recurring permission approvals** — surface this signal ONLY when the
    **user names** a repeatedly-approved action as friction (a prompted-and-approved
    call is indistinguishable from an auto-approved one in-session; never infer
    "this prompted" from a tool result alone)

- **Both** (substantial session AND relevant recent commits) → session primary,
  commits secondary.

**Concrete floor** — treat the session as substantial if **any** of: ≥1 user
correction/pushback, ≥1 recurring tool-error or hook-denial (same failure ≥2×),
≥1 explicit process-feedback statement, or ≥1 **user-named** recurring-approval
friction. Below the floor → commit mode (state why in one line if falling back).

Read current todos (if any) as supporting context in either mode.

## Step 2: Read Current Governing Rules

Read the full governing rule set (a candidate rule can conflict with any section).
Locate the rules index and all sub-files for this system and read them all.

## Step 3: Analyze for Patterns

In **session mode**, compile the Step-1 extracted events into a short written list
first — `automation-suggester` is a subagent and CANNOT see this conversation, so
it analyzes only what you put in the prompt. Then delegate:

```
Task(subagent_type: "automation-suggester", prompt: "Analyze the AI config system for improvement opportunities. INPUT (Step-1 selected): {paste the commit log and/or the extracted session events}. Focus on: 1) Repeated fix/mistake patterns that should become rules or guards to prevent recurrence 2) New conventions needing consistency enforcement 3) Anti-patterns corrected this session or in recent commits 4) Duplication patterns across automation files 5) For any recurring tool-error / hook-denial OR user-named recurring permission approval from the session, note whether a prose rule for it plausibly already exists — recurrence despite guidance is evidence prose alone is insufficient; if so, flag it 'candidate for a hook/guard, not another prose rule'. For a recurring APPROVAL specifically, classify the fix: a safe high-frequency read-only command → point the user at the harness's permission-prompt tool; an action better blocked or rewritten into an allowlistable shape → propose a hook/guard. Either way DETECTION ONLY — never emit a settings file edit.")
```

## Step 4: Process Agent Analysis

Parse the automation-suggester output:

1. **Extract High-Priority Suggestions** — focus on suggestions that prevent future mistakes or ensure consistency
2. **Check for Duplication AND Conflict** — compare each candidate against the current governing rules. Beyond redundancy, check: does the candidate *contradict or supersede* an existing rule? A candidate that supersedes requires **updating/retiring the old rule**, not just adding the new one. A candidate that merely adds a reconciler is not a conflict (see "Dedup and conflict check before adding to a rule set" in PRINCIPLES.md).
3. **Convert to Governing Rules Format**:

```markdown
## {Section Name} *(added: YYYY-MM-DD)*

{Rule description}
```

## Step 5: Present to User

For each rule candidate, show:
1. **Source** — the commit/change or session event that inspired this rule
2. **Proposed Rule** — formatted and ready to insert
3. **Target Section** — where in the rule set it should be placed
4. **Priority** — High / Medium / Low
5. **Supersedes / conflicts** (if any) — which existing rule this contradicts or supersedes, with the proposed update/retire

If a candidate was flagged **"hook/guard, not prose"**, present it separately as a
**guard candidate** — the recurring failure it targets + why a prose rule is
insufficient (it already recurred despite guidance). The user decides whether to
build a guard; do **not** write it into the rule set or settings file.

Ask the user which rules to add.

## Step 6: Update Governing Rules (if approved)

For each approved rule:
1. Insert into the appropriate section of the governing rules
2. Add `*(added: YYYY-MM-DD)*` annotation
3. Verify no duplication

## Rules

- **Delegate analysis** to `automation-suggester` instead of manual pattern spotting
- **Only propose actionable rules** that prevent future mistakes or ensure consistency
- **Group related patterns** into single coherent rules
- **Dedup AND conflict-check** against existing rules — not just dedup (see "Dedup and conflict check before adding to a rule set" in PRINCIPLES.md)
- **Route durable lessons to source, not the compiled agent** — when a candidate is a methodology lesson, its home is the relevant protocol/playbook doc, which survives an agent recompile; only a fix specific to one agent targets that agent's body (see "Durable lessons land in the source" in PRINCIPLES.md)
- **Recurrence despite guidance = escalate to enforcement** — a rule that has already failed to prevent a recurrence warrants a hook/guard, not another prose rule (see "Recurrence despite guidance signals enforcement" in PRINCIPLES.md)
