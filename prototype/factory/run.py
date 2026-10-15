#!/usr/bin/env python3
"""One command: python3 run.py [--demo] [--port 8787] [--once]"""
import argparse, json, threading, pathlib
from factory.board import Board; from factory.router import Router
from factory.engine import Ctx, listener, ROOT; from factory.server import serve; from factory.pipelines import PIPELINES
ap = argparse.ArgumentParser(); ap.add_argument("--demo", action="store_true"); ap.add_argument("--once", action="store_true")
ap.add_argument("--port", type=int, default=8787); ap.add_argument("--config", default="config.json"); a = ap.parse_args()
ctx = Ctx(); ctx.root = ROOT; ctx.cfg = json.load(open(ROOT / a.config)); ctx.router = Router(ctx.cfg)
(ROOT / "data").mkdir(exist_ok=True); ctx.board = Board(str(ROOT / "data" / "board.db"))
if ctx.router.local and not any(ctx.router.models[w]["provider"] != "mock" for w in ctx.cfg["split_workers"]):
    print("Ollama detected:", ctx.router.local, "(set split_workers to ollama/<name> in config.json to use)")
if a.demo: print("demo card", ctx.board.add("Build a small landing page", "landing_page", PIPELINES["landing_page"], "demo"))
stop = threading.Event()
if a.once: listener(ctx, stop, once=True); print(json.dumps(ctx.board.snapshot()["cards"][:1], indent=1)); raise SystemExit
threading.Thread(target=listener, args=(ctx, stop), daemon=True).start()
print(f"dashboard: http://localhost:{a.port}"); serve(ctx, a.port).serve_forever()
