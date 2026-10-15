#!/usr/bin/env python3
"""Software factory overlap diagram: problem areas as regions, repos in overlaps."""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, Circle, Ellipse, FancyArrowPatch
import numpy as np

fig, ax = plt.subplots(figsize=(22, 14), dpi=150)
ax.set_xlim(0, 100)
ax.set_ylim(0, 68)
ax.set_aspect('equal')
ax.axis('off')
fig.patch.set_facecolor('#0f1419')
ax.set_facecolor('#0f1419')

# Color palette (distinct, dark-bg friendly)
C = {
    'board': '#1e3a5f',
    'route': '#3d2a5c',
    'credit': '#1a4d3e',
    'orch': '#5c3a1e',
    'sand': '#3a1e2e',
    'skill': '#2e3a1e',
    'check': '#1e2e3a',
    'audit': '#3a2e1e',
    'local': '#2e1e3a',
    'trig': '#1e3a2e',
    'ui': '#3a1e1e',
    'edge': '#6b8cae',
    'text': '#e8eef5',
    'muted': '#9db0c5',
    'accent': '#7dd3fc',
    'core': '#fbbf24',
}

def region(xy, w, h, color, label, sub=''):
    box = FancyBboxPatch(xy, w, h, boxstyle='round,pad=0.3,rounding_size=1.2',
                         facecolor=color, edgecolor='#8ba3bf', linewidth=1.4, alpha=0.92)
    ax.add_patch(box)
    ax.text(xy[0]+0.6, xy[1]+h-1.1, label, color=C['text'], fontsize=11,
            fontweight='bold', fontfamily='DejaVu Sans', va='top')
    if sub:
        ax.text(xy[0]+0.6, xy[1]+h-2.5, sub, color=C['muted'], fontsize=7.5,
                fontfamily='DejaVu Sans', va='top', linespacing=1.25)

def repo(x, y, name, stars='', core=False):
    color = C['core'] if core else C['accent']
    weight = 'bold' if core else 'normal'
    ax.text(x, y, f"• {name}" + (f"  ({stars})" if stars else ''),
            color=color, fontsize=7.2 if not core else 7.8,
            fontweight=weight, fontfamily='DejaVu Sans', va='top')

# Title
ax.text(50, 66.2, 'Software Factory: Problem × Repo Overlap Map', color=C['text'],
        fontsize=18, fontweight='bold', ha='center', fontfamily='DejaVu Sans')
ax.text(50, 64.2, 'Verified 15 Oct 2026 · gold = recommended stitch core; cyan = strong adjacent',
        color=C['muted'], fontsize=9, ha='center', fontfamily='DejaVu Sans')

# Layout: 12 areas in a ring + center "factory glue"
# Row 1
region((1, 50), 23, 12.5, C['board'], '1. Board + multi-chat',
       'tasks, threads, sessions\npersistence per project')
repo(1.8, 59.5, 'vibe-kanban', '28k', True)
repo(1.8, 57.8, 'claude-squad', '8.6k', True)
repo(1.8, 56.1, 'claudecodeui / CloudCLI', '14k')
repo(1.8, 54.4, 'openclaw/acpx sessions', '3.3k')
repo(1.8, 52.7, 'LangGraph checkpoints', '43k')

region((26, 50), 23, 12.5, C['route'], '2+3. Job + model routing',
       'block pick · model pick · ask-user')
repo(26.8, 59.5, 'Jev (TypeSafe / OpenRouter)', '', True)
repo(26.8, 57.8, 'Laya (local System-1)', '33k', True)
repo(26.8, 56.1, 'LiteLLM gateway', '61k', True)
repo(26.8, 54.4, 'Plano + Arch-Router', '7k')
repo(26.8, 52.7, 'vLLM semantic-router', '6.2k')

region((51, 50), 23, 12.5, C['credit'], '4. Credits / usage',
       'NOT OpenRouter-only')
repo(51.8, 59.5, 'CodexBar + CLI + serve', '22.5k', True)
repo(51.8, 57.8, 'ccusage', '19k', True)
repo(51.8, 56.1, 'CodeBurn', '11k')
repo(51.8, 54.4, 'OpenUsage', '225')
repo(51.8, 52.7, 'Win-CodexBar / MeterBar', '')

region((76, 50), 23, 12.5, C['orch'], '5. Orchestrator + CLIs',
       'Claude plans · ACP workers')
repo(76.8, 59.5, 'Claude Code / Agent SDK', '151k', True)
repo(76.8, 57.8, 'ACP protocol + adapters', '4.5k', True)
repo(76.8, 56.1, 'Codex / opencode / Gemini / pi', '')
repo(76.8, 54.4, 'openai-agents-python', '30k')
repo(76.8, 52.7, 'goose (MCP recipes)', '55k')

# Row 2
region((1, 34), 23, 13.5, C['sand'], '6. Sandboxes / rooms',
       'worktrees · E2B · isolation')
