# Pai-Harness (Software Factory)

Credit-aware, multi-chat software factory for your PC. Prefer **subscription + free quota + local**. Decision engine: **Laya only** (no Jev). Usage meters: CodexBar / Win-CodexBar + ccusage. Route away when a plan window is near its limit. Never buy extra metered credits by default.

Status: design + mock prototype + **one-click setup scripts**. Verified research dated 15 Oct 2026.

## Quick start

### macOS / Linux

```bash
git clone https://github.com/pranit1812/Pai-Harness.git
cd Pai-Harness
./setup.sh
```

Non-interactive (default free CLI set, skip browser login):

```bash
./setup.sh --yes --skip-login
```

Dry run (print actions only):

```bash
./setup.sh --dry-run --yes
```

### Windows (PowerShell)

```powershell
git clone https://github.com/pranit1812/Pai-Harness.git
cd Pai-Harness
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Non-interactive:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Yes -SkipLogin
```

Dry run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -DryRun -Yes
```

### Cross-platform wrapper

There is no single binary named `setup`. Use:

1. macOS/Linux: `./setup.sh`
2. Windows: `setup.ps1`
3. Same flags in spirit: dry-run / yes / skip-login

`setup.sh` and `setup.ps1` both write `config/pool.yaml` from what got installed, run health checks, and never write secrets into the repo.

## What setup installs (default free set)

1. Ollama + small `qwen2.5-coder:1.5b`
2. OpenCode (local via Ollama)
3. Gemini CLI (unpaid API key path, ~250 req/day Flash)
4. Cursor CLI Hobby
5. Codex CLI (ChatGPT Free limited or your Plus sub)
6. pi, Kilo free tier
7. ccusage + CodexBar (Mac) / Win-CodexBar (Windows)
8. Laya (`pip`/`uv`)

Optional toggles: Claude Code (Pro/Max), Copilot, Cline, Crush, Qwen (local only; cloud OAuth free tier ended Apr 2026).

Full limits and sources: `docs/free-clis.md`.

## Routing policy (your decisions)

1. Laya only for System-1 decisions (no Jev).
2. No dollar spending caps: you run subscriptions and do not buy extra credits.
3. Credit awareness = plan **usage-limit windows** via CodexBar/ccusage; back off when near the limit.
4. Prefer: subscription quota, then free quota, then local. Avoid metered API keys.

## Layout

```
Pai-Harness/
  README.md
  setup.sh / setup.ps1
  config/pool.yaml          (generated locally; example committed)
  docs/
    free-clis.md
    problem-map.md
    venn.md / venn.png
    stitch-plan.md
    usage-tools.md
    archive/factory-design/
  prototype/factory/        mock demo
```

## Mock prototype (optional)

```bash
cd prototype/factory
python3 run.py --demo
# dashboard http://127.0.0.1:8787
```

## Docs to read

1. `docs/free-clis.md` - free/subscription CLI matrix
2. `docs/stitch-plan.md` - repos to stitch
3. `docs/problem-map.md` - full area map
4. `docs/usage-tools.md` - CodexBar siblings

## Secrets

Never commit API keys, cookies, or OAuth tokens. Logins stay in each CLI's local store / OS keychain. Put optional env vars (for example `GEMINI_API_KEY`) in your shell profile, not in this repo.
