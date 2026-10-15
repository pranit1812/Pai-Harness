# Problem map: software factory

Verified live on 15 Oct 2026 (Europe/London). Stars and last-push from GitHub API.
ADHD layout: numbered, max 5 items per group. No em dashes.

## 0. Whole problem in one sentence

One place where a job lands, the right block and model are chosen from your pool (cloud + local + coding CLIs), Claude can orchestrate subagents, credits steer the pick, every decision is auditable, and you can create new blocks by prompting.

## 1. Job / task board + multi-chat

Need: cards on a board, separate conversation threads per project or agent, session persistence across restarts.

1. [BloopAI/vibe-kanban](https://github.com/BloopAI/vibe-kanban) - 28.4k ★, pushed 2026-09-19. Web kanban, one worktree per issue, multi-agent. Gap: no credit-aware routing.
2. [smtg-ai/claude-squad](https://github.com/smtg-ai/claude-squad) - 8.6k ★, pushed 2026-08-20. TUI, tmux + worktree per agent. Gap: terminal only, no router.
3. [siteboon/claudecodeui](https://github.com/siteboon/claudecodeui) (CloudCLI) - 14.1k ★, pushed 2026-10-15. Web/mobile chat for Claude, Codex, Cursor, Gemini, OpenCode. Gap: chat shell, not a factory.
4. [openclaw/acpx](https://github.com/openclaw/acpx) - 3.3k ★, pushed 2026-10-15. Headless ACP client with stateful sessions. Gap: protocol client, not a board.
5. [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph) - 43.3k ★, pushed 2026-10-15. Durable graphs and checkpoints. Gap: heavy runtime if used as the whole stack.

We still write: thin `POST /cards` board API and a thread store keyed by card + block.

## 2. Job routing (which block)

Need: send each card to the right block or pipeline; ask the user when confidence is low.

1. [TypeSafe Jev](https://openrouter.ai/docs/guides/community/jev) via OpenRouter Decisions API - hosted System-1, choice/score/yes-no with probabilities. Gap: paid, closed weights; weak at zero-shot model pick without your data.
2. [NandhaKishorM/laya](https://github.com/NandhaKishorM/laya) - 33.0k ★, pushed 2026-10-15. Local Apache-2.0 System-1 (~33 ms). Gap: weaker zero-shot; needs fine-tune on your logs.
3. [katanemo/plano](https://github.com/katanemo/plano) - 7.1k ★, pushed 2026-10-07. Preference-policy router + Arch-Router. Gap: generative, heavier than encoders.
4. [vllm-project/semantic-router](https://github.com/vllm-project/semantic-router) - 6.2k ★, pushed 2026-10-15. Programmable decision layer for models/compute. Gap: infra-heavy.
5. Tag/keyword rules in our code - free, instant, auditable. Gap: not semantic.

## 3. Model routing / decision APIs

Need: pick the right LLM or coding CLI from your pool, with budget and priority.

1. Jev + [typesafe/jev-router](https://openrouter.ai/docs/guides/routing/routers/jev-router) on OpenRouter - can pick model + reasoning tier. Gap: their pool bias; still train a head on your runs for best results.
2. Laya local - free, private. Gap: fine-tune required for model pick quality.
3. [BerriAI/litellm](https://github.com/BerriAI/litellm) - 61.3k ★, pushed 2026-10-15. Gateway to 100+ APIs + Jev pass-through + budgets. Gap: not a decision brain by itself.
4. [ulab-uiuc/LLMRouter](https://github.com/ulab-uiuc/LLMRouter) - 3.0k ★, pushed 2026-10-09. Research library of routers. Gap: library, not productized.
5. [lm-sys/RouteLLM](https://github.com/lm-sys/RouteLLM) - 5.6k ★, last push 2024-08-10. Classic idea. Gap: stale; use as reference only.

Evidence: arXiv 2610.02267 and RouterArena/LLMRouterBench say curated pools + trained heads beat big zero-shot routers.

## 4. Credit / quota / usage visibility

Prior mistake corrected: this is not OpenRouter-only. Many tools read Claude Code, Codex, Cursor, Gemini locally.

1. [steipete/CodexBar](https://github.com/steipete/CodexBar) - 22.5k ★, pushed 2026-10-15. Menu bar + `codexbar` CLI + `codexbar serve` HTTP JSON. 100+ providers including Claude, Codex, Cursor, Gemini, OpenRouter, TypeSafe, OpenCode, Pi. Gap: macOS app primary; Linux CLI exists.
2. [ccusage/ccusage](https://github.com/ccusage/ccusage) - 19.0k ★, pushed 2026-10-15. Local CLI over Claude, Codex, OpenCode, Hermes, pi, Gemini, Copilot, and more. Gap: local logs only (no live plan quotas unless combined).
3. [getAgentSeal/codeburn](https://github.com/getAgentSeal/codeburn) - 11.5k ★, pushed 2026-10-15. Desktop + CLI + VS Code for ~37 to 42 tools. Gap: product surface is broad; wire carefully.
4. [janekbaraniewski/openusage](https://github.com/janekbaraniewski/openusage) - 225 ★, pushed 2026-10-13. Terminal dashboard, 35+ tools, Prometheus optional. Gap: younger project.
5. Siblings: [nesszer/Win-CodexBar](https://github.com/nesszer/Win-CodexBar) (1.2k ★, Windows), [VincentShipsIt/meterbar.dev](https://github.com/VincentShipsIt/meterbar.dev) (MeterBar, Claude/Codex/Cursor menu bar), [Maciek-roboblog/Claude-Code-Usage-Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor) (8.7k ★, Claude-focused).

We still write: a credit ledger that polls CodexBar/`ccusage` JSON, plus your monthly caps, used by the model router.

## 5. Orchestrator + subagent CLIs (ACP / MCP)

Need: Claude plans; Codex, Cursor, Gemini, opencode, pi execute in rooms.

1. [anthropics/claude-code](https://github.com/anthropics/claude-code) - 151k ★, pushed 2026-10-14. Best planner + native subagents/skills. Gap: Claude models only inside one session.
2. [agentclientprotocol/agent-client-protocol](https://github.com/agentclientprotocol/agent-client-protocol) - 4.5k ★, pushed 2026-10-15. Shared JSON-RPC protocol. Registry lists Claude, Codex, Cursor, Gemini, OpenCode, Pi, Hermes, Goose, OpenHands, and more.
3. Workers: [openai/codex](https://github.com/openai/codex) 129k ★ · [anomalyco/opencode](https://github.com/anomalyco/opencode) 214k ★ · [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) 107k ★ · [earendil-works/pi](https://github.com/earendil-works/pi) 115k ★. All ACP-reachable.
4. [openai/openai-agents-python](https://github.com/openai/openai-agents-python) - 30.1k ★. Handoffs and guardrails pattern. Gap: OpenAI-centric if used as runtime.
5. [aaif-goose/goose](https://github.com/aaif-goose/goose) - 55.3k ★. MCP-native recipes. Gap: general agent, not our board.

We still write: one MCP tool `run_cli_agent` that the harness owns (budget inside code, not the LLM).

## 6. Sandboxes / worktrees / rooms

Need: parallel workers, isolated copies, merge or pick winner.

1. Native `git worktree` - already in the prototype. Gap: no network/FS jail.
2. [e2b-dev/E2B](https://github.com/e2b-dev/E2B) - 14.4k ★, pushed 2026-10-14. Cloud sandboxes for agents. Gap: hosted cost.
3. [OpenHands/OpenHands](https://github.com/OpenHands/OpenHands) - 91.0k ★. Full sandboxed platform. Gap: too heavy to adopt wholesale.
4. [frankbria/parallel-cc](https://github.com/frankbria/parallel-cc) - 14 ★. Worktrees + optional E2B multi-run. Gap: young, Claude-centric.
5. [dagger/dagger](https://github.com/dagger/dagger) - 16.3k ★. Portable pipelines/containers. Gap: CI-shaped, not chat-shaped.

## 7. Block / skill registry + builder + Hermes-style auto-suggest

Need: create blocks by prompt, test them, approve, archive unused ones.

1. [anthropics/skills](https://github.com/anthropics/skills) - 181k ★, pushed 2026-10-09. SKILL.md format + skill-creator. Gap: format only, no factory board.
2. [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) - 254k ★, pushed 2026-10-15. Learn-to-skill, skill retrieval, curator (stale → archive, never delete). Gap: full agent product; copy patterns, do not fork the app.
3. [ShengranHu/ADAS](https://github.com/ShengranHu/ADAS) - 1.6k ★, last 2025-01-28. Meta-agent designs agents. Gap: research code.
4. [a2aproject/A2A](https://github.com/a2aproject/A2A) - 26.2k ★. Publish blocks as callable agent cards later. Gap: protocol overhead day one.
5. [modelcontextprotocol/registry](https://github.com/modelcontextprotocol/registry) - 7.4k ★. Tool discovery. Gap: tools ≠ skills.

## 8. Deterministic checks + judges

Need: code checks first; LLM judge only on finished artifacts.

1. [microsoft/playwright](https://github.com/microsoft/playwright) - 97.8k ★. Browser/UI checks.
2. [dequelabs/axe-core](https://github.com/dequelabs/axe-core) - 7.7k ★. Accessibility.
3. [promptfoo/promptfoo](https://github.com/promptfoo/promptfoo) - 26.0k ★. Prompt/agent eval harness.
4. [strongdm/attractor](https://github.com/strongdm/attractor) - 1.3k ★. Spec-driven "checks over reading code" idea.
5. Per-block shell scripts in `block.yaml` - our glue.

## 9. Audit / observability / decision timeline

Need: every block/model pick shows chosen, runners-up, reason, cost, who decided.

1. [langfuse/langfuse](https://github.com/langfuse/langfuse) - 35.9k ★, pushed 2026-10-15. Self-host traces, costs, evals. Gap: needs OTel wiring.
2. [Arize-ai/phoenix](https://github.com/Arize-ai/phoenix) - 11.9k ★. OpenInference/OTel. Gap: more eval-lab than product dashboard.
3. [open-telemetry/semantic-conventions](https://github.com/open-telemetry/semantic-conventions) GenAI - vendor-neutral span shapes.
4. SQLite decision table in our harness - one row per choice for the card timeline.
5. CodexBar `serve` / ccusage JSON - feed spend into the same timeline.

## 10. Local models

1. [ollama/ollama](https://github.com/ollama/ollama) - 183k ★. Easiest local OpenAI-compatible server.
2. [vllm-project/vllm](https://github.com/vllm-project/vllm) - 93.9k ★. High throughput when you have GPU.
3. [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) - 131k ★. Lean local inference.
4. LiteLLM pointing at local endpoints - one pool for cloud and local.
5. Laya on-device for free routing decisions.

## 11. Triggers (Slack, API, phone)

1. Our `POST /cards` - already in the prototype.
2. [n8n-io/n8n](https://github.com/n8n-io/n8n) - 207k ★. Visual workflows into the API.
3. [slackapi/bolt-python](https://github.com/slackapi/bolt-python) - 1.3k ★. Slack → card.
4. [temporalio/temporal](https://github.com/temporalio/temporal) - 23.7k ★. Durable job queues if you outgrow SQLite.
5. Phone: CloudCLI / claudecodeui already mobile-friendly; or webhook + ntfy-style push.

## 12. Dashboard / UI

1. vibe-kanban patterns for board + review.
2. claudecodeui / CloudCLI for multi-agent chat on desktop and phone.
3. [open-webui/open-webui](https://github.com/open-webui/open-webui) - 156k ★. Chat shell over Ollama/OpenAI. Gap: not agent-factory shaped.
4. [lobehub/lobehub](https://github.com/lobehub/lobehub) - 83.2k ★. Multi-agent operator UI. Gap: heavy product.
5. Prototype dashboard on :8787 - keep as the decision-timeline home until replaced.

## 13. Extra areas worth naming

1. Session/thread store (card ↔ chat history).
2. Priority tiers (P0 hard → Claude; P2 chores → local).
3. Human gates (ask when confidence/budget/new block).
4. Learning loop (reweight from run log weekly).
5. Provider status (CodexBar incidents) so we skip outages.

## Source note

Stars and push dates from `https://api.github.com/repos/...` on 15 Oct 2026. Raw TSV: `research/meta.tsv`.
