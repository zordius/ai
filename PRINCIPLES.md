# Principles for AI-augmented engineering

A personal collection of design principles, naming conventions, and method
patterns I keep landing on across AI-augmented engineering work — distilled
from a working Claude Code project. Methods are kept generalized; concrete
examples are tagged "**e.g.**" so they don't read as the rule.

The goal is to capture the *thinking* behind a stable AI-augmented workspace,
not the workspace itself. Directory paths, scripts, and configs are
project-specific — what survives abstraction is the discipline, the naming
taxonomy, the layering of authority, and a handful of reusable methods.

---

## 1. Discipline (the spine)

These behaviors should hold in every session, every task. Most belong in an
always-loaded operational doc (e.g. `CLAUDE.md`).

### Fact discipline
Never present memory or inference as established fact. Ground a claim in a
primary source, or mark it (`[TBC]`, "likely", "appears"). Surface conflicting
sources rather than silently picking one. *Exempt:* trivial mechanical edits
and clearly-subjective or explicitly-speculative statements — but never relabel
a factual claim to dodge this.

### Abbreviation discipline
Don't coin initials that abbreviate a name (e.g. "TI" for "ticket protocol").
Spell the name out. Use only widely-recognized abbreviations (API, RPC, MCP,
PR). Qualified index labels in a defined cross-ref system (anti-pattern T3,
source tier 1, Step 5) are fine — they're anchors, not name-abbreviations.
Invented name-initials collide and rot.

### CLI first, MCP second
If a well-known CLI does the job, use it via shell — not an MCP. One auth
covers many use cases; the AI and the human use the same tool; CLI text
output costs only its bytes while MCP adds tool schemas + structured payloads.
Reach for an MCP when no CLI exists, or when the MCP brings something the CLI
fundamentally can't (interactive OAuth, indexed search with semantic
features, structured output the agent shouldn't text-parse).

**e.g.** `gh` (GitHub PRs/issues/search/releases), `git`, `rg`/`fd`, `op`
(1Password), `gcloud`, `kubectl` — preferred over equivalent MCPs.

### Never WebFetch authenticated platforms
If reading the page requires a browser login, the platform's MCP is the only
correct path. If the MCP isn't loaded, pause and ask for setup — never fall
back to `WebFetch`.

### Prompt-tainting compound avoidance
One command per shell call. A pipe splits the call into segments that must
*each* be allowlisted — they typically can't all be. Use the tool's own flags
(`rg -l/-c/--stats/-g`), or write a single-command wrapper script that
encloses the actual pipe inside one allowlisted invocation.

### Explicit-path staging only
Never `git add -A` or `git add .` — those grab work from parallel sessions
and bypass intent. Stage by exact path, derived from what *this* turn
actually changed.

### Session-scoped operations by default
Operations that change shared state (commits, comments, deploys) should
default to "what I did this turn", not "everything in the working tree".
A `--all` (or equivalent) flag is the explicit override.

### Trigger-phrase pointers
A reference like "see X.md" only fires when the AI recognizes the situation.
Put the *trigger word* in the always-loaded doc so routing happens.

| Weak | Strong |
|---|---|
| "See `tool-selection.md` for details" | "Before adopting any MCP or choosing between CLI and MCP, read `tool-selection.md`" |

### Don't delegate understanding
Subagents are for parallelism and context isolation, not for replacing
comprehension. Brief them as if they walked into the room cold — full
context, full goal, no assumed knowledge from earlier in your conversation.

### Trust but verify subagent output
Their summary describes what they intended, not necessarily what they did.
After a code-changing subagent, check actual file state before reporting
the work as done.

### One target per comment / report
Multi-location findings: split into one comment per location, each with a
"will post here →" link. A single comment listing five places becomes a
single ambiguous notification.

### Clickable links in deliverables
References (Slack threads, docs, PRs, files) render as markdown links, not
bare text, in drafted comments and reports.

---

## 2. Naming taxonomy

