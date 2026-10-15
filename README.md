# Software Factory

Design + research + a small mock prototype for a **credit-aware, multi-chat software factory** on your PC.

Status on 15 Oct 2026: **design and prototype only**. No GitHub remote has been created yet. Parent agent will push when you say so.

## What this is

1. A job lands on a board (API, Slack, phone, or chat).
2. A **job router** picks the right block (designer, checker, …) using rules + System-1 decision models (Jev / Laya).
3. A **model router** picks the right LLM or coding CLI from your pool, using **live usage/credits** (CodexBar, ccusage, …), priority, and budget.
4. **Claude** orchestrates; Codex / Cursor / Gemini / opencode / pi run as **ACP subagents** in git worktree "rooms".
5. Deterministic checks run; a judge reviews finished work; you only verify the end.
6. You can **create new blocks by prompting**; Hermes-style suggestions and curator keep the registry healthy.
7. Every decision is on an **audit timeline**.

## Layout

```
software-factory/
  README.md                 ← you are here
  docs/
    problem-map.md          ← 12 problem areas × verified repos
    venn.md                 ← text overlap clusters
    venn.png                ← big overlap diagram
    stitch-plan.md          ← top 10 stitch + what we write
    archive/factory-design/ ← v1 and v2 design notes
  prototype/factory/        ← earlier mock end-to-end demo
  research/meta.tsv         ← GitHub stars/push dump
```

## Run the mock prototype (optional)

Models are stand-ins. Real keys and Ollama are not required.

```bash
cd prototype/factory
python3 run.py --demo
# dashboard → http://127.0.0.1:8787
```

## Run on your PC (when we build for real)

1. Clone this repo.
2. Install: Ollama (optional local), coding CLIs you use, CodexBar or ccusage for usage.
3. Copy `.env.example` → `.env` (Anthropic / OpenRouter / etc. as you choose).
4. `python3 -m factory` (exact entrypoint lands when the build starts).
5. Open the dashboard; create a card; watch the decision timeline.

## Docs to read first

1. `docs/stitch-plan.md` - what to stitch and what we write.
2. `docs/problem-map.md` - full area × repo table.
3. `docs/venn.png` + `docs/venn.md` - overlaps.
4. `docs/archive/factory-design/v2/design.md` - earlier detailed v2.

## Corrected finding: credits

Usage is **not** OpenRouter-only. Primary tools:

1. [CodexBar](https://github.com/steipete/CodexBar) - https://codexbar.app/ - CLI + `serve` JSON, 100+ providers.
2. [ccusage](https://github.com/ccusage/ccusage) - local cost across Claude, Codex, OpenCode, Hermes, pi, Gemini, …
3. Also: CodeBurn, OpenUsage, Win-CodexBar, MeterBar, Claude-Code-Usage-Monitor.

## Not done yet

1. GitHub remote (parent will create when you approve).
2. Real model wiring and ACP worker loop.
3. Your answers: Jev key vs Laya-only; monthly caps; which CLIs you are logged into.
