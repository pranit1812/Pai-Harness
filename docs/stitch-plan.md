# Stitch plan

Design only. Target: run on Pranit's PC. Verified 15 Oct 2026.

## Top 10 repos to stitch (ranked)

1. **steipete/CodexBar** - live usage/limits for Claude, Codex, Cursor, Gemini, OpenRouter, and 100+ others via CLI/`serve`. Fixes the "only OpenRouter has credits" mistake.
2. **BerriAI/litellm** - one gateway for cloud + local + Jev pass-through; budgets and logging hooks.
3. **anthropics/claude-code** (+ Agent SDK) - orchestrator. Plans; does not own spend (code does).
4. **agentclientprotocol/agent-client-protocol** (+ codex-acp, claude-agent-acp, pi-acp, etc.) - one client to Codex, Cursor, Gemini, OpenCode, Pi.
5. **anthropics/skills** - SKILL.md block format and skill-creator template for the builder.
6. **NousResearch/hermes-agent** (patterns only) - auto "save as skill", usage sidecar, curator archive.
7. **NandhaKishorM/laya** + **TypeSafe Jev** (via OpenRouter) - System-1 decisions for block pick and human gates. Jev primary when online; Laya local fallback after fine-tune.
8. **BloopAI/vibe-kanban** (UX patterns) + our board - multi-chat/rooms inspiration without adopting the whole app.
9. **langfuse/langfuse** - self-host audit traces; pair with our SQLite decision timeline.
10. **ollama/ollama** - local models in the same pool; chores and private jobs.

Honorable mentions (use when needed): ccusage (offline cost), E2B (real sandboxes), Playwright/axe-core (checks), n8n/Slack Bolt (triggers), promptfoo (eval), OpenUsage/CodeBurn (extra usage UIs).

## What we still write ourselves

1. Thin task board: `POST /cards`, queues per block, multi-chat thread store.
2. Job router: rules → Jev/Laya → ask-user; writes a decision record every time.
3. Model router + credit ledger: CodexBar/ccusage JSON + monthly caps + P0/P1/P2 tiers.
4. Block registry loader (`blocks/*/SKILL.md` + `block.yaml`) and prompt→block builder with approve gate.
5. One MCP tool `run_cli_agent(agent, task, worktree)` that enforces budget before ACP launch.
6. Dashboard panel: card timeline (chosen, runners-up, reason, cost, confidence).

## Architecture (one page)

```
Trigger (Slack/API/phone/n8n)
        │
        ▼
   Board + chats  ──────────── sessions per card/block
        │
        ▼
   Job router (rules → Jev/Laya → ask)
        │
        ▼
   Block(s) from registry
        │
        ▼
   Model router (pool + CodexBar credits + priority)
        │
        ├─ Claude orchestrator ──MCP──► ACP workers (Codex/Cursor/Gemini/opencode/pi)
        │                                      │
        │                                      ▼
        │                               git worktree / E2B room
        │                                      │
        └──────── checks (Playwright/axe/scripts) ── retry ── judge
                                                       │
                                                       ▼
                                              Langfuse + SQLite timeline
```

## Routing policy (short)

1. Explicit block or model name on the card always wins.
2. Else job router: tags, then Jev choice over block descriptions; ask if top p < 0.7.
3. Model router: filter by capabilities, privacy, remaining credits; score by fit × priority × budget.
4. P0 hard jobs → Claude Opus + best CLI; P2 chores → local Ollama.
5. Provider under 20% of cap: score halved. Under 5%: skipped and you are told.
6. Never let the LLM spend past the card budget; the MCP tool refuses.

## Multi-chat

1. Each card has a primary thread.
2. Each block run can open a child thread (designer chat ≠ checker chat).
3. Sessions persist (SQLite or acpx-style ACP session ids).
4. UI can borrow CloudCLI / vibe-kanban patterns; our API stays the source of truth.

## Credits integration (concrete)

1. Prefer `codexbar serve` or `codexbar usage --format json` as the live feed.
2. Prefer `ccusage ... --json` for local historical cost by tool.
3. OpenRouter `GET /api/v1/credits` as a secondary live balance.
4. Anthropic/OpenAI Admin cost APIs reconcile the ledger; they are not a wallet balance.
5. Ledger is ours; providers only update it.

## Build order on your PC (estimate ~8 hours once you approve)

1. Scaffold repo, board API, SQLite decision log (1 h).
2. Wire CodexBar/ccusage into the ledger (1 h).
3. LiteLLM pool + Ollama stub (1 h).
4. Job router with Jev (or Laya-only if you skip the key) (1 h).
5. ACP client + Claude MCP tool for one worker (Codex or opencode) (2 h).
6. Skills-based block registry + Hermes-style suggest/curator (1.5 h).
7. Dashboard timeline + Langfuse optional (0.5 h).

## Explicit non-goals

1. Do not fork Hermes, OpenHands, or vibe-kanban as the core.
2. Do not let Claude choose spend without the ledger gate.
3. Do not require Docker/E2B on day one (worktrees first).
