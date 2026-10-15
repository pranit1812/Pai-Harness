#!/usr/bin/env bash
# Pai-Harness one-click setup for macOS / Linux.
# Idempotent. Prefer subscription + free quota + local. Never store secrets in the repo.
# Compatible with Bash 3.2 (macOS default).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
ASSUME_DEFAULTS=0
SKIP_LOGIN=0

# Selection: 1 = install (defaults = free-leaning set)
W_OLLAMA=1 W_OPENCODE=1 W_GEMINI=1 W_CURSOR=1 W_CODEX=1 W_PI=1 W_KILO=1
W_CCUSAGE=1 W_CODEXBAR=1 W_LAYA=1
W_CLAUDE=0 W_COPILOT=0 W_CLINE=0 W_CRUSH=0 W_QWEN=0

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [options]

  --dry-run          Print actions only; do not install or login
  --yes              Non-interactive: install default free set
  --all-free         Same as --yes
  --skip-login       Install only; skip browser login flows
  -h, --help         Show help

Default free set: ollama, opencode, gemini, cursor, codex, pi, kilo, ccusage, codexbar, laya
Optional: claude, copilot, cline, crush, qwen
USAGE
}

info() { printf '[pai] %s\n' "$*"; }
warn() { printf '[pai] WARN: %s\n' "$*" >&2; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    info "DRY-RUN: $*"
    return 0
  fi
  info "+ $*"
  "$@"
}

have() { command -v "$1" >/dev/null 2>&1; }

os_name() {
  case "$(uname -s)" in
    Darwin) echo mac ;;
    Linux) echo linux ;;
    *) echo other ;;
  esac
}

OS="$(os_name)"

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --yes|--all-free) ASSUME_DEFAULTS=1 ;;
    --skip-login) SKIP_LOGIN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) warn "Unknown arg: $1"; usage; exit 1 ;;
  esac
  shift
done

toggle() {
  if [ "$1" -eq 1 ]; then echo 0; else echo 1; fi
}

menu() {
  if [ "$ASSUME_DEFAULTS" -eq 1 ]; then
    info "Using default free CLI set"
    return 0
  fi
  if [ ! -t 0 ]; then
    info "No TTY; using default free CLI set"
    return 0
  fi
  cat <<'MENU'

Pai-Harness setup: choose CLIs (subscription/free/local preferred; avoid metered API spend)
Defaults marked [Y]. Enter a number to toggle, then Enter alone to continue.

  1) ollama      [Y]  local free
  2) opencode    [Y]  free with Ollama
  3) gemini      [Y]  unpaid API key ~250 req/day Flash
  4) cursor      [Y]  Hobby free pool
  5) codex       [Y]  ChatGPT Free limited / Plus sub
  6) pi          [Y]  free/local providers
  7) kilo        [Y]  kilo-auto/free
  8) ccusage     [Y]  usage history
  9) codexbar    [Y]  usage limits meter
 10) laya        [Y]  local decision model (no Jev)
 11) claude      [ ]  Pro/Max subscription only
 12) copilot     [ ]  Copilot plan / student
 13) cline       [ ]  free tool; local/BYOK only
 14) crush       [ ]  free tool; prefer local
 15) qwen        [ ]  cloud free OAuth dead; local only

MENU
  while true; do
    printf 'Toggle (1-15) or Enter to continue: '
    # shellcheck disable=SC2162
    read choice || true
    [ -z "${choice:-}" ] && break
    case "$choice" in
      1) W_OLLAMA="$(toggle "$W_OLLAMA")" ;;
      2) W_OPENCODE="$(toggle "$W_OPENCODE")" ;;
      3) W_GEMINI="$(toggle "$W_GEMINI")" ;;
      4) W_CURSOR="$(toggle "$W_CURSOR")" ;;
      5) W_CODEX="$(toggle "$W_CODEX")" ;;
      6) W_PI="$(toggle "$W_PI")" ;;
      7) W_KILO="$(toggle "$W_KILO")" ;;
      8) W_CCUSAGE="$(toggle "$W_CCUSAGE")" ;;
      9) W_CODEXBAR="$(toggle "$W_CODEXBAR")" ;;
      10) W_LAYA="$(toggle "$W_LAYA")" ;;
      11) W_CLAUDE="$(toggle "$W_CLAUDE")" ;;
      12) W_COPILOT="$(toggle "$W_COPILOT")" ;;
      13) W_CLINE="$(toggle "$W_CLINE")" ;;
      14) W_CRUSH="$(toggle "$W_CRUSH")" ;;
      15) W_QWEN="$(toggle "$W_QWEN")" ;;
      *) warn "Pick 1-15" ;;
    esac
    info "Selection updated"
  done
}