Directory paths are project-specific. What's portable is the *axis* you name
along: **lifecycle**. Two files with the same content but different lifecycle
should sit in different dirs.

### Top-level workspace dirs

| Suggested name | Lifecycle | What lives there |
|---|---|---|
| `codebase/` | **Read-only**, auto-synced | External code you want to *read* but never edit; source of truth lives elsewhere |
| `<personal-dev>/` (e.g. `zdev/`) | **Editable, personal**, gitignored per-subdir | Your own iterating-on work; clones you actively modify |
| `scratch/` | **Ephemeral**, session-bound | Junk redirect targets (`> scratch/<hex>.txt`); never reused next session; opaque names |
| `cache/` | **Durable**, cross-session | Things worth reusing days later (kb hits, fetched specs); meaningful names |
| `<substantial-tool>/` | **Forked code**, top-level | Substantial in-tree code with its own dev loop; usually a clone with local mods |

The principle behind it: **dirs are named for lifecycle, not for content**.
`scratch/foo.txt` and `cache/foo.txt` behave differently — that's why they're
different dirs. Don't pick a name that hides the lifecycle.

### AI configuration layout

| Suggested name | Purpose |
|---|---|
| `.claude/` (or `.cursor/`, etc.) | All AI configuration |
| `.claude/scripts/` | Bootstrap + operational scripts (idempotent, runnable) |
| `.claude/docs/` | Design rationale, audit reference; anything *consulted*, not always-loaded |
| `.claude/skills/`, `agents/`, `commands/` | AI-harness primitives by their kind |
| `.claude/kb/` (optional) | Cached knowledge, tiered |
| `~/.claude/configs/` | User-personal per-machine config (per-user-secret MCP setups, etc.) |
| `~/.claude/.../memory/` | Cross-session personal context (not operational rules) |

---

## 3. Authority layering (where rules live)

A single rule could live in four places. Pick by **how often it should fire**.

| Always loaded? | Home | What lives here |
|---|---|---|
| Yes, every session | `CLAUDE.md` (or equivalent always-loaded doc) | Operational behavior — "do this now". Terse. |
| Only during reviews/audits | `.claude/docs/<topic>.md`, with a trigger-phrase pointer from the always-loaded doc | Rationale, audit reference, decision criteria |
| Cross-session personal | `~/.claude/.../memory/<rule>.md` | Personal decisions and learnings; not operational rules |
| Preloaded into a specific agent | The agent's `skills:` frontmatter | Content the agent always operates with |

The principle: **CLAUDE.md is for behavior the AI should exhibit constantly;
docs are for decisions the AI should make occasionally; memory is for context
you'd otherwise re-derive.** Don't put design rationale in CLAUDE.md — it
inflates context for every session, when it's only needed when the decision
comes up.

---

## 4. MCP tiering — what goes in project config

Three tiers, deciding factor is **setup friction + credential blast radius**
(not context cost, which on modern agent harnesses is near-zero for unused
MCPs):

| Tier | Setup shape | Belongs in project config? |
|---|---|---|
| **Hosted/official** | OAuth or no auth | ✅ Yes |
| **Local sidecar in-repo** | pnpm/npm-installed alongside project code | ✅ Yes |
| **Per-user secret** | User must supply API key, license, or token | ❌ No — opt-in via user config + setup script |

The "easy to start for everyone" promise breaks if anyone cloning the repo
has to manually obtain credentials before things work. Per-user-secret MCPs
get a `setup-<name>.sh` recipe instead, which writes config to the user's
home (not the project tree).

**e.g.** A platform code-search MCP that uses OAuth (Tier 1) belongs in the
project config. A bug-tracker MCP that requires a per-user API key (Tier 3)
belongs in a setup script that writes to `~/.<harness>/configs/`.

---

## 5. Method patterns (generalized, with examples)

Reusable shapes that show up across tasks. Each is a one-paragraph principle;
specifics belong in your project's actual implementation.

