#!/usr/bin/env bash
# add-principle helper — self-locate THIS plugin's own clone and guard author-mode.
#
# Prints the repo root on stdout ONLY when we're in a writable git clone of
# zordius/ai (i.e. the plugin was loaded via `--plugin-dir <your-clone>`, not an
# installed/cache copy). Otherwise exits non-zero with a reason on stderr.
#
# Self-locates from its own path (script lives at <root>/bin/), so there is no
# hardcoded path to go stale — it always resolves the clone it was loaded from.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "not-author-mode: $ROOT is not a git work tree" >&2; exit 3; }

origin="$(git -C "$ROOT" remote get-url origin 2>/dev/null || true)"
case "$origin" in
  *zordius/ai*) : ;;
  *) echo "not-author-mode: origin '$origin' is not zordius/ai — refusing (installed/cache copy?)" >&2; exit 4 ;;
esac

[ -w "$ROOT" ] || { echo "not-author-mode: $ROOT is not writable" >&2; exit 5; }

echo "$ROOT"