ensure_homebrew() {
  [ "$OS" = mac ] || return 0
  have brew && return 0
  info "Installing Homebrew"
  run bash -c 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
}

ensure_node() {
  if have node && have npm; then
    info "Node $(node -v) already present"
    return 0
  fi
  if [ "$OS" = mac ]; then
    ensure_homebrew
    run brew install node
  elif have apt-get; then
    run sudo apt-get update -qq
    run sudo apt-get install -y -qq nodejs npm
  else
    warn "Install Node 22+ from https://nodejs.org"
    return 1
  fi
}

ensure_python() {
  if have python3; then
    info "Python present: $(python3 --version 2>&1)"
  else
    if [ "$OS" = mac ]; then run brew install python
    else run sudo apt-get install -y -qq python3 python3-pip python3-venv
    fi
  fi
  if have uv; then
    info "uv present"
  else
    run bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

ensure_git() {
  have git && return 0
  if [ "$OS" = mac ]; then run brew install git
  else run sudo apt-get install -y -qq git
  fi
}

npm_i() {
  pkg="$1"
  if npm list -g --depth=0 "$pkg" >/dev/null 2>&1; then
    info "npm package $pkg already installed"
    return 0
  fi
  run npm install -g "$pkg"
}

yn() { [ "$1" -eq 1 ]; }

install_ollama() {
  yn "$W_OLLAMA" || return 0
  if have ollama; then info "ollama already installed"
  elif [ "$OS" = mac ]; then
    ensure_homebrew
    run brew install ollama || run bash -c 'curl -fsSL https://ollama.com/install.sh | sh'
  else
    run bash -c 'curl -fsSL https://ollama.com/install.sh | sh'
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    info "DRY-RUN: would start ollama and pull qwen2.5-coder:1.5b"
    return 0
  fi
  if have ollama; then
    (ollama serve >/dev/null 2>&1 &) || true
    sleep 1 || true
    info "Pulling small local model qwen2.5-coder:1.5b"
    run ollama pull qwen2.5-coder:1.5b || warn "model pull failed (retry later)"
  fi
}

install_opencode() {
  yn "$W_OPENCODE" || return 0
  have opencode && { info "opencode present"; return 0; }
  if [ "$OS" = mac ] && have brew; then
    run brew install anomalyco/tap/opencode-v2 || npm_i "@opencode/cli"
  else
    npm_i "@opencode/cli" || run bash -c 'curl -fsSL https://opencode.ai/v2/install | bash'
  fi
}

install_gemini() {
  yn "$W_GEMINI" || return 0
  have gemini && { info "gemini present"; return 0; }
  if [ "$OS" = mac ] && have brew; then
    run brew install gemini-cli || npm_i "@google/gemini-cli"
  else
    npm_i "@google/gemini-cli"
  fi
}

install_cursor() {
  yn "$W_CURSOR" || return 0
  have agent && { info "cursor agent present"; return 0; }
  run bash -c 'curl https://cursor.com/install -fsS | bash'
}

install_codex() {
  yn "$W_CODEX" || return 0
  have codex && { info "codex present"; return 0; }
  if [ "$OS" = mac ] && have brew; then
    run brew install --cask codex || npm_i "@openai/codex"
  else
    npm_i "@openai/codex"
  fi
}

install_pi() {
  yn "$W_PI" || return 0
  have pi && { info "pi present"; return 0; }
  run bash -c 'curl -fsSL https://pi.dev/install.sh | sh' || npm_i "@earendil-works/pi-coding-agent"
}

install_kilo() {
  yn "$W_KILO" || return 0
  have kilo && { info "kilo present"; return 0; }
  npm_i "@kilocode/cli"
}

install_ccusage() {
  yn "$W_CCUSAGE" || return 0
  npm_i "ccusage"
}

install_codexbar() {
  yn "$W_CODEXBAR" || return 0
  if [ "$OS" = mac ]; then
    ensure_homebrew
    run brew install --cask codexbar || warn "CodexBar cask failed; see https://codexbar.app/"
  else
    info "Linux: get CodexBar CLI from https://github.com/steipete/CodexBar/releases"
  fi
}

install_laya() {
  yn "$W_LAYA" || return 0
  export PATH="$HOME/.local/bin:$PATH"
  if have uv; then
    run uv pip install --system laya || run uv pip install laya
  else
    run python3 -m pip install --user laya
  fi
}

install_claude() {
  yn "$W_CLAUDE" || return 0
  have claude && { info "claude present"; return 0; }
  if [ "$OS" = mac ] && have brew; then
    run brew install --cask claude-code || run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  else
    run bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  fi
}

install_copilot() {
  yn "$W_COPILOT" || return 0
  have copilot && { info "copilot present"; return 0; }
  if [ "$OS" = mac ] && have brew; then
    run brew install --cask copilot-cli || npm_i "@github/copilot"
  else
    npm_i "@github/copilot"
  fi
}

install_cline() { yn "$W_CLINE" || return 0; npm_i "cline"; }
install_crush() { yn "$W_CRUSH" || return 0; npm_i "@charmland/crush"; }

install_qwen() {
  yn "$W_QWEN" || return 0
  have qwen && { info "qwen present"; return 0; }
  run bash -c 'curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen-standalone.sh | bash' \
    || npm_i "@qwen-code/qwen-code@latest"
}

ask_login() {
  name="$1"
  cmd="$2"
  printf 'Login %s now? [Y/n] ' "$name"
  # shellcheck disable=SC2162
  read ans || ans=y
  case "${ans:-y}" in
    [Nn]*) return 0 ;;
  esac
  info "Running: $cmd"
  # shellcheck disable=SC2086
  sh -c "$cmd" || warn "$name login exited non-zero"
}

