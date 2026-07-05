#!/usr/bin/env bash
# Locate THIS plugin's own clone. Self-locates from its own path (script lives at
# <root>/bin/), so there is no hardcoded path to go stale.
#
#   principles-repo.sh path     → print the repo root, UNGUARDED. For read-only
#                                 callers (e.g. source-audit reading PRINCIPLES.md).
#   principles-repo.sh [guard]  → print the root ONLY in author-mode: a *writable*
#                                 git clone of zordius/ai. For the WRITE path
#                                 (add-principle's commit+push). Exits non-zero
#                                 with a reason otherwise (installed/cache copy).
#                                 Default when no subcommand is given.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${1:-guard}" in
  path)
    # Unguarded locate — reading the source needs no write authority.
    echo "$ROOT"
    ;;
  guard)
    # Author-mode guard — only push from a writable clone of zordius/ai.
    git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
      || { echo "not-author-mode: $ROOT is not a git work tree" >&2; exit 3; }
    origin="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
    case "$origin" in
      *zordius/ai*) : ;;
      *) echo "not-author-mode: origin '$origin' is not zordius/ai — refusing (installed/cache copy?)" >&2; exit 4 ;;
    esac
    [ -w "$ROOT" ] || { echo "not-author-mode: $ROOT is not writable" >&2; exit 5; }
    echo "$ROOT"
    ;;
  *)
    echo "usage: principles-repo.sh [path|guard]" >&2; exit 2
    ;;
esac
