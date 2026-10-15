# Pai-Harness one-click setup for Windows (PowerShell 5+ / pwsh).
# Idempotent. Prefer subscription + free quota + local. Never store secrets in the repo.
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$Yes,
  [switch]$AllFree,
  [switch]$SkipLogin,
  [switch]$Help
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Info([string]$Message) { Write-Host "[pai] $Message" }
function Warn([string]$Message) { Write-Warning "[pai] $Message" }

function Invoke-Step {
  param([scriptblock]$Action, [string]$Label)
  if ($DryRun) { Info "DRY-RUN: $Label"; return }
  Info "+ $Label"
  & $Action
}

function Test-Cmd([string]$Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

if ($Help) {
  @"
Usage: .\setup.ps1 [-DryRun] [-Yes] [-AllFree] [-SkipLogin]

Default free set: ollama, opencode, gemini, cursor, codex, pi, kilo, ccusage, wincodexbar, laya
Optional: claude, copilot, cline, crush, qwen
"@ | Write-Host
  exit 0
}

if ($AllFree) { $Yes = $true }

# Selection defaults
$Want = @{
  ollama = $true; opencode = $true; gemini = $true; cursor = $true; codex = $true
  pi = $true; kilo = $true; ccusage = $true; wincodexbar = $true; laya = $true
  claude = $false; copilot = $false; cline = $false; crush = $false; qwen = $false
}

function Show-Menu {
  if ($Yes) { Info "Using default free CLI set"; return }
  if (-not [Environment]::UserInteractive) { Info "Non-interactive; using defaults"; return }
  @"

Pai-Harness setup (Windows): subscription/free/local preferred; avoid metered API spend
Enter numbers to toggle, blank Enter to continue.

  1) ollama       [Y] local free
  2) opencode     [Y] free with Ollama
  3) gemini       [Y] unpaid API key ~250/day Flash
  4) cursor       [Y] Hobby free pool
  5) codex        [Y] ChatGPT Free / Plus
  6) pi           [Y] free/local
  7) kilo         [Y] kilo-auto/free
  8) ccusage      [Y] usage history
  9) Win-CodexBar [Y] usage limits
 10) laya         [Y] local decisions (no Jev)
 11) claude       [ ] Pro/Max subscription
 12) copilot      [ ] Copilot plan / student
 13) cline        [ ] free tool; local/BYOK
 14) crush        [ ] free tool; prefer local
 15) qwen         [ ] cloud free OAuth dead; local only

"@ | Write-Host
  $map = @{
    "1"="ollama";"2"="opencode";"3"="gemini";"4"="cursor";"5"="codex"
    "6"="pi";"7"="kilo";"8"="ccusage";"9"="wincodexbar";"10"="laya"
    "11"="claude";"12"="copilot";"13"="cline";"14"="crush";"15"="qwen"
  }
  while ($true) {
    $choice = Read-Host "Toggle (1-15) or Enter to continue"
    if ([string]::IsNullOrWhiteSpace($choice)) { break }
    if ($map.ContainsKey($choice)) {
      $k = $map[$choice]
      $Want[$k] = -not $Want[$k]
      Info "toggled $k -> $($Want[$k])"
    } else { Warn "Pick 1-15" }
  }
}

function Ensure-Winget {
  if (Test-Cmd winget) { return $true }
  Warn "winget not found; some installs will use npm/curl fallbacks"
  return $false
}

function Ensure-Node {
  if ((Test-Cmd node) -and (Test-Cmd npm)) {
    Info "Node $(node -v) present"
    return
  }
  if (Ensure-Winget) {
    Invoke-Step -Label "winget install OpenJS.NodeJS.LTS" -Action {
      winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    }
  } else {
    throw "Install Node 22+ from https://nodejs.org then re-run"
  }
}

function Ensure-Git {
  if (Test-Cmd git) { return }
  if (Ensure-Winget) {
    Invoke-Step -Label "winget install Git.Git" -Action {
      winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
    }
  }
}

function Ensure-Python {
  if (Test-Cmd python) { Info "Python present"; }
  elseif (Ensure-Winget) {
    Invoke-Step -Label "winget install Python.Python.3.12" -Action {
      winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
    }
  }
  if (-not (Test-Cmd uv)) {
    Invoke-Step -Label "install uv" -Action {
      irm https://astral.sh/uv/install.ps1 | iex
    }
  }
}

function Install-Npm([string]$Package) {
  Invoke-Step -Label "npm i -g $Package" -Action {
    npm install -g $Package
  }
}