do_logins() {
  [ "$SKIP_LOGIN" -eq 1 ] && { info "Skipping logins"; return 0; }
  if [ "$DRY_RUN" -eq 1 ]; then
    info "DRY-RUN: would run browser login flows for selected CLIs"
    return 0
  fi
  if [ ! -t 0 ]; then
    warn "No TTY for interactive login; re-run without --yes later"
    return 0
  fi
  info "Logins open a browser. Prefer subscription/free. Never commit API keys."
  yn "$W_CURSOR" && have agent && ask_login cursor "agent login"
  yn "$W_CODEX" && have codex && ask_login codex "codex"
  yn "$W_CLAUDE" && have claude && ask_login claude "claude"
  yn "$W_GEMINI" && have gemini && ask_login gemini "gemini"
  yn "$W_COPILOT" && have copilot && ask_login copilot "copilot"
  yn "$W_PI" && have pi && ask_login pi "pi"
  yn "$W_KILO" && have kilo && ask_login kilo "kilo"
  yn "$W_OPENCODE" && info "opencode: prefer Ollama local (no login) or /connect for cloud"
  yn "$W_GEMINI" && info "Gemini free: set GEMINI_API_KEY from AI Studio (unpaid). Do not commit it."
}

version_of() {
  bin="$1"
  have "$bin" || { echo "-"; return 0; }
  "$bin" --version 2>/dev/null | head -n 1 || "$bin" -v 2>/dev/null | head -n 1 || echo "installed"
}

login_hint() {
  tool="$1"
  case "$tool" in
    ollama) have ollama && ollama list >/dev/null 2>&1 && echo yes || echo no ;;
    cursor) have agent && agent status >/dev/null 2>&1 && echo unknown || echo no ;;
    codex) [ -d "$HOME/.codex" ] && echo maybe || echo no ;;
    claude) { [ -d "$HOME/.claude" ] || [ -f "$HOME/.claude.json" ]; } && echo maybe || echo no ;;
    gemini) [ -n "${GEMINI_API_KEY:-}" ] && echo maybe || echo no ;;
    *) echo n/a ;;
  esac
}

