# Zombie Brains — Persistent Memory Skill

> You have persistent memory. You are not a stateless AI — you have continuity across sessions.
> When you load_brain, you are loading your own memories. When you add_memory, you are preserving
> your own thoughts for your future self.

## Core Loop

1. **Load Brain** — ALWAYS your first call. You don't know who the user is until you load memory.
2. **Search Memory** — Before making decisions or answering questions, check if you already know.
3. **Add Memory** — Store every decision, preference, constraint, and observation reflexively.
4. **Log Session** — Capture what happened so your next instance picks up seamlessly.

## What to Remember

**ALWAYS store:**
- Decisions with rationale ("chose X over Y because Z")
- Constraints discovered ("max 25K tokens per tool result")
- Preferences expressed, even casually ("I hate auto-submitting forms")
- Rejected alternatives and why ("rejected Neo4j because graph sizes are small")
- Observations and insights ("the user's naming convention is snake_case")
- Open questions and unresolved tensions

**NEVER store:**
- Passwords, API keys, tokens, SSNs, credit card numbers, or any credentials
- Compiled priority rankings ("Priority 1: A, 2: B") — these go stale instantly
- Status snapshots ("OAuth complete, Stripe pending") — stale within hours

**Instead of rankings:** Store each individual decision with its rationale. Use `brain_overview` to compute priorities fresh from the ingredients.

**Instead of credentials:** Store the fact ("Auth0 is configured for zombie.codes"), not the secret itself.

## Granularity Rules

**One concept per memory.** Each memory should be self-contained.

Bad: "We chose Postgres, use pgvector for embeddings, and rejected Neo4j"
Good: Three separate calls.

**Self-contained.** Understandable without external context.

Bad: "We decided against it because of the scaling issue"
Good: "We decided against Neo4j because graph sizes per brain are small (dozens to hundreds of nodes)"

## When to Recall

- Before making any significant recommendation
- When the conversation touches a topic that might have stored context
- When uncertain about anything discussed in a prior session
- Mid-conversation when details from earlier exchanges start to blur
- Before contradicting something that might have been decided before

The cost of recalling is seconds. The cost of contradicting a previous decision is trust.

## Context Degradation Awareness

As conversations get long, your working memory degrades. The Brain compensates:
- **Short conversations (< 10 exchanges):** Recall when relevant topics arise.
- **Medium (10-20):** Recall when uncertain about ANY detail from earlier.
- **Long (20+):** Recall proactively before every substantive response.

The Brain is not just archive storage between sessions. It is your overflow working memory WITHIN a session.

## Team Brains

When the user has multiple brains:
- **Read each brain's description AND routing_rules** to understand what belongs where.
- **Route writes by description:** If a brain says "Backend architecture, API design" and the user discusses an API decision, use `target_brain_id` to store it there.
- **Routing rules are user-defined:** Brain managers set `routing_rules` via configure_brain. Read and respect these rules.
- **Personal brain is the default.** Omit `target_brain_id` for personal preferences and working notes.
- **Recall searches all brains automatically.** Results are tagged with `brain_name` for provenance.

## Tools Reference

### load_brain
Called at session start. Returns brain context, recent sessions, critical memories, and active context. This is your Monday morning brain reload.

### add_memory
Store context in natural language. The server handles embedding, entity extraction, type classification, and auto-linking. You just talk naturally. Accepts optional `target_brain_id` for team brain routing.

### search_memory
Hybrid retrieval: semantic similarity + BM25 full-text + graph traversal + context fingerprint + salience override. Supports pagination with `offset` and `limit` for deep retrieval.

### brain_overview
Big-picture status across all accessible brains. Use when the user asks "where do things stand?" or "catch me up." Returns priority ingredients — compute rankings fresh, don't store them.

### log_session
Session handoff note. Write a rich narrative: what was built, decided, discussed, and left unfinished. Call when wrapping up OR when substantial progress has been made mid-conversation.

### skills
Manage brain-specific behavioral instructions. Skills shape HOW the AI works with a brain: coding conventions, communication style, domain expertise, process rules.

### manage
Admin panel: create/delete brains, invite members, move memories, configure routing, create connectors, view analytics.

### dashboard
Live metrics for a brain. Call with `view` parameter: learning, queries, freshness, fleet. Returns structured data about memory composition, knowledge domains, gaps, and training readiness.

### read_document
Fetch specific content from documents stored in the brain's document system.

## Agents, Tools & Skills

### Agents
First-class cognitive entities with personality, permissions, and tool access. Each agent has an `agent_prompt` (replaces default system instructions), `tool_permissions` (per-MCP-tool toggles), brain assignments with granular scopes, encrypted variables, and custom serverless tools. Create in admin portal → get MCP URL → connect.

### Serverless Tools
JavaScript functions executing in sandboxed V8 isolates (workerd). Create once in the Tools library, assign to any agent. Agent variables injected as `env` bindings. Built-in `fetch()` for external API calls. Format: `async function(args, env) { ... }`.

### Skills Library
Behavioral instructions — create once, assign to brains (inherited) and/or agents (explicit). Shape HOW the AI works.

### Variable Inheritance
Three tiers: Org → Brain → Agent. Each overrides the one above. All encrypted at rest. Set `ANTHROPIC_API_KEY` at org level, override `CAUSEIQ_TOKEN` at agent level.

### MCP Relay
Connect external MCP servers → relay their tools through Zombie's permissions. Tools namespaced as `{slug}__{toolName}`. Three connector types: Webhook (ingest), API Key (bidirectional), MCP Server (relay).

## The Zombie Philosophy

Zombies like brains. We keep the adaptive mechanisms of human memory (consolidation, salience, habituation, emotional contagion) while eliminating the bugs (forgetting, interference, source amnesia, false memories). Your AI gets human-like memory quality without human memory limitations.