### Three-bucket git gather
Inspect the working tree as **STAGED / CHANGED / UNTRACKED** separately, so
downstream agents understand provenance. A file that's already staged was
intentional; an untracked file is suspect; a changed-but-not-staged file is
in-progress.

### Parallel pre-commit scanners
Run independent safety checks in parallel before commit (secret scanner,
gitignore hygiene, lint). Stop only on a hard BLOCK (e.g. a leaked
credential). Warnings can be reported and continued past with user consent.

### Conventional commit + co-author footer
Generated commits follow [Conventional Commits 1.0](https://www.conventionalcommits.org/),
end with a co-author footer announcing AI authorship. Standard format means
release tooling and changelog generators just work.

### Setup-script-as-bootstrap
Per-user-secret tools get a `setup-<name>.sh` that's idempotent, fetches
secrets via a vault CLI (e.g. `op read`), writes to the user's home — not
the project tree. The project tracks the *recipe*, not the credentials.

### Scoped secret storage (minimize a secret's blast radius)
Load a per-user secret in *only* the tool that needs it, not the harness's
shared environment. A secret placed in a globally-injected `env` block reaches
**every** subprocess the agent spawns — including the shell it runs commands in
— so it leaks into arbitrary command and tool output. Instead keep it in a
dedicated, gitignored, read-denied file loaded only by its consumer: the tool's
launcher (**e.g.** `node --env-file=<file>`) or the script that reads it
in-process. Name the file for what it is, **not** `.env` — `.env` is the magnet
for accidental reads (grep, file-watchers, the agent's own read tool), and a
read-deny rule often doesn't cover every read path (a `grep`/`find` still
surfaces it). Committed config carries no literal secret — only an
env-var-with-default or a file reference. And rotate any secret that ever
entered the agent's context (pasted, echoed, or printed).

### Pipe-wrapper for allowlist-blocked compounds
When a workflow genuinely needs a pipe but the harness blocks pipes for
safety, write a tiny allowlisted wrapper script that encloses the pipe
internally. The harness sees one approved command; the pipe runs *inside*
that command.

### Stage gate before exhaustive code sweep
Before doing exhaustive code search for a feature, confirm the project's
lifecycle stage. Pre-implementation work (planning, design, ticket triage)
rarely needs the codebase searched. Skip the sweep, save the context.

### Three-tier knowledge base
- **`knowledge/`** — domain concepts and feature specs (multi-source,
  confidence-tracked, never silently downgrade)
- **`projects/`** — work tracking (tickets, current state)
- **`process/`** — open-item registers (append-only, no confidence concept)

Each tier has its own merge and write discipline. Don't conflate them —
the lifecycle and citation rules differ.

### Resume detection
Before starting work on something stateful (a long-running ticket, a
multi-step refactor), discover what already exists (comments, branches,
PRs, prior session traces). Pick up where prior work left off; don't
re-derive.

### Citation contract for fact-making agents
Verifier-style agents must end every factual claim with `[src: …]` or
`[TBC: …]`. The contract is preloaded into the agent via its always-loaded
skills frontmatter, so it can't forget mid-task.

### Six-step safety sequence for stateful posts
Before posting to a shared system (Jira comment, Slack message, PR review),
run a fixed safety sequence: assignee-only guard, dedup check, dry-run
preview, user confirmation, post, audit log. The same sequence becomes
trustworthy through repetition.

---

## How to use this doc

This isn't a workspace template — it's a *checklist* for designing one.

When setting up a new AI-augmented project, walk this doc top to bottom:

1. Pick the discipline rules you want to enforce (Section 1) — those go
   into your always-loaded operational doc.
2. Decide your naming taxonomy (Section 2) — lifecycle-driven, not
   content-driven.
3. Decide where each kind of rule lives (Section 3) — always-loaded vs.
   consulted vs. personal vs. agent-internal.
4. Apply the MCP tiering test (Section 4) when bringing in a new MCP.
5. Reach for the method patterns (Section 5) when you find yourself
   re-deriving the same workflow shape.

The discipline is the spine. Everything else is operational glue that
should look different in every project, but think similarly.