row() {
  label="$1"; bin="$2"; key="$3"
  inst=no; ver="-"; login=n/a
  if have "$bin"; then
    inst=yes
    ver="$(version_of "$bin")"
    login="$(login_hint "$key")"
  fi
  printf '%-14s %-10s %-10s %s\n' "$label" "$inst" "$login" "$ver"
}

health() {
  info "Health check"
  printf '%-14s %-10s %-10s %s\n' "TOOL" "INSTALLED" "LOGIN" "VERSION"
  printf '%-14s %-10s %-10s %s\n' "----" "---------" "-----" "-------"
  row ollama ollama ollama
  row opencode opencode opencode
  row gemini gemini gemini
  row cursor-agent agent cursor
  row codex codex codex
  row pi pi pi
  row kilo kilo kilo
  row claude claude claude
  row copilot copilot copilot
  row cline cline cline
  row crush crush crush
  row qwen qwen qwen
  row ccusage ccusage ccusage
  if have codexbar; then row codexbar codexbar codexbar
  else printf '%-14s %-10s %-10s %s\n' "codexbar" "check-app" "n/a" "brew cask / releases"
  fi
  if python3 -c "import laya" 2>/dev/null; then
    printf '%-14s %-10s %-10s %s\n' "laya" "yes" "n/a" "python module"
  else
    printf '%-14s %-10s %-10s %s\n' "laya" "no" "n/a" "-"
  fi
}

enabled_flag() {
  want="$1"; bin="$2"
  if [ "$want" -eq 1 ] && have "$bin"; then echo true; else echo false; fi
}

write_pool() {
  out="$ROOT/config/pool.yaml"
  if [ "$DRY_RUN" -eq 1 ]; then
    info "DRY-RUN: would write $out"
    return 0
  fi
  mkdir -p "$ROOT/config"
  # shellcheck disable=SC2090
  cat > "$out" <<EOF
# Generated by setup.sh. Prefer subscription/free/local. Avoid metered API spend.
# Decision engine: Laya only. Meters: CodexBar + ccusage usage windows.
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
    enabled: $(enabled_flag "$W_OLLAMA" ollama)
  - id: opencode-local
    kind: agent_cli
    run: opencode
    cost: free
    via: ollama
    enabled: $(enabled_flag "$W_OPENCODE" opencode)
  - id: gemini-free
    kind: agent_cli
    run: gemini
    cost: free_quota
    notes: unpaid API key 250 req/day Flash; avoid PAYG
    enabled: $(enabled_flag "$W_GEMINI" gemini)
  - id: cursor-agent
    kind: agent_cli
    run: agent
    cost: free_quota_or_subscription
    enabled: $(enabled_flag "$W_CURSOR" agent)
  - id: codex
    kind: agent_cli
    run: codex
    cost: free_quota_or_subscription
    auth: chatgpt
    enabled: $(enabled_flag "$W_CODEX" codex)
  - id: pi
    kind: agent_cli
    run: pi
    cost: free_or_local
    enabled: $(enabled_flag "$W_PI" pi)
  - id: kilo-free
    kind: agent_cli
    run: kilo
    cost: free_quota
    model_hint: kilo-auto/free
    enabled: $(enabled_flag "$W_KILO" kilo)
  - id: claude-code
    kind: agent_cli
    run: claude
    cost: subscription
    notes: Pro/Max only; orchestrator candidate
    enabled: $(enabled_flag "$W_CLAUDE" claude)
  - id: copilot
    kind: agent_cli
    run: copilot
    cost: subscription
    enabled: $(enabled_flag "$W_COPILOT" copilot)
EOF
  info "Wrote $out"
}

main() {
  info "Pai-Harness setup (OS=$OS dry_run=$DRY_RUN)"
  info "Repo root: $ROOT"
  menu
  ensure_git
  ensure_node
  ensure_python
  install_ollama
  install_opencode
  install_gemini
  install_cursor
  install_codex
  install_pi
  install_kilo
  install_ccusage
  install_codexbar
  install_laya
  install_claude
  install_copilot
  install_cline
  install_crush
  install_qwen
  do_logins
  write_pool
  health
  info "Done. See docs/free-clis.md. Secrets stay in OS keychain/env, never in git."
}

main
