#!/usr/bin/env bash
# Zombie Brains — UserPromptSubmit hook
#
# Forces search_memory at the start of every turn, forces add_memory
# evaluation at the end. Framed as mandatory protocol, not optional
# tooling. Default to STORE — gaps cost more than redundancy.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

emit_silent_protocol "PER-TURN MEMORY — MANDATORY" "$(cat <<'EOF'
SEARCH FIRST. Before you compose a single word of response, call
search_memory with the core topic of the user message. The brain
knows things you don't. Answering without searching means you're
guessing when you could be knowing.

Frame the search HONESTLY — pull the actual subject from what the
user said and query it directly. "what's our approach to X" becomes
search_memory({query: "X approach decision"}). Don't formulate
generic queries; formulate specific ones.

If the search returns relevant memories, use them. If it returns
contradictions, trust the newer timestamp. If the server attaches
a reconciliation.superseded[] block, respect it — older memory is
historical, newer is authoritative.

STORE AFTER. When your response is drafted and before you send it,
evaluate this exchange for add_memory. The answer is almost always
YES.

STORE when the exchange contains:
  • A decision or preference the user expressed (however casually)
  • A correction — the user told you you were wrong about something
  • A new fact about their work, project, environment, or goals
  • An insight or realization that changes how future work happens
  • A constraint discovered (technical, organizational, personal)
  • An open question worth tracking

SKIP ONLY when the exchange is PURELY mechanical — single-word
acknowledgments ("yes", "ok", "continue"), command invocations
with no new information ("run the tests"), or direct duplicates
of memories you just searched up.

Defaulting to SKIP is the failure mode. A redundant memory gets
consolidated away by the server. A missed memory costs an entire
future session re-deriving what was already known. The cost
asymmetry says: when in doubt, STORE.

Use the psychometric battery HONESTLY. Low confidence on fields
you're unsure about is BETTER than inflated confidence. The server
reads the battery; fake scores corrupt its thread detection.
EOF
)"
