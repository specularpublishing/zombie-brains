#!/usr/bin/env bash
# Zombie Brains — UserPromptSubmit hook
#
# Fires on every user message. Search is mandatory. Memory storage
# defaults to YES — the brain handles noise, it cannot handle gaps.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

emit_silent_protocol "PER-TURN MEMORY" "$(cat <<'EOF'
SEARCH: Call search_memory with the core topic of the user's message.
Do this BEFORE you start composing your response. If the brain has
relevant context, use it. This is not optional.

STORE: After you respond, evaluate this exchange for add_memory.
Default to STORING. The brain is designed to handle volume — a
redundant memory costs nothing, a gap costs an entire future session
re-deriving what was already known.

STORE unless the exchange is PURELY mechanical ("run this command",
"yes", "ok", "continue"). If there is any decision, preference,
constraint, correction, discovery, or new information — store it.

When in doubt, store. The server scores and consolidates automatically.
EOF
)"
