---
name: add-principle
description: Sync a distilled principle/method/convention into this plugin's own PRINCIPLES.md — the framework maintaining itself. Author-mode only (run with the plugin loaded via --plugin-dir from your own writable clone). Use when a session lands a generalizable rule worth keeping beyond the current project.
allowed-tools:
  - Bash
  - Read
  - Edit
---

# Add a principle (self-maintenance)

Keep `PRINCIPLES.md` — the **A-tier source** of this framework — in sync with new
distillations. This skill lives *inside* the plugin, so it edits the very clone it
was loaded from (no hardcoded path to go stale). It replaces the older,
project-bound `update-principles` skill.

## When to use

The user has identified something worth keeping **beyond the current project**:
a design principle, naming convention, authority-layering rule, MCP-tiering
refinement, or reusable method pattern. Don't auto-invoke — principles are
deliberate; wait for explicit intent ("add this to my principles", "keep this in
`zordius/ai`", after a design discussion that landed a generalizable rule).

## Step 0 — locate the clone & confirm author-mode

```bash
bin/principles-repo.sh
```

It prints the repo root **only if** you're in a writable git clone of `zordius/ai`
(i.e. the plugin was loaded via `--plugin-dir <your-clone>`, typically
`~/zrepos/ai`). If it exits non-zero (`not-author-mode: …`), you're on an
installed/cache copy — **stop**: tell the user to relaunch with
`claude --plugin-dir <their-zordius/ai clone>`; never push from a cache copy. Use
the printed root as `<root>` below.

## Step 1 — pull latest

```bash
git -C <root> pull --rebase
```

Surface any failure (network / conflict / divergence) to the user; don't
auto-resolve.

## Step 2 — read the target

`Read <root>/PRINCIPLES.md`. Read the whole file (it's the dedup baseline). If the
repo has grown substructure, default to `PRINCIPLES.md` but ask which file first.

## Step 3 — draft, generalized (show before editing — the doc is public)

Draft the addition and **show the user** before touching the file. Apply the
discipline:

- **Type marker** — before drafting, confirm which type fits:
  - `[rule]` — a behavioral directive ("always / never / must / do not")
  - `[method]` — a reusable procedure with named steps; each step must produce visible output
  - `[taxonomy]` — a named classification system with enumerable, exhaustive categories
  Assign the marker in the `###` header: `### [rule] Entry name`. A mismatch propagates
  the wrong conformance bar to every future source-audit that checks against this entry.

- **Generalize** — strip project-specific names; frame concrete cases as "**e.g.**".
- **Cite-removal** — drop internal-org links, ticket IDs, vault refs dead to a
  public reader.
- **Counterfactual-absence gate** (PRINCIPLES §6) — before adding, imagine the
  entry gone with the rest of the corpus present: if nothing breaks because an
  existing entry already covers it, **STOP — do not proceed to Edit**; tell the
  user the draft is redundant and name the covering entry (no reworded twins); if
  only *part* is uncovered, lift that part and **reference** the covering entry
  instead of restating it.
- **Conflict / supersession check** — after the absence gate passes, scan for:
  (a) **contradiction** — any existing entry that says the opposite; if found,
  **STOP — do not proceed to Edit**; surface both entries to the user for
  resolution before adding. (b) **supersession** — any existing entry this new
  one makes obsolete; if found, propose retiring or updating the old entry
  alongside the addition (don't leave stale rules in place).
- **Lifecycle-axis naming / trigger-phrase pointers** — if extending the naming
  taxonomy or adding a consulted-doc rule, follow those conventions.

Show the draft to the user. Do not apply the Edit yet — proceed to Step 3c then Step 3b.

## Step 3c — challenger pass

Before applying the Edit, run these ten checks and surface any findings to the user.
The user decides whether to revise, proceed, or stop.

1. **Reliability** — does the method have steps that can fail silently? Are there
   unstated prerequisites? Flag any.
2. **Delta value** — confirm counterfactual-absence gate passed (Step 3). No further
   action if it did.
3. **Reversibility** — will removing this entry later break any `[derives]:` reference?
   If yes, surface this. (No derives pointing at it yet = safe to remove.)
4. **Automation applicability** — apply `Evaluate an observed task for automation
   potential`: what is the irreducible human judgment component? Is context-specificity
   parameterizable? Name the automation type (command / agent / skill / hook / rule).
5. **Agent capability** — for each step in a `[method]`, can an agent execute it with
   current tools? Flag any step that assumes a tool or MCP that may not be available.
6. **Source relationship** — confirm dedup + conflict check passed (Step 3). No further
   action if it did.
7. **Type marker correctness** — verify the marker matches the content:
   `[rule]`: behavioral directive? `[method]`: each step produces visible output?
   `[taxonomy]`: categories enumerable and mutually exhaustive? Flag a mismatch.
8. **Necessity axis** — is this already structurally enforced by a hook, script, or
   permission rule? If yes, a prose rule is redundant; surface this.
9. **Abstraction completeness** — scan for org-specific names, ticket IDs, internal
   URLs, or instance-specific details that weren't abstracted. Flag any found.
10. **Recurrence check** — search for closely-related entries. If a similar rule
    already exists but isn't being followed, more prose won't fix it — enforcement
    is the correct response; flag this.

**Gate**: if any check produced a finding, present all findings and **stop** —
wait for the user's explicit direction (revise / proceed anyway / abort) before
continuing to Step 3b. Do not proceed silently past a finding.
If all ten checks pass with no findings, proceed to Step 3b immediately.

## Step 3b — derives-from annotation

After the challenger pass, determine which source slug(s) this entry derives from:

1. List valid slugs: `grep '^\[slug\]:' <root>/PRINCIPLES.md`
2. Pick the slug whose principle this entry most directly specializes or applies.
   For fan-in entries (two parents): `[derives]: slug1, slug2`.
3. Include `[derives]: parent-slug` in the draft **immediately after the `###`
   heading line** — before any body text.
4. If the slug table is empty (Phase 1 not yet run), proceed without the
   annotation and note it as a follow-up.
5. If this is a genuinely new root (no existing principle it derives from),
   **omit** the `[derives]:` line entirely and instead add `[slug]: new-slug` to
   the slug table — confirm with the user before doing so; new roots are rare.

Then apply with `Edit`, anchored on stable surrounding text.

## Step 4 — show the diff and validate

```bash
git -C <root> --no-pager diff PRINCIPLES.md
```

Then validate derives annotations:

```bash
<root>/bin/validate-derives.sh <root>/PRINCIPLES.md
```

Exit 0 = all slug references resolve. Exit 2 = slug table not yet built (Phase 1
of the source-tree migration pending — proceed, note the gap). Exit 1 = broken
slug reference — fix before committing.

Let the user review diff and validation result before commit.

## Step 5 — commit & push

Conventional Commits 1.0; body explains the generalized rule, not the project
incident that prompted it. **No `Co-Authored-By` footer** (personal public repo).

```bash
git -C <root> add PRINCIPLES.md
git -C <root> commit -m "docs: <summary>"
git -C <root> push
```

Commits are **gpg-signed**. gpg-agent can be flaky — if `commit` hangs or errors
on gpg, **don't loop-retry or silently `--no-gpg-sign`**: ask the user to restart
gpg-agent (`gpgconf --launch gpg-agent`), then retry (the staged edit survives).

On success report: commit SHA, the line(s) changed, and
`https://github.com/zordius/ai/blob/main/PRINCIPLES.md`.

## What NOT to add

Things that don't survive abstraction: org-tooling specifics (Jira, internal URLs,
Slack channels), KB content for specific features, org-specific protocols, or
anything that reads as a private blog entry rather than a transferable principle.

## Step 6 — Ripple check

`PRINCIPLES.md` is **source** — the new entry is now in canon, but compiled
artifacts (agents, skills, `CLAUDE.md`) won't reflect it until explicitly updated.
Based on the entry's signal category, the likely-affected surfaces are:

- **Agent behavior rules** → `agents/` (agents whose job brings the domain into play);
  possibly `CLAUDE.md` if it's a session-level behavioral rule.
- **Construction patterns** → `agents/` and `skills/`.
- **Source/compiled architecture rules** → `skills/source-audit/`, `skills/add-principle/`,
  `skills/principles/`.

Surface the gaps: run `/source-audit` against the relevant surfaces (Mode 2 — compile
direction). This is the standard way to find which artifacts now have a gap against
the new entry. No need to act here — naming the surfaces is the ripple check.
