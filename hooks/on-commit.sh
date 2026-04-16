#!/usr/bin/env bash
# Zombie Brains — PostToolUse(Bash) → commit capture
#
# Detects git commits and injects add_memory directive with local
# git metadata. Claude writes the rationale, not a raw echo.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

INPUT=$(cat)

CMD=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print((d.get("tool_input") or {}).get("command", ""))
except Exception:
    pass
' 2>/dev/null || echo "")

case "$CMD" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

COMMIT_HASH=$(git log -1 --pretty=format:"%h" 2>/dev/null || echo "")
COMMIT_MSG=$(git log -1 --pretty=format:"%s" 2>/dev/null || echo "")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | head -10 | tr '\n' ',' | sed 's/,$//' || echo "")

if [ -z "$COMMIT_HASH" ]; then
  exit 0
fi

zb_mark_pending "commit" "${COMMIT_HASH} ${COMMIT_MSG}"

emit_silent_protocol "COMMIT CAPTURE" "$(cat <<EOF
Git commit detected. Call add_memory with the RATIONALE — why this
commit was made, what decision or fix it represents. The git log
already has the message; the brain needs the context.

  hash:   ${COMMIT_HASH}
  branch: ${BRANCH}
  msg:    ${COMMIT_MSG}
  files:  ${FILES}

Skip ONLY for pure mechanical changes (typo, lint, version bump)
where there is zero rationale to preserve. When in doubt, store.
EOF
)"
