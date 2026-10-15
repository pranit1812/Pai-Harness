# Software Factory: Assembly Design
Design only. Builds on the prototype in /workspace/factory. Links checked 15 Oct 2026.

## 1. Core idea
1. A card lands on the board (same simple `POST /cards`).
2. The **Job router** reads it and picks the right block(s): designer, frontend checker, researcher.
3. Each block asks the **Model router** for the best model from your pool: cloud, local or a coding-agent CLI.
4. Block runs: agent, code checks, retry, fresh judge. You verify only the end.
5. Need a new skill? Say "I want a special front-end checker". The **Block builder** writes, tests and registers it.

## 2. Components
1. **Job router.** Matches a card to blocks. Step 1 cheap: tags and keywords. Step 2: small local router model (Arch-Router 1.5B) reading block descriptions. Can chain blocks into a pipeline (designer then frontend checker).
2. **Block registry.** A folder of `blocks/<name>/block.yaml` files, SKILL.md style (Anthropic Agent Skills). Each one is a Lego brick. Exposed as an A2A style agent card so outside agents can call it too.
3. **Model pool + model router.** `pool.yaml` lists every model with capabilities, cost, speed and a local flag. The router scores models against what the block needs. LiteLLM or Plano does the actual calling.
4. **Block builder.** A meta block (ADAS style). From your prompt it drafts the manifest, writes the checks, runs it on 2 to 3 sample cards, and registers it only if it passes. You approve before it goes live.
5. **Board and listeners.** One listener per block, subscribed to its own queue. Router puts the card on that queue. Dashboard shows which block and which model took it.

## 3. Data shapes

### 3.1 Block manifest (`blocks/frontend-checker/block.yaml`)
```yaml
name: frontend-checker
description: Reviews a built page for layout, accessibility and broken links.
triggers: [frontend, ui, html, css, review]
role_prompt: |
  You are a strict front-end reviewer. Report issues as a JSON list.
needs:                 # what the model router matches on
  capabilities: [code, vision]
  min_context: 64000
  prefer_local: false
  max_cost_per_run_usd: 0.50
checks:                # deterministic, code not vibes
  - cmd: npx html-validate output/index.html
  - cmd: npx @axe-core/cli output/index.html --exit
  - cmd: npx linkinator output/
judge:
  rubric: [no_blocking_a11y_issues, mobile_layout_ok, matches_brief]
  pass_score: 8
retries: 2
ask_user: when_cost_over_limit   # or always / never
```

### 3.2 Model pool (`pool.yaml`)
```yaml
models:
  - id: claude-opus
    kind: cloud
    endpoint: litellm/anthropic/claude-opus
    capabilities: [code, reasoning, vision, long_context]
    context: 200000
    cost_per_mtok_usd: {in: 15, out: 75}
    speed: slow
  - id: gpt
    kind: cloud
    endpoint: litellm/openai/gpt
    capabilities: [code, reasoning, vision]
    cost_per_mtok_usd: {in: 2, out: 8}
    speed: medium
  - id: qwen-coder-local
    kind: local
    endpoint: http://localhost:11434/v1   # Ollama
    capabilities: [code]
    context: 32000
    cost_per_mtok_usd: {in: 0, out: 0}
    local: true
  - id: opencode-agent
    kind: agent_cli
    run: opencode run "{prompt}"          # runs inside the worktree
    capabilities: [code, tools, multi_file]
  - id: codex-agent
    kind: agent_cli
    run: codex exec "{prompt}"
    capabilities: [code, tools, multi_file]
```

### 3.3 Card
```json
{
  "title": "Landing page for the FDE demo",
  "body": "Hero, 3 features, mobile first",
  "source": "slack",
  "blocks": ["auto"],
  "model": "auto",
  "budget_usd": 2
}
```
`blocks` and `model` can be named to skip routing. `"auto"` lets the routers decide.

## 4. Routing logic
1. **Card to block.** Explicit block name wins. Else tag match. Else router model picks from block descriptions. Low confidence (under 0.6) means ask you.
2. **Block to model.** Filter pool by `needs` (capabilities, context, budget). Score the rest by capability fit, cost and speed. Prefer local when `prefer_local` or the card is private.
3. **When it asks you.** Top 2 or 3 models are close, cost is over the limit, or the block is brand new. It shows: "I can use Claude, GPT or local Qwen. Pick one or say auto."
4. **Learning.** Every run logs block, model, check pass, judge score and cost. The scorer reweights from that log over time (RouteLLM style, from your own data).
5. **Fan-out.** Important cards still split across 2 to 3 models in parallel worktrees, and the judge picks the winner.

## 5. Recommended repos to stitch
1. **Routing:** [LiteLLM](https://github.com/BerriAI/litellm) as the gateway to every model. [Plano](https://github.com/katanemo/plano) plus [Arch-Router-1.5B](https://huggingface.co/katanemo/Arch-Router-1.5B) for preference based routing with a tiny local model. [vLLM Semantic Router](https://github.com/vllm-project/semantic-router) and [LLMRouter](https://github.com/ulab-uiuc/LLMRouter) for learned routing. [RouteLLM](https://github.com/lm-sys/RouteLLM) is the classic idea but stale since Aug 2024.
2. **Hosted routing to compare:** [OpenRouter Auto Router](https://openrouter.ai/docs/guides/routing/routers/auto-router) and [Not Diamond](https://github.com/Not-Diamond/notdiamond-python).
3. **Block format and registry:** [Anthropic Agent Skills](https://github.com/anthropics/skills) for the SKILL.md shape. [MCP Registry](https://github.com/modelcontextprotocol/registry) for tools. [A2A](https://github.com/a2aproject/A2A) agent cards so blocks are callable. [OpenAI Agents SDK](https://github.com/openai/openai-agents-python) handoffs as the pattern for block to block hand-off.
4. **Self-building blocks and factory pattern:** [ADAS](https://github.com/ShengranHu/ADAS) (meta agent that designs agents). [StrongDM Software Factory](https://factory.strongdm.ai/) and its [Attractor](https://github.com/strongdm/attractor) spec for the "no human reads the code, checks do" model.
5. **Workers and sandboxes:** [opencode](https://github.com/anomalyco/opencode) and [Codex CLI](https://github.com/openai/codex) as agent CLIs. [Ollama](https://github.com/ollama/ollama) for local. [E2B](https://github.com/e2b-dev/E2B) for cloud sandboxes.

## 6. Build order
1. **Block registry + manifest loader** (45 min). Move the current landing page pipeline into `blocks/*/block.yaml`.
2. **Model pool + scorer** (1 hr). `pool.yaml`, filter and score, call through LiteLLM. Add the "ask me" prompt on the dashboard.
3. **Job router** (1 hr). Tags first, then Arch-Router via Ollama. Per-block queues and listeners.
4. **Block builder** (1.5 hr). Prompt to manifest, dry run on sample cards, approve button, register.
5. **Run log + learning** (1 hr). Log every run, reweight scores, show "best model per block" on the dashboard.
