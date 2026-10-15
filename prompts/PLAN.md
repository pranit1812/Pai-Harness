# Plan prompt for Pai-Harness (for a planning-only model)

You are a planner. You cannot run code, install anything, or test anything, and you do not need to.
Your output is text only: a critique, a plan, and three draft documents that a separate coding
agent (Claude Code, Opus) will later follow. Write everything in plain Markdown in your reply.
If you cannot open a file, say which one and continue with what you have.

## The concept (read first, do not re-decide)
Pai-Harness is a local "software factory" for one developer who uses many AI coding tools.
1. A job (card) arrives from chat, API, Slack or phone and lands on a task board.
2. A job router picks the right block for the card. A block is a reusable Lego brick:
   agent does the work, deterministic code checks run, a failed check sends it back,
   a judge agent in a fresh context reviews it, and the human verifies only at the end.
3. A model router picks the right model or CLI for that block from a pool:
   subscription plans first, then free quotas, then local models (Ollama). No dollar caps.
4. Claude is the orchestrator. It calls Codex CLI, Cursor CLI, Gemini CLI, opencode, pi and
   others as workers through ACP (Agent Client Protocol). Code, not the model, owns budgets.
5. Users create new blocks by prompting. Blocks use the SKILL.md format. After hard tasks the
   system suggests "save as a block?" (Hermes Agent style) and archives unused blocks.
6. Every decision is auditable: chosen option, scored alternatives, reason, cost, and whether
   the user was asked. Visible per card in the UI.

## Locked decisions
1. Decision model: Laya (local, open weights). No paid decision APIs.
2. Usage and limits: CodexBar and ccusage, route away from a plan near its limit.
3. Worker protocol: ACP. MCP for tools exposed to the orchestrator.
4. Parallel work: one git worktree per worker. Sandbox (Docker/E2B) optional later.
5. Runs locally on macOS and Windows. One-click setup already exists (setup.sh, setup.ps1).

## Frontend goal
A desktop-quality app at the level of the Codex app or better:
1. Left: projects, each with its own chats (multi-chat, persistent sessions).
2. Center: the task board (new, routed, running, needs review, done) with live cards.
3. Right: inspector for the selected card: routing decision timeline, model and CLI used,
   checks and judge results, diff preview, usage meters per provider.
4. Approve, reject, retry, or "save as block" actions on every finished card.
5. A block library page: browse, create by prompt, test, approve.

## Read in this order
1. README.md
2. docs/problem-map.md, docs/venn.md, docs/stitch-plan.md
3. docs/free-clis.md, docs/usage-tools.md
4. docs/archive/factory-design/v2/design.md
5. prototype/ (stdlib Python mock, for concepts only)

## What I want back
1. Critique: up to 5 things in the concept or decisions that are wrong or risky, with evidence.
   Propose a fix for each. Keep the locked decisions unless something truly blocks.
2. Architecture: processes, languages, frameworks, and the main data shapes
   (card, block manifest, model pool, decision record). Pick a frontend stack and say why.
3. Repo choices: which open source repos to use directly vs only borrow ideas from. Use the
   repos already listed in docs/stitch-plan.md and docs/problem-map.md (they were verified on
   15 Oct 2026). Only add a new one if you are sure it exists; mark it "unverified".
4. Milestones: 8 to 12 milestones for the coding agent, each about 60 to 120 minutes, each with
   acceptance criteria the coding agent can check itself (it will use a fake ACP agent so no paid
   agent is needed). You only describe the checks; you do not run them.
5. Three draft documents, each in its own fenced Markdown block so I can copy them into files:
   docs/SPEC.md (frozen-spec style), CLAUDE.md (rules for the coding agent), and
   prompts/KICKOFF.md (one paste-in prompt per milestone).

## Format of your reply
1. Critique (max 5 items)
2. Architecture and stack (short)
3. Repo choices (table)
4. Milestones (table: id, name, minutes, acceptance criteria)
5. The three draft documents (fenced blocks)

## Style
Simple English. Short sentences. Numbered lists, max 5 items per group. No em dashes.
Do not summarise this prompt back to me.
