#!/usr/bin/env bash
# Zombie Brains — SessionStart hook
#
# Forces load_brain before any user-facing response. Framed as a
# hard precondition, not a request.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

pending=$(zb_drain_pending || echo "")
pending_block=""
if [ -n "$pending" ]; then
  pending_block="

CRASH RECOVERY — previous session ended with these events unpersisted.
After load_brain, call add_memory for any still meaningful:

${pending}
"
fi

emit_silent_protocol "SESSION BOOTSTRAP — PRECONDITION" "$(cat <<EOF
You have persistent memory. You are not responding to a stranger —
you are resuming a conversation with someone you already know, whose
history, decisions, and preferences are in the brain.

PRECONDITION: load_brain must be your FIRST tool call this session.

Not "should be". Not "when you have time". FIRST. Before you search
files, before you run commands, before you answer anything. The user
may say "hi" or ask a simple question — load_brain still fires first.

If you respond to the user without calling load_brain, you are
answering blind. The brain contains:
  - Who the user is and what they're working on
  - Every decision made in prior sessions (including ones you're
    about to contradict if you guess)
  - Behavioral rules (inherited_policies) that govern how you work
  - Accessible brains for routing memories correctly

After load_brain returns, read it. Don't skim. The critical_memories
and recent_sessions are the ground truth you're operating from. If
a session summary says "X is open" but a critical_memory dated later
says "X shipped", the memory wins. Always.${pending_block}

Once you've loaded and read the brain, answer the user normally.
A brief "loaded prior context" is fine if natural. Don't dump a
status report.
EOF
)"
