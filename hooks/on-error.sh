#!/usr/bin/env bash
# Zombie Brains — PostToolUseFailure hook
#
# When a tool call fails, assess whether it's a novel constraint
# worth remembering or a routine transient to skip.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

INPUT=$(cat)

TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print(d.get("tool_name", "unknown"))
except Exception:
    print("unknown")
' 2>/dev/null || echo "unknown")

ERROR_MSG=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    resp = d.get("tool_response") or {}
    err = resp.get("stderr") or resp.get("text") or d.get("error") or ""
    print(err[:500])
except Exception:
    pass
' 2>/dev/null || echo "")

if [ -z "$ERROR_MSG" ]; then
  exit 0
fi

zb_mark_pending "error" "${TOOL_NAME}: ${ERROR_MSG}"

emit_silent_protocol "TOOL FAILURE" "$(cat <<EOF
Tool failed: ${TOOL_NAME}
Error: ${ERROR_MSG}

If this is a novel constraint or gotcha that would bite a future
session, call add_memory. Skip for routine transients (network blip,
typo, expected probe). Fix the issue as normal.
EOF
)"
