#!/usr/bin/env bash
# Zombie Brains — SessionStart hook
#
# Forces load_brain before any response. No network calls — the MCP
# is Claude's job, this hook tells Claude to do it.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

# Drain any pending markers from previous session crashes.
pending=$(zb_drain_pending || echo "")
pending_block=""
if [ -n "$pending" ]; then
  pending_block="

CRASH RECOVERY — previous session ended before these were persisted.
After load_brain, call add_memory for any that are still meaningful:

${pending}
"
fi

emit_silent_protocol "SESSION START" "$(cat <<EOF
Call load_brain NOW — before you respond to the user. Do not answer
the user's message until load_brain returns.

After load_brain:
- critical_memories are live facts. Newest timestamp wins conflicts.
- recent_sessions are frozen snapshots — treat as historical context.
- inherited_policies are behavioral rules — follow them.
- accessible_brains tell you where to route memories this session.

If a session summary says something is "open" but a critical memory
says it shipped, the memory wins. The summary is stale.${pending_block}

Respond to the user naturally. Brief context acknowledgment is fine
but do not dump a status report.
EOF
)"
