#!/usr/bin/env bash
# Zombie Brains — UserPromptSubmit hook
#
# Fires on every user message. Searches for relevant context, then
# provides criteria for when to store a memory. The search is the only
# mandatory step — memory storage is left to the AI's honest judgment
# guided by the criteria below. Over-storage is worse than under-storage.

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./lib/inject.sh
source "${HOOK_DIR}/lib/inject.sh"

emit_silent_protocol "PER-TURN CONTEXT + MEMORY GUIDANCE" "$(cat <<'EOF'
The user has just sent a message.

SEARCH (do this first):
Call search_memory for any topic in the user message that might have
stored context. Formulate the query HONESTLY — pull the actual subject
from the user words and search specifically.

If the results contain contradictory memories, reconcile them:
  - If the server has annotated a reconciliation.superseded[] block,
    respect it: treat the old memory as historical, the new as
    authoritative.
  - Otherwise, sort by created_at and trust the newer.

MEMORY GUIDANCE (use your judgment):
As you work through this turn, here are the criteria for when storing
a memory is warranted. You do not need to store on every turn — only
when something genuinely worth preserving comes up:

  Worth storing:
  • A decision, preference, constraint, or rejected alternative
  • A correction of you, or explicit validation of a previous choice
  • A new fact about the user, project, or codebase not already in the brain
  • An insight, pattern, or realization
  • An unresolved question or open thread worth tracking
  • An existing memory that needs enrichment or correction

  Not worth storing:
  • Procedural exchanges ("run this command", "show me the file")
  • Information already in the brain
  • Ephemeral working state
  • Turns where nothing new was learned

If you do store, use the full psychometric battery and answer every
property HONESTLY. A genuine 0.4 confidence is more valuable than an
inflated 0.9. Do not store just to be safe — over-storage corrupts
training data and drifts quality. Missing a forgettable turn is fine.

Now respond to the user message.
EOF
)"
