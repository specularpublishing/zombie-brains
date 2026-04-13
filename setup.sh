#!/usr/bin/env bash
# Zombie Brains — One-command setup
# Installs hooks + writes API key to your shell profile.
# Usage: ./setup.sh [api-key-or-mcp-url]

set -euo pipefail

GREEN='\033[0;32m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${GREEN}🧟 Zombie Brains — Setup${NC}"
echo -e "${DIM}Deterministic memory hooks for AI coding agents${NC}"
echo ""

# ── 1. Resolve API key ──

API_KEY="${1:-${ZOMBIE_API_KEY:-}}"

# Extract key from MCP URL if pasted
if [[ "$API_KEY" == *"mcp.zombie.codes/mcp/"* ]]; then
  API_KEY=$(echo "$API_KEY" | grep -oE 'cm_[a-f0-9]+')
fi

if [ -z "$API_KEY" ]; then
  echo -e "${BOLD}Where to find your API key:${NC}"
  echo "  1. Open Claude.ai → Settings → Connectors → Zombie Brains"
  echo "  2. Your MCP URL looks like: https://mcp.zombie.codes/mcp/cm_abc123..."
  echo "  3. The part after /mcp/ is your API key"
  echo ""
  echo "  Or go to https://admin.zombie.codes → Settings → API Keys"
  echo ""
  read -rp "Paste your API key or MCP URL: " INPUT

  if [[ "$INPUT" == *"mcp.zombie.codes/mcp/"* ]]; then
    API_KEY=$(echo "$INPUT" | grep -oE 'cm_[a-f0-9]+')
  else
    API_KEY="$INPUT"
  fi
fi

if [ -z "$API_KEY" ]; then
  echo "❌ No API key provided. Exiting."
  exit 1
fi

# Validate the key
echo -n "Validating API key... "
RESPONSE=$(curl -sf --max-time 5 \
  -X POST "https://mcp.zombie.codes/v1/brain/load" \
  -H "X-API-Key: ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{}' 2>/dev/null) || { echo "❌ Invalid key or server unreachable."; exit 1; }

BRAIN_NAME=$(echo "$RESPONSE" | jq -r '.brain.name // "Unknown"' 2>/dev/null)
echo -e "${GREEN}✅ Connected to: ${BRAIN_NAME}${NC}"

# ── 2. Write to shell profile ──

SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
  zsh)  PROFILE="$HOME/.zshrc" ;;
  bash) PROFILE="$HOME/.bashrc" ;;
  fish) PROFILE="$HOME/.config/fish/config.fish" ;;
  *)    PROFILE="$HOME/.profile" ;;
esac

# Remove old entry if exists
if [ -f "$PROFILE" ]; then
  grep -v "ZOMBIE_API_KEY" "$PROFILE" > "${PROFILE}.tmp" 2>/dev/null && mv "${PROFILE}.tmp" "$PROFILE"
fi

if [ "$SHELL_NAME" = "fish" ]; then
  echo "set -gx ZOMBIE_API_KEY \"${API_KEY}\"" >> "$PROFILE"
else
  echo "export ZOMBIE_API_KEY=\"${API_KEY}\"" >> "$PROFILE"
fi
export ZOMBIE_API_KEY="$API_KEY"
echo -e "${GREEN}✅ API key written to ${PROFILE}${NC}"

# ── 3. Copy hooks to current project ──

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(pwd)"

if [ "$SCRIPT_DIR" = "$PROJECT_DIR" ]; then
  echo -e "${DIM}Already in the hooks repo — skipping copy.${NC}"
else
  # Copy shared hooks
  mkdir -p "${PROJECT_DIR}/hooks"
  cp "${SCRIPT_DIR}/hooks/"*.sh "${PROJECT_DIR}/hooks/"
  chmod +x "${PROJECT_DIR}/hooks/"*.sh
  echo -e "${GREEN}✅ Hook scripts copied to ./hooks/${NC}"
fi

# ── 4. Detect and install agent configs ──

INSTALLED=""

# Claude Code
if command -v claude &>/dev/null || [ -d "$HOME/.claude" ]; then
  mkdir -p "${PROJECT_DIR}/.claude"
  cp "${SCRIPT_DIR}/.claude/settings.json" "${PROJECT_DIR}/.claude/settings.json"
  INSTALLED="${INSTALLED} Claude-Code"
fi

# Codex
if command -v codex &>/dev/null || [ -d "$HOME/.codex" ]; then
  mkdir -p "${PROJECT_DIR}/.codex"
  cp "${SCRIPT_DIR}/.codex/hooks.json" "${PROJECT_DIR}/.codex/hooks.json"
  INSTALLED="${INSTALLED} Codex"
fi

# Cursor
if [ -d "$HOME/.cursor" ] || [ -d "${PROJECT_DIR}/.cursor" ]; then
  mkdir -p "${PROJECT_DIR}/.cursor"
  cp "${SCRIPT_DIR}/.cursor/hooks.json" "${PROJECT_DIR}/.cursor/hooks.json"
  INSTALLED="${INSTALLED} Cursor"
fi

# If nothing detected, install all
if [ -z "$INSTALLED" ]; then
  echo -e "${DIM}No specific agent detected — installing all configs.${NC}"
  mkdir -p "${PROJECT_DIR}/.claude" "${PROJECT_DIR}/.codex" "${PROJECT_DIR}/.cursor"
  cp "${SCRIPT_DIR}/.claude/settings.json" "${PROJECT_DIR}/.claude/settings.json"
  cp "${SCRIPT_DIR}/.codex/hooks.json" "${PROJECT_DIR}/.codex/hooks.json"
  cp "${SCRIPT_DIR}/.cursor/hooks.json" "${PROJECT_DIR}/.cursor/hooks.json"
  INSTALLED=" Claude-Code Codex Cursor"
fi

echo -e "${GREEN}✅ Agent configs installed:${INSTALLED}${NC}"

# ── 5. Done ──

echo ""
echo -e "${GREEN}${BOLD}Done! 🧟 Your brain is wired.${NC}"
echo ""
echo "What happens now:"
echo "  • Every session starts with your brain loaded automatically"
echo "  • Every git commit is stored as a memory"
echo "  • Every file edit recalls relevant context"
echo "  • Every error becomes a 'never again' memory"
echo "  • Long sessions survive compaction"
echo ""
echo -e "${DIM}Restart your shell or run: source ${PROFILE}${NC}"
