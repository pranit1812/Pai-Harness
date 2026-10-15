# Usage / credits tools (CodexBar and siblings)

Verified 15 Oct 2026. Corrects the earlier claim that only OpenRouter exposes credits.

## Ranked for our factory

1. **CodexBar** - https://github.com/steipete/CodexBar · https://codexbar.app/ · 22.5k ★ · pushed today
 - Menu bar (macOS) + Linux/macOS CLI tarballs.
 - `codexbar usage`, `codexbar cost`, `codexbar serve` (HTTP JSON for scripts).
 - Providers include Codex, Claude, Cursor, Gemini, OpenRouter, OpenCode, TypeSafe, Pi, Copilot, and ~100 more.
 - Reuses existing sessions (OAuth, cookies, CLI login); no new passwords stored.
 - Best fit as the **live quota feed** for the model router.

2. **ccusage** - https://github.com/ccusage/ccusage · 19.0k ★ · pushed today
 - `bunx ccusage daily` (and weekly/monthly/session/blocks).
 - Reads local logs for Claude Code, Codex, OpenCode, Hermes, pi, Gemini CLI, Copilot, Amp, Goose, …
 - Best fit as the **historical cost** feed and Claude 5-hour block monitor.

3. **CodeBurn** - https://github.com/getAgentSeal/codeburn · 11.5k ★
 - Desktop, menu bar, CLI (`npx codeburn`), VS Code. Broad tool coverage.
 - Good if you want a polished local UI; wire via CLI/JSON if available.

4. **OpenUsage** - https://github.com/janekbaraniewski/openusage · https://openusage.sh/ · 225 ★
 - Terminal dashboard, many providers, optional Prometheus.
 - Younger; keep as optional.

5. **Win-CodexBar** - https://github.com/nesszer/Win-CodexBar · 1.2k ★
 - Windows tray port of CodexBar spirit (Tauri). Use if PC is Windows.

6. **MeterBar** - https://github.com/VincentShipsIt/meterbar.dev · https://meterbar.dev/
 - Focused macOS bar for Claude Code, Codex CLI, Cursor limits.

7. **Claude-Code-Usage-Monitor** - https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor · 8.7k ★
 - Claude-focused; last push 2026-07-05 (older than CodexBar/ccusage).

## Provider API reality (still true)

1. OpenRouter: live credits endpoint.
2. Anthropic / OpenAI: cost/usage admin APIs, not a simple "wallet balance".
3. Cursor / Claude plan / Codex plan: best read via CodexBar-class tools that reuse local sessions.
4. Local Ollama/vLLM: cost 0; limit is GPU queue.

## How the factory should consume them

1. Poll CodexBar serve/CLI for remaining % and reset times → router scores.
2. Pull ccusage JSON daily for ledger reconciliation.
3. Keep our own SQLite ledger as source of truth for routing decisions.