repo(1.8, 44.5, 'git worktrees (native)', '', True)
repo(1.8, 42.8, 'E2B', '14k', True)
repo(1.8, 41.1, 'OpenHands sandbox ideas', '91k')
repo(1.8, 39.4, 'parallel-cc', '14')
repo(1.8, 37.7, 'Dagger', '16k')

region((26, 34), 23, 13.5, C['skill'], '7. Blocks / skills',
       'SKILL.md · builder · Hermes')
repo(26.8, 44.5, 'anthropics/skills', '181k', True)
repo(26.8, 42.8, 'Hermes Agent (learn+curator)', '254k', True)
repo(26.8, 41.1, 'ADAS meta-design', '1.6k')
repo(26.8, 39.4, 'A2A agent cards', '26k')
repo(26.8, 37.7, 'MCP registry', '7.4k')

region((51, 34), 23, 13.5, C['check'], '8. Checks + judges',
       'deterministic · rubric')
repo(51.8, 44.5, 'Playwright', '98k', True)
repo(51.8, 42.8, 'axe-core', '7.7k', True)
repo(51.8, 41.1, 'promptfoo evals', '26k')
repo(51.8, 39.4, 'StrongDM Attractor', '1.3k')
repo(51.8, 37.7, 'pytest / custom scripts', '')

region((76, 34), 23, 13.5, C['audit'], '9. Audit / timeline',
       'every decision visible')
repo(76.8, 44.5, 'Langfuse (self-host)', '36k', True)
repo(76.8, 42.8, 'Phoenix / OpenInference', '12k')
repo(76.8, 41.1, 'OTel GenAI semconv', '670')
repo(76.8, 39.4, 'SQLite decision log', '', True)
repo(76.8, 37.7, 'CodexBar serve JSON', '')

# Row 3
region((1, 18), 23, 13.5, C['local'], '10. Local models',
       'Ollama · vLLM · llama.cpp')
repo(1.8, 28.5, 'Ollama', '183k', True)
repo(1.8, 26.8, 'vLLM', '94k')
repo(1.8, 25.1, 'llama.cpp', '131k')
repo(1.8, 23.4, 'LiteLLM → local endpoints', '')
repo(1.8, 21.7, 'Laya offline decisions', '')

region((26, 18), 23, 13.5, C['trig'], '11. Triggers',
       'Slack · API · phone')
repo(26.8, 28.5, 'POST /cards (ours)', '', True)
repo(26.8, 26.8, 'n8n workflows', '207k')
repo(26.8, 25.1, 'Slack Bolt', '1.3k')
repo(26.8, 23.4, 'ntfy / webhooks', '')
repo(26.8, 21.7, 'Temporal (durable jobs)', '24k')

region((51, 18), 23, 13.5, C['ui'], '12. Dashboard / UI',
       'board · credits · audit')
repo(51.8, 28.5, 'vibe-kanban UI patterns', '', True)
repo(51.8, 26.8, 'claudecodeui / CloudCLI', '14k', True)
repo(51.8, 25.1, 'open-webui (chat shell)', '156k')
repo(51.8, 23.4, 'LobeHub multi-agent', '83k')
repo(51.8, 21.7, 'prototype dashboard :8787', '')

# Center: glue we write
region((76, 18), 23, 13.5, '#1a1a2e', 'WE WRITE (glue)',
       'thin harness, not a platform')
repo(76.8, 28.5, 'Job + model routers', '', True)
repo(76.8, 26.8, 'Credit ledger + tiers', '', True)
repo(76.8, 25.1, 'Block registry + builder', '', True)
repo(76.8, 23.4, 'ACP MCP tool for Claude', '', True)
repo(76.8, 21.7, 'Decision timeline UI', '', True)

# Overlap callouts (bottom strip)
ax.text(50, 15.5, 'KEY OVERLAPS (one repo covering multiple areas)',
        color=C['text'], fontsize=11, fontweight='bold', ha='center')

overlaps = [
    (2, 'CodexBar', 'credits + audit feed\n+ CLI serve for routing'),
    (22, 'LiteLLM', 'model pool + local\n+ Jev pass-through'),
    (42, 'ACP + Claude', 'orchestrator + all\nCLI subagents'),
    (62, 'Hermes + Skills', 'block format +\nauto-suggest + curator'),
    (82, 'vibe-kanban', 'board + rooms +\nmulti-chat UX'),
]
for x, title, body in overlaps:
    box = FancyBboxPatch((x, 2.2), 16, 11.5, boxstyle='round,pad=0.25,rounding_size=0.8',
                         facecolor='#162033', edgecolor=C['core'], linewidth=1.5, alpha=0.95)
    ax.add_patch(box)
    ax.text(x+8, 12.2, title, color=C['core'], fontsize=9, fontweight='bold',
            ha='center', fontfamily='DejaVu Sans')
    ax.text(x+8, 9.8, body, color=C['muted'], fontsize=7.5, ha='center',
            va='top', fontfamily='DejaVu Sans', linespacing=1.35)

plt.tight_layout(pad=0.4)
out = '/workspace/software-factory/docs/venn.png'
fig.savefig(out, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
print('wrote', out)
