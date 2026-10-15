# Venn / overlap view

Companion to `docs/venn.png` (landscape 3093×2113). Verified 15 Oct 2026.

## How to read the diagram

1. Twelve problem areas sit in a grid. Gold bullets are the stitch core. Cyan bullets are strong adjacent options.
2. The bottom-right box is what we still write: thin glue, not another platform.
3. The five gold-bordered cards at the bottom are the biggest overlaps (one repo covering several areas).

## Overlap clusters (text Venn)

### Cluster A - Credits ∩ Audit ∩ Routing feed
Repos in the middle: **CodexBar** (`codexbar usage`, `codexbar cost`, `codexbar serve`).
1. Also in Credits only: ccusage, CodeBurn, OpenUsage, Win-CodexBar, MeterBar.
2. Also in Audit only: Langfuse, Phoenix, OTel GenAI, our SQLite decision log.
3. Shared idea: usage JSON becomes both a router input (remaining %) and a timeline row.

### Cluster B - Model pool ∩ Local ∩ Decision APIs
Repos: **LiteLLM**.
1. Cloud + local OpenAI-compatible endpoints in one pool.
2. Jev pass-through / System-One route on the same gateway.
3. Laya sits beside it as the free local decision engine (not a chat model).

### Cluster C - Orchestrator ∩ Workers ∩ Sessions
Repos: **Claude Code / Agent SDK + ACP**.
1. Claude plans and can call one MCP tool we own: `run_cli_agent`.
2. ACP adapters reach Codex, Cursor, Gemini CLI, OpenCode, Pi, Hermes, Goose, and more.
3. acpx / CloudCLI add multi-chat session persistence around those agents.

### Cluster D - Skills ∩ Builder ∩ Learning
Repos: **anthropics/skills format + Hermes Agent patterns**.
1. SKILL.md is the on-disk block shape.
2. Hermes learn → "save as block?"; curator archives after 30 unused days (never deletes).
3. ADAS is the research cousin for meta-design; A2A publishes blocks later.

### Cluster E - Board ∩ Rooms ∩ Multi-chat UX
Repos: **vibe-kanban** (patterns) + our thin board API.
1. claude-squad for terminal-first parallel rooms.
2. git worktrees (already in the prototype) for isolation; E2B when you need a real jail.
3. CloudCLI / claudecodeui when you want phone + web chats on the same agents.

### Cluster F - Checks ∩ Spec-driven factory idea
1. Playwright + axe-core + per-block shell = deterministic gate.
2. StrongDM Attractor / promptfoo = rubric and eval ideas.
3. Judge LLM only sees finished artifacts (fresh context), same as Kem's "block" idea.

## What nothing covers alone

No single repo is a credit-aware, multi-chat, skill-building software factory. Closest partial products:
1. vibe-kanban: board + rooms, no routing or credits.
2. Hermes Agent: skills life cycle, not a multi-provider factory board.
3. OpenHands: sandboxed agents, heavy and not credit-routed.
4. StrongDM Attractor: philosophy and checks, not a runtime.

That is why the stitch plan keeps a thin harness and treats everything else as swappable parts.