function Install-Selected {
  Ensure-Git
  Ensure-Node
  Ensure-Python

  if ($Want.ollama) {
    if (Test-Cmd ollama) { Info "ollama present" }
    else {
      Info "Install Ollama from https://ollama.com/download (Windows installer)"
      if (Ensure-Winget) {
        Invoke-Step -Label "winget install Ollama.Ollama" -Action {
          winget install -e --id Ollama.Ollama --accept-package-agreements --accept-source-agreements
        }
      }
    }
    if (-not $DryRun -and (Test-Cmd ollama)) {
      Info "Pulling qwen2.5-coder:1.5b"
      try { ollama pull qwen2.5-coder:1.5b } catch { Warn "model pull failed" }
    } elseif ($DryRun) { Info "DRY-RUN: would ollama pull qwen2.5-coder:1.5b" }
  }

  if ($Want.opencode) { if (Test-Cmd opencode) { Info "opencode present" } else { Install-Npm "@opencode/cli" } }
  if ($Want.gemini) { if (Test-Cmd gemini) { Info "gemini present" } else { Install-Npm "@google/gemini-cli" } }
  if ($Want.cursor) {
    if (Test-Cmd agent) { Info "cursor agent present" }
    else {
      Invoke-Step -Label "install Cursor CLI" -Action { irm 'https://cursor.com/install?win32=true' | iex }
    }
  }
  if ($Want.codex) { if (Test-Cmd codex) { Info "codex present" } else { Install-Npm "@openai/codex" } }
  if ($Want.pi) {
    if (Test-Cmd pi) { Info "pi present" }
    else { Install-Npm "@earendil-works/pi-coding-agent" }
  }
  if ($Want.kilo) { if (Test-Cmd kilo) { Info "kilo present" } else { Install-Npm "@kilocode/cli" } }
  if ($Want.ccusage) { Install-Npm "ccusage" }

  if ($Want.wincodexbar) {
    Info "Win-CodexBar: prefer GitHub release https://github.com/nesszer/Win-CodexBar/releases"
    if (Ensure-Winget) {
      Invoke-Step -Label "winget try Win-CodexBar" -Action {
        winget install -e --id dontcallmejames.CodexBar --accept-package-agreements --accept-source-agreements
      }
    }
  }

  if ($Want.laya) {
    Invoke-Step -Label "pip/uv install laya" -Action {
      if (Test-Cmd uv) { uv pip install laya }
      else { python -m pip install --user laya }
    }
  }

  if ($Want.claude) {
    if (Test-Cmd claude) { Info "claude present" }
    else {
      if (Ensure-Winget) {
        Invoke-Step -Label "winget Anthropic.ClaudeCode" -Action {
          winget install -e --id Anthropic.ClaudeCode --accept-package-agreements --accept-source-agreements
        }
      } else {
        Invoke-Step -Label "claude install.ps1" -Action { irm https://claude.ai/install.ps1 | iex }
      }
    }
  }

  if ($Want.copilot) {
    if (Test-Cmd copilot) { Info "copilot present" }
    else {
      if (Ensure-Winget) {
        Invoke-Step -Label "winget GitHub.Copilot" -Action {
          winget install -e --id GitHub.Copilot --accept-package-agreements --accept-source-agreements
        }
      } else { Install-Npm "@github/copilot" }
    }
  }

  if ($Want.cline) { Install-Npm "cline" }
  if ($Want.crush) { Install-Npm "@charmland/crush" }
  if ($Want.qwen) {
    Invoke-Step -Label "install qwen" -Action {
      irm https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.ps1 | iex
    }
  }
}

function Do-Logins {
  if ($SkipLogin) { Info "Skipping logins"; return }
  if ($DryRun) { Info "DRY-RUN: would run browser logins"; return }
  if (-not [Environment]::UserInteractive) { Warn "No interactive session for login"; return }
  Info "Logins open a browser. Prefer subscription/free. Never commit API keys."
  function Ask([string]$Name, [scriptblock]$Cmd) {
    $ans = Read-Host "Login $Name now? [Y/n]"
    if ($ans -match '^[Nn]') { return }
    try { & $Cmd } catch { Warn "$Name login failed: $_" }
  }
  if ($Want.cursor -and (Test-Cmd agent)) { Ask "cursor" { agent login } }
  if ($Want.codex -and (Test-Cmd codex)) { Ask "codex" { codex } }
  if ($Want.claude -and (Test-Cmd claude)) { Ask "claude" { claude } }
  if ($Want.gemini -and (Test-Cmd gemini)) { Ask "gemini" { gemini } }
  if ($Want.copilot -and (Test-Cmd copilot)) { Ask "copilot" { copilot } }
  if ($Want.pi -and (Test-Cmd pi)) { Ask "pi" { pi } }
  if ($Want.kilo -and (Test-Cmd kilo)) { Ask "kilo" { kilo } }
  if ($Want.gemini) { Info "Gemini free: set GEMINI_API_KEY from AI Studio unpaid key. Do not commit it." }
}

function Enabled([bool]$WantFlag, [string]$Bin) {
  if ($WantFlag -and (Test-Cmd $Bin)) { return "true" }
  return "false"
}

function Write-Pool {
  $out = Join-Path $Root "config\pool.yaml"
  if ($DryRun) { Info "DRY-RUN: would write $out"; return }
  New-Item -ItemType Directory -Force -Path (Join-Path $Root "config") | Out-Null
  $content = @"
# Generated by setup.ps1. Prefer subscription/free/local. Avoid metered API spend.
# Decision engine: Laya only. Meters: Win-CodexBar + ccusage usage windows.
generated: true
decision_engine: laya
credit_policy:
  prefer: [subscription, free_quota, local]
  avoid: [metered_api]
  meters: [codexbar, ccusage]
  note: No hard dollar caps; route away when a plan window is near its limit.
models:
  - id: ollama-qwen-coder
    kind: local
    endpoint: http://localhost:11434/v1
    model: qwen2.5-coder:1.5b
    cost: free
    enabled: $(Enabled $Want.ollama ollama)
  - id: opencode-local
    kind: agent_cli
    run: opencode
    cost: free
    via: ollama
    enabled: $(Enabled $Want.opencode opencode)
  - id: gemini-free
    kind: agent_cli
    run: gemini
    cost: free_quota
    notes: unpaid API key 250 req/day Flash; avoid PAYG
    enabled: $(Enabled $Want.gemini gemini)
  - id: cursor-agent
    kind: agent_cli
    run: agent
    cost: free_quota_or_subscription
    enabled: $(Enabled $Want.cursor agent)
  - id: codex
    kind: agent_cli
    run: codex
    cost: free_quota_or_subscription
    auth: chatgpt
    enabled: $(Enabled $Want.codex codex)
  - id: pi
    kind: agent_cli
    run: pi
    cost: free_or_local
    enabled: $(Enabled $Want.pi pi)
  - id: kilo-free
    kind: agent_cli
    run: kilo
    cost: free_quota
    model_hint: kilo-auto/free
    enabled: $(Enabled $Want.kilo kilo)
  - id: claude-code
    kind: agent_cli
    run: claude
    cost: subscription
    notes: Pro/Max only; orchestrator candidate
    enabled: $(Enabled $Want.claude claude)
  - id: copilot
    kind: agent_cli
    run: copilot
    cost: subscription
    enabled: $(Enabled $Want.copilot copilot)
"@
  Set-Content -Path $out -Value $content -Encoding UTF8
  Info "Wrote $out"
}

function Show-Health {
  Info "Health check"
  "{0,-14} {1,-10} {2}" -f "TOOL","INSTALLED","VERSION" | Write-Host
  "{0,-14} {1,-10} {2}" -f "----","---------","-------" | Write-Host
  $tools = @(
    @{n="ollama";b="ollama"}, @{n="opencode";b="opencode"}, @{n="gemini";b="gemini"},
    @{n="cursor-agent";b="agent"}, @{n="codex";b="codex"}, @{n="pi";b="pi"},
    @{n="kilo";b="kilo"}, @{n="claude";b="claude"}, @{n="copilot";b="copilot"},
    @{n="cline";b="cline"}, @{n="crush";b="crush"}, @{n="qwen";b="qwen"},
    @{n="ccusage";b="ccusage"}
  )
  foreach ($t in $tools) {
    $inst = if (Test-Cmd $t.b) { "yes" } else { "no" }
    $ver = "-"
    if ($inst -eq "yes") {
      try { $ver = (& $t.b --version 2>$null | Select-Object -First 1) } catch { $ver = "installed" }
    }
    "{0,-14} {1,-10} {2}" -f $t.n,$inst,$ver | Write-Host
  }
  $laya = "no"
  try { python -c "import laya" 2>$null; if ($LASTEXITCODE -eq 0) { $laya = "yes" } } catch {}
  "{0,-14} {1,-10} {2}" -f "laya",$laya,"python module" | Write-Host
  "{0,-14} {1,-10} {2}" -f "Win-CodexBar","check-app","releases / winget" | Write-Host
}

Info "Pai-Harness Windows setup (DryRun=$DryRun)"
Show-Menu
Install-Selected
Do-Logins
Write-Pool
Show-Health
Info "Done. See docs/free-clis.md. Secrets stay in OS credential store/env, never in git."
