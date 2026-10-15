# Free / subscription coding CLIs (Oct 2026)

Verified live 15 Oct 2026. Focus: free tiers, subscription-included quota (no extra credit buys), and local. Prefer subscription/free windows over metered API spend. Sources linked.

Routing policy for Pai-Harness: use CodexBar / ccusage to watch plan windows; route away when a plan is near its limit; never prefer pay-as-you-go API keys.

## Legend

- **free_quota**: usable without buying credits (may need a free account or free API key)
- **subscription**: included in a monthly plan you already pay for
- **local**: runs on your machine, $0 inference
- **metered**: avoid for default routing

## 1. Ollama (local)

| | |
|---|---|
| Kind | local |
| Limits | Your GPU/RAM only |
| Install macOS | Download app from https://ollama.com/download or `brew install ollama` |
| Install Windows | Download installer from https://ollama.com/download |
| Login | None for local models |
| Pull model | `ollama pull qwen2.5-coder:1.5b` (small) or `qwen2.5-coder:7b` |
| Source | https://docs.ollama.com/quickstart |

## 2. OpenCode

| | |
|---|---|
| Kind | free_quota when pointed at Ollama; optional paid providers |
| Limits | Local = free. Cloud providers depend on keys you add. |
| Install macOS | `curl -fsSL https://opencode.ai/v2/install \| bash` or `brew install anomalyco/tap/opencode-v2` or `npm i -g @opencode/cli` |
| Install Windows | `npm i -g @opencode/cli` (or desktop binary from https://opencode.ai/download). WSL also supported. |
| Login | `/connect` only if using cloud providers. For Ollama: configure `baseURL http://localhost:11434/v1` or `ollama launch opencode` |
| Source | https://opencode.ai/download · https://docs.ollama.com/integrations/opencode |

## 3. Gemini CLI

| | |
|---|---|
| Kind | free_quota (API key unpaid) or subscription (AI Pro/Ultra / Code Assist Standard+) |
| Limits | Unpaid Gemini API key: **250 requests/day**, Flash only. Google-account "Code Assist for individuals" was historically 1000 req/day; **consumer Google login for Gemini CLI was deprecated 18 Jun 2026** (migrate to Antigravity / API key / paid Code Assist). |
| Install macOS | `npm i -g @google/gemini-cli` or `brew install gemini-cli` |
| Install Windows | `npm i -g @google/gemini-cli` |
| Login | Prefer unpaid API key in env (`GEMINI_API_KEY`) for free Flash. Or paid Code Assist / Workspace. Avoid metered PAYG unless you opt in. |
| Source | https://geminicli.com/docs/resources/quota-and-pricing/ · https://developers.google.com/gemini-code-assist/resources/faqs |

## 4. Cursor CLI (`agent`)

| | |
|---|---|
| Kind | free_quota (Hobby) + subscription (Plus+) |
| Limits | Free: limited Agent and Chat (no fixed public count). Paid weekly pool shared with Grok products. Top-offs are metered; avoid. |
| Install macOS | `curl https://cursor.com/install -fsS \| bash` |
| Install Windows | `irm 'https://cursor.com/install?win32=true' \| iex` |
| Login | `agent login` (browser). Status: `agent status` |
| Source | https://cursor.com/docs/cli/reference/authentication · https://cursor.com/pricing |

## 5. Codex CLI

| | |
|---|---|
| Kind | free_quota (ChatGPT Free/Go, limited) + subscription (Plus/Pro/…) |
| Limits | Included across Free, Go, Plus, Pro, Business, Enterprise. Free/Go: limited flagship access. Plus/Pro: shared ~5h windows + weekly caps. Prefer ChatGPT sign-in over OpenAI API key. |
| Install macOS | `npm i -g @openai/codex` or `brew install --cask codex` |
| Install Windows | `npm i -g @openai/codex` |
| Login | `codex` then **Sign in with ChatGPT** |
| Source | https://github.com/openai/codex · https://chatgpt.com/codex/pricing/ · https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan |

## 6. Claude Code

| | |
|---|---|
| Kind | subscription only (not on free Claude.ai) |
| Limits | Pro/Max/Team/Enterprise. Shared 5-hour session + weekly limits with claude.ai. Extra usage credits = metered; avoid. |
| Install macOS | `curl -fsSL https://claude.ai/install.sh \| bash` or `brew install --cask claude-code` |
| Install Windows | `irm https://claude.ai/install.ps1 \| iex` or `winget install Anthropic.ClaudeCode` |
| Login | `claude` (browser) with Pro/Max credentials. Prefer `/login` subscription OAuth over `ANTHROPIC_API_KEY`. |
| Source | https://code.claude.com/docs/en/install · https://claude.com/pricing |

## 7. pi (earendil)

| | |
|---|---|
| Kind | free_quota via free OpenRouter models / local; BYOK otherwise |
| Limits | Tool is free. Inference free only with free/local providers (e.g. OpenRouter free models, Ollama). |
| Install macOS | `curl -fsSL https://pi.dev/install.sh \| sh` or `npm i -g --ignore-scripts @earendil-works/pi-coding-agent` |
| Install Windows | `npm i -g --ignore-scripts @earendil-works/pi-coding-agent` |
| Login | `pi` then `/login` (pick free/local provider). Optional: `pi install npm:pi-freerouter` |
| Source | https://pi.dev/docs/latest/quickstart · https://pi.dev/docs/latest/providers |

## 8. Kilo Code CLI

| | |
|---|---|
| Kind | free_quota (`kilo-auto/free` and models labeled free) |
| Limits | Free models available; Auto Free may log prompts to partner endpoints (do not send secrets). Upstream rate limits apply (community reports ~200 req/h for some free routes; confirm in app). |
| Install | `npm i -g @kilocode/cli` then `kilo` |
| Login | Follow first-run; pick free models via `/models` |
| Source | https://kilo.ai/docs/getting-started/using-kilo-for-free · https://www.npmjs.com/package/@kilocode/cli |

## 9. Cline CLI

| | |
|---|---|
| Kind | free tool + BYOK / Cline credits (metered if you buy credits) |
| Limits | OSS free for individuals. Default path should be local/Ollama or free provider keys, not Cline credit packs. |
| Install | `npm i -g cline` (Node 20+, 22 recommended) |
| Login | First run / provider setup |
| Source | https://cline.bot/pricing · https://www.npmjs.com/package/cline |

## 10. Crush (Charm)

| | |
|---|---|
| Kind | free tool + provider BYOK / Hyper |
| Limits | CLI free; inference depends on provider. Prefer local. |
| Install | `npm i -g @charmland/crush` |
| Source | https://www.npmjs.com/package/@charmland/crush · https://github.com/charmbracelet/crush |

## 11. GitHub Copilot CLI

| | |
|---|---|
| Kind | subscription (Copilot Individual/Business) or free for verified students |
| Limits | Requires active Copilot plan. Student free via GitHub Education. |
| Install macOS | `npm i -g @github/copilot` or `brew install --cask copilot-cli` or `curl -fsSL https://gh.io/copilot-install \| bash` |
| Install Windows | `npm i -g @github/copilot` or `winget install GitHub.Copilot` |
| Login | `copilot` then `/login` |
| Source | https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli |

## 12. Qwen Code

| | |
|---|---|
| Kind | local free via Ollama endpoint; cloud OAuth free tier **discontinued 15 Apr 2026** |
| Limits | No free Qwen OAuth. Use Alibaba key / Token Plan (paid) or point at local OpenAI-compatible server. |
| Install macOS | `curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.sh \| bash` or `npm i -g @qwen-code/qwen-code@latest` |
| Install Windows | `irm https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.ps1 \| iex` |
| Login | `qwen` then `/auth` (prefer custom/local provider) |
| Source | https://qwenlm.github.io/qwen-code-docs/en/users/quickstart/ |

## 13. Amp / Factory droids

| | |
|---|---|
| Kind | mostly paid product; BYOK possible |
| Limits | Not a default free worker. Skip unless you already subscribe. |
| Source | Product sites; treat as subscription/metered |

## Usage meters (not CLIs, required for routing)

| Tool | Platform | Install | Notes |
|---|---|---|---|
| CodexBar | macOS | `brew install --cask codexbar` | CLI + `codexbar serve` JSON. https://github.com/steipete/CodexBar |
| Win-CodexBar | Windows | GitHub release / winget if available (`dontcallmejames.CodexBar` reported) | https://github.com/nesszer/Win-CodexBar |
| ccusage | both | `npm i -g ccusage` or `bunx ccusage` | Local cost history. https://github.com/ccusage/ccusage |

## Decision engine

| Tool | Kind | Install | Notes |
|---|---|---|---|
| Laya | local free | `pip install laya` or `uv pip install laya` | Apache-2.0 System-1. No Jev. https://github.com/NandhaKishorM/laya |

## Default setup picks (all free-leaning)

1. Ollama + small coder model
2. OpenCode (local)
3. Gemini CLI (unpaid API key Flash 250/day) if you want cloud free
4. Cursor CLI (Hobby free pool)
5. Codex CLI (ChatGPT Free limited, or Plus if subscribed)
6. pi (free/local providers)
7. Kilo (`kilo-auto/free`)
8. ccusage + CodexBar / Win-CodexBar
9. Laya

Optional if you already subscribe: Claude Code, Copilot CLI, Cursor Plus, ChatGPT Plus Codex.

Skip by default: Qwen cloud OAuth (dead), Amp, metered Anthropic/OpenAI API keys, Cline credit packs.
