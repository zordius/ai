# zordius/ai

A Claude Code plugin for AI-augmented engineering. Provides agents and skills
for maintaining, auditing, and improving AI config systems (`.claude/` and
equivalents). Loaded via `--plugin-dir ~/zrepos/ai`.

The design rationale and methodology live in [`PRINCIPLES.md`](PRINCIPLES.md).
The agents and skills here are compiled artifacts of that source — durable
lessons land in the source, not the artifacts.

---

## Agents

Invoke via `zordius-ai:{name}` in the agent tool, or let the harness route by description.

| Agent | When to use |
|---|---|
| [`system-consultant`](agents/system-consultant.md) | **Before creating or modifying any `.claude/` file.** Reads the knowledge baseline and governing rules, checks mechanics, validates schema, identifies companion ripple. Also runs full config-system audits. |
| [`claude-md-challenger`](agents/claude-md-challenger.md) | **When `CLAUDE.md` has grown large or trimming is under consideration.** Classifies each section as KEEP / SPLIT / POSITIVE; advisory output only. |
| [`automation-suggester`](agents/automation-suggester.md) | **Mode A** — after running a workflow where manual steps accumulated: classifies each intervention as automatable or a necessary human gate. **Mode B** — to find coverage gaps in the AI config system against its intent axes. |

---

## Skills

Invoke via `/zordius-ai:{name}`.

| Skill | When to use |
|---|---|
| [`source-audit`](skills/source-audit/SKILL.md) | **After any `PRINCIPLES.md` change**, or on a periodic cadence: bidirectional gap check between source entries and compiled artifacts. Mode 1 finds orphaned methods to lift; Mode 2 finds source entries not yet reflected in artifacts. |
| [`add-principle`](skills/add-principle/SKILL.md) | **When a session surfaces a generalizable rule** worth adding to `PRINCIPLES.md`. Walks the 10-check challenger pass, derives annotation, and gpg-commits. Author-mode only (writable clone). |
| [`review`](skills/review/SKILL.md) | **When reviewing any set of artifacts** whose relationship matters. Picks the shape by relationship: two-axis for peers that should agree, bidirectional for spec↔realization, three-axis for behavioral instruction files. |
| [`principles`](skills/principles/SKILL.md) | **When setting up a new AI workspace or auditing an existing one**: condensed operational checklist of `PRINCIPLES.md`. Loaded on demand — not always-on. |
| [`ch`](skills/ch/SKILL.md) | Switch the session to Traditional Chinese (繁體中文). |

---

## Source vs compiled

`PRINCIPLES.md` is the **source**. Agents and skills are **compiled artifacts** —
they implement specific entries from the source, adapted for their execution context.

The source↔compiled gap is tracked by `/zordius-ai:source-audit` and managed
via the lift loop documented in `~/zordius-ai/LIFT.md` (workspace-local; not
part of this repo).

## Commit conventions

- GPG-signed (`-S`); gpg-agent sometimes times out — restart with `/exit` if signing fails
- No `Co-Authored-By` footer (personal public repo)
- Conventional Commits: `fix(artifact):` for artifact fixes, `docs:` for source additions
