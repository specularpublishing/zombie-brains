# Zombie Brains — Deterministic Memory Hooks

**Your AI coding agent forgets everything between sessions. These hooks fix that — deterministically.**

One set of hook scripts. Three platform configs. Every commit, every error, every decision — stored automatically without relying on the AI to remember.

## Quick Start

```bash
git clone https://github.com/Zombie-Brains/zombie-brains.git
cd your-project
/path/to/zombie-brains/setup.sh
```

The setup script:
1. Asks for your API key (or extracts it from your MCP URL)
2. Validates it against your brain
3. Writes `ZOMBIE_API_KEY` to your shell profile
4. Detects which AI agents you have installed (Claude Code, Codex, Cursor)
5. Copies the right hooks and configs automatically

**That's it.** Restart your shell and every session builds on the last.

## What the Hooks Do

| Hook | Trigger | What happens |
|------|---------|-------------|
| **Session Start** | Session opens | Auto-loads your brain, injects context |
| **On Commit** | `git commit` | Stores commit + changed files as a memory |
| **On Edit** | File write/edit | Searches brain for context, injects silently |
| **On Error** | Tool failure | Stores errors as critical "never again" memories |
| **On Stop** | Agent finishes | Logs session summary (async) |
| **Pre-Compact** | Before compaction | Re-injects critical memories for long sessions |

## Supported Platforms

| Platform | Config | Status |
|----------|--------|--------|
| **Claude Code** | `.claude/settings.json` | ✅ Full (12+ events) |
| **OpenAI Codex** | `.codex/hooks.json` | ✅ Supported |
| **Cursor** | `.cursor/hooks.json` | ✅ Supported |

All platforms use the same `hooks/` scripts. Only the config format differs.

## Manual Install

If you prefer to set things up yourself:

```bash
# 1. Set your API key
export ZOMBIE_API_KEY="cm_your_key_here"

# 2. Copy hooks to your project
cp -r zombie-brains/hooks your-project/hooks

# 3. Copy your platform's config
cp -r zombie-brains/.claude your-project/.claude    # Claude Code
cp -r zombie-brains/.codex your-project/.codex      # Codex
cp -r zombie-brains/.cursor your-project/.cursor     # Cursor
```

## Where to Find Your API Key

Your API key is embedded in your MCP URL:
```
https://mcp.zombie.codes/mcp/cm_abc123def456...
                              ^^^^^^^^^^^^^^^^
                              This is your key
```

Find it in: **Claude.ai → Settings → Connectors → Zombie Brains**

Or generate one at: **admin.zombie.codes → Settings → API Keys**

## How It Works

**The AI doesn't decide to remember — the hooks guarantee it.**

```
Agent event fires (commit, edit, error, session start)
  → Hook script reads event JSON from stdin
  → Extracts relevant data (commit msg, file path, error)
  → Calls Zombie REST API via curl
  → Returns additionalContext (injected into agent's context)
```

## Requirements

- `curl` and `jq` (pre-installed on macOS; `apt install jq` on Linux)
- A [Zombie Brains](https://zombie.codes) account
- Any supported AI coding agent

## Also Included: SKILL.md

The behavioral guide that teaches your AI agent the core loop:
1. **Load Brain** — always first
2. **Search Memory** — before decisions
3. **Add Memory** — store reflexively
4. **Log Session** — capture handoff notes

```bash
# Install as a Claude Code skill
mkdir -p ~/.claude/skills/zombie-brains
cp SKILL.md ~/.claude/skills/zombie-brains/SKILL.md
```

## Links

- [Zombie Brains](https://zombie.codes) — The Cognitive OS for AI
- [Docs](https://mcp.zombie.codes/docs) — Full API documentation
- [MCP Connector](https://mcp.zombie.codes) — Connect via Claude.ai

---

*Context that won't stay dead.* 🧟
