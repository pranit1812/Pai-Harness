# Software Factory Design v2
Design only. All links checked 15 Oct 2026 (UTC+1). Builds on v1 and the prototype in /workspace/factory.

## 0. What changed from v1
1. Router brain is now a **decision model** (Jev or Laya) plus your own trained head, not a guess.
2. Every decision is **logged and visible**: why this block, why this model, the runners up, credits spent.
3. Routing is **budget aware** with priority tiers. Claude orchestrates and drives coding CLIs over **ACP**.
4. Block builder copies **Agent Skills (SKILL.md)** and **Hermes Agent's** learn plus curator loop.
5. Harness choices are backed by a verdict table (section 7).

## 1. Jev and Laya (your "laya or jev")
These are real products, not typos. Both are "System One" decision models: you send a state plus typed questions (choice, score, yes/no) and get back calibrated probabilities in one pass, no generated text.
1. **Jev** by TypeSafe AI. Closed hosted API, `POST https://api.typesafe.ai/v1/systemone`, model `jev-latest` (1.13) or `jev-preview` (1.14). Launched Sep 2026. [typesafe.ai](https://typesafe.ai/), [API docs](https://docs.typesafe.ai/api).
2. **Laya** by Convai Innovations. Open weights, Apache 2.0, 421M ModernBERT encoder (plus 322M multilingual), about 33 ms per call, `pip install laya`. Released Sep 2026. [HF model](https://huggingface.co/convaiinnovations/laya), [GitHub](https://github.com/NandhaKishorM/laya).
3. **Honest evidence.** Independent tests say Jev is clearly stronger zero shot. A paired study found Jev more accurate on 9 of 11 agent decision points, and **neither beat chance on zero-shot model routing** ([arXiv 2610.02267](https://arxiv.org/abs/2610.02267)). Nadir found a length rule beat both zero shot Laya and GLiNER2; a trained head on top won ([Nadir blog](https://getnadir.com/blog/jev-laya-gliner-decision-models-llm-routing-benchmark/)). TextCortex: Jev 84.5% vs best Laya 61.6% on tiers ([jays.fyi](https://jays.fyi/blog/local-llm-routers-lost-to-always-answering-medium)). Another bench: [system-one-router](https://mmornati.github.io/system-one-router/).
4. **Verdict.** Use them where they are strong: **picking a block** (choice among few labels) and **gates** (needs a human? is this risky?). For **picking a model**, use rules plus a head trained on your own run log. Jev first (accuracy), Laya as the free local fallback after fine tuning on your logged decisions.
5. Caution: `jevtypesafeai.com` looks like a third party proxy, not TypeSafe. Use the official endpoint.

### 1.1 Router candidates compared
| Option | Type | Good for | Weak at | Use it? |
|---|---|---|---|---|
| Jev | hosted decision API | block choice, gates, calibrated confidence | zero shot model routing, EU hosting | Yes, primary for job routing |
| Laya | open 421M encoder | free, fast, local, private | zero shot accuracy, many labels, order bias | Yes, local fallback after fine tune |
| Arch-Router 1.5B (Plano) | open generative router | preference policies like "code gen -> Claude" | slower than encoders | Optional, if you run Plano |
| NVIDIA llm-router | blueprint | intent or trained NN router | heavy stack (Triton) | Borrow ideas only |
| OpenRouter Auto, Not Diamond | hosted model routers | zero setup | black box, their pool not yours | Skip as core |

## 2. Core idea
1. Card lands on the board (`POST /cards`, unchanged).
2. **Job router** asks Jev "which block?" and gets probabilities. Low confidence means it asks you.
3. **Model router** filters your pool by needs, budget and priority tier, then scores. Close call means it asks you.
4. **Claude orchestrator** runs the block and hands coding work to CLI subagents (Cursor, Codex, opencode, Gemini, pi) over ACP.
5. Every step writes an OpenTelemetry span. The dashboard shows the full decision trail per card.

## 3. Components
1. **Job router.** Rules first (explicit block, tags). Then Jev `choice` over block descriptions. Then you, if top probability is under 0.7.
2. **Model router plus ledger.** Pool YAML plus a **credit ledger** per provider. Hard filters (capability, budget, privacy), then a score. Writes the full scorecard to the decision log.
3. **Orchestrator plus CLI subagents.** Claude (via Claude Agent SDK or Claude Code) is the planner. Each coding CLI is an ACP agent the harness launches in its own git worktree.
4. **Block registry and builder.** Blocks are SKILL.md folders plus a `block.yaml` for checks and routing needs. Builder follows Anthropic's skill-creator pattern and Hermes' learn and curator loop.
5. **Audit layer.** OTel GenAI spans exported to Langfuse (self host) or Phoenix. SQLite decision table for the dashboard.

## 4. Credit and priority routing
### 4.1 Can each balance be read by API?
| Provider | Balance or usage API | How we track |
|---|---|---|
| OpenRouter | Yes: `GET /api/v1/credits` and `/api/v1/key` ([docs](https://openrouter.ai/docs/api/api-reference/credits/get-remaining-credits)) | poll live |
| Anthropic | Cost history only, Admin API cost report ([docs](https://docs.anthropic.com/en/api/admin-api/usage-cost/get-cost-report)), no balance | you set monthly cap, we subtract |
| OpenAI | Admin usage and costs endpoints, no balance endpoint found | you set cap, we subtract |
| Gemini, Cursor, Codex plan | No public balance API found | count per run from CLI JSON output, local cap |
| Local (Ollama, vLLM) | free | cost 0, limited by GPU queue |
Rule: **the ledger is ours.** Provider APIs only reconcile it. Every run records tokens and cost from the CLI or API response.

### 4.2 Priority tiers
1. **P0 hard project:** Claude Opus orchestrates, best coding CLI executes, 3 way split allowed.
2. **P1 normal:** Sonnet or GPT class, single worker, cheap judge.
3. **P2 chores:** local model or cheapest CLI, no split.
4. **Budget guard:** when a provider drops under 20% of its cap, its score halves. Under 5%, it is removed and you are told.
5. **Always ask** when the pick costs over the card budget or a P0 card would fall back to a weaker model.

### 4.3 Claude as orchestrator: is that the best pattern?
1. Your idea is mostly right. The better version: **the harness owns routing and budget, Claude owns planning**. Do not let an LLM decide spend; code does.
2. **Use ACP to talk to CLIs**, not ad hoc shell parsing. Claude, Codex, Gemini CLI, opencode, Cursor and pi (via pi-acp) are all ACP agents ([ACP agents list](https://agentclientprotocol.com/get-started/agents), [registry](https://agentclientprotocol.com/get-started/registry)). One client, many agents, streaming, cancel.
3. Expose "run_cli_agent(agent, task, worktree)" to Claude as **one MCP tool**. The tool asks the model router which CLI, so budget logic stays in code.
4. Fallback where ACP is missing: headless flags. `claude -p --output-format json`, `codex exec --json`, `gemini -p`, `cursor-agent -p --output-format json` ([Cursor headless](https://cursor.com/docs/cli/headless)), `opencode run`, `pi -p`. Pin versions; flags move fast.
5. Claude Code native subagents ([docs](https://docs.claude.com/en/docs/claude-code/sub-agents)) are fine inside one Claude session, but they only use Claude models. Cross vendor work goes through ACP.

## 5. Audit trail (every card, visible)
1. **Standard:** [OpenTelemetry GenAI semantic conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) for model calls, agent and tool spans. Vendor neutral.
2. **Backend:** [Langfuse](https://github.com/langfuse/langfuse) self hosted (traces, costs, evals) or [Phoenix](https://github.com/Arize-ai/phoenix). Both ingest OTel.
3. **Decision record per step** (stored in SQLite and as span attributes):
```json
{"card": 42, "step": "model_route", "chosen": "claude-opus",
 "candidates": [{"id":"claude-opus","score":0.81},{"id":"gpt","score":0.74},{"id":"qwen-local","score":0.31,"rejected":"no vision"}],
 "reason": "P0 card, needs vision, Anthropic 62% credit left",
 "decider": "rules+jev-1.13", "confidence": 0.88,
 "cost_usd": 0.42, "tokens": {"in": 18000, "out": 4100}, "asked_user": false}
```
4. **Dashboard:** card timeline: block choice, model choice, runners up, checks, judge score, cost. One click to the full trace.
5. **Replay:** every decision is reproducible from the log, so you can retrain the router head on it.

## 6. Block builder (skills done properly)
### 6.1 What to copy from the ecosystem
1. **Agent Skills format** ([anthropics/skills](https://github.com/anthropics/skills)): folder with SKILL.md (name, description in frontmatter), scripts, references. Progressive loading: only descriptions sit in context. Use its **skill-creator** skill as the builder's template.
2. **Claude Code subagents and plugins:** subagent = role prompt plus tool allowlist plus model. Plugins bundle skills, subagents, hooks and MCP servers. Our block maps 1 to 1.
3. **Cursor rules / AGENTS.md:** per repo guidance the CLIs already read. Blocks can ship one.
4. **OpenAI Agents SDK** ([repo](https://github.com/openai/openai-agents-python)): handoffs and guardrails as the pattern for block to block passing.
5. **A2A / ACP:** publish a block as an agent others can call later. Not needed day one.

### 6.2 Hermes Agent: what it does, what we copy
[Hermes Agent](https://github.com/NousResearch/hermes-agent) (254k stars) treats skills as procedural memory.
1. **Learn:** after a complex task it offers to save the procedure and pitfalls as a SKILL.md via its `skill_manage` tool. **Copy:** after a card succeeds with retries, suggest "save as block?".
2. **Cheap loading:** list skills (names only), view one when needed. **Copy** for the job router's block list.
3. **Usage sidecar:** use count and last used in a separate JSON. **Copy:** feeds router priors and pruning.
4. **Curator** ([docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/curator)): unused 14 days goes stale, 30 days archived, never deleted; optional LLM pass merges duplicates. **Copy** both, with merge off by default.
5. **Skip:** agent editing blocks silently. Ours always needs your approve click and a passing test run.

### 6.3 Builder flow
1. You: "I want a special front-end checker".
2. Builder (skill-creator style) drafts SKILL.md, `block.yaml` (needs, checks, rubric) and 3 test cards.
3. Runs it on the test cards in a sandbox. Checks must pass and the judge must agree.
4. Shows you the diff and the run cost. You approve.
5. Registered; Jev router sees its description next card.

## 7. Harness verdict (evidence based)
| Harness | Strength | Weakness | Borrow | Skip |
|---|---|---|---|---|
| Claude Code ([repo](https://github.com/anthropics/claude-code)) | best planning, subagents, skills, hooks | Claude models only | orchestrator, skills format | using it for cheap chores |
| Codex CLI ([repo](https://github.com/openai/codex)) | strong exec mode, sandboxing | OpenAI only | worker for P0/P1 | |
| opencode ([repo](https://github.com/anomalyco/opencode)) | any provider incl. local, ACP | quality depends on model | local model worker | |
| Cursor agent CLI ([docs](https://cursor.com/docs/cli/headless)) | uses your Cursor plan, ACP | no balance API | worker when Cursor credit is spare | |
| pi ([repo](https://github.com/earendil-works/pi), 115k stars) | tiny, hackable, many providers | fewer batteries | minimal worker, RPC mode | |
| Gemini CLI ([repo](https://github.com/google-gemini/gemini-cli)) | long context, free tier | weaker at hard edits | big repo reading block | |
| OpenHands ([repo](https://github.com/OpenHands/OpenHands)) | full sandboxed platform | heavy | sandbox ideas | running whole platform |
| goose ([repo](https://github.com/aaif-goose/goose)) | MCP native, recipes | general purpose | recipe format idea | |
| Amp, Factory droids ([amp](https://ampcode.com), [factory](https://factory.ai)) | polished, multi agent | closed, paid | UX ideas | as core |
| StrongDM Attractor ([repo](https://github.com/strongdm/attractor)) | spec driven, checks over reading code | spec, not a runtime | scenario tests as checks | |
| Vibe Kanban, Claude Squad, Conductor ([vk](https://github.com/BloopAI/vibe-kanban), [cs](https://github.com/smtg-ai/claude-squad), [conductor](https://conductor.build)) | board plus worktrees per agent | no routing or budget | board and worktree UX (you already have it) | |
| LangGraph ([repo](https://github.com/langchain-ai/langgraph)) | durable graphs, checkpoints | heavy for this | retry and checkpoint ideas | as runtime |
Bottom line: **do not adopt one harness.** Keep your thin board, add ACP clients, use Claude Code as orchestrator and the others as swappable workers.

## 8. Router research 2025 to 2026
1. **Arch-Router** ([arXiv 2506.16655](https://arxiv.org/abs/2506.16655)): preference policies beat benchmark-only routing for real users.
2. **RouterEval** ([arXiv 2503.10657](https://arxiv.org/abs/2503.10657)): routing scales with pool size, but most routers leave lots on the table.
3. **RouterArena** ([arXiv 2510.00202](https://arxiv.org/abs/2510.00202), [repo](https://github.com/RouteWorks/RouterArena)): live router leaderboard.
4. **LLMRouterBench** ([arXiv 2601.07206](https://arxiv.org/abs/2601.07206), [repo](https://github.com/ynulihao/LLMRouterBench)): many routers, including commercial ones, do not reliably beat a simple baseline; careful pool curation beats a big pool.
5. **System-1 decision models audit** ([arXiv 2610.02267](https://arxiv.org/abs/2610.02267)): Jev beats Laya; neither routes models zero shot.
Takeaway: **small curated pool, rules plus a head trained on your own logs, calibrated confidence for asking you.**

## 9. Build order
1. **Decision log plus OTel to Langfuse** (1.5 hr). Audit first, so everything after is visible.
2. **Pool plus credit ledger plus tiers** (1.5 hr). OpenRouter live poll, caps for the rest.
3. **Job router with Jev, ask on low confidence** (1 hr). Laya stub as offline fallback.
4. **ACP client plus one MCP tool for Claude** (2 hr). Start with Codex and opencode, then Cursor, Gemini, pi.
5. **Block builder plus curator** (2 hr). Then retrain the router head weekly from the log.
