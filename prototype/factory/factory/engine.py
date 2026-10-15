"""Listener + SPLIT: fan a card out to N workers, each in its own git worktree (cloud room), each a different model."""
import json, os, subprocess, pathlib, shutil, threading, time
from concurrent.futures import ThreadPoolExecutor
from .blocks import agent_block, judge_block

ROOT = pathlib.Path(__file__).resolve().parent.parent
class Ctx: pass
_room_lock = threading.Lock()

def make_room(card, worker):
    """Isolated room: git worktree on its own branch. Swap for docker/E2B by changing this function."""
    with _room_lock:
        return _make_room(card, worker)

def _make_room(card, worker):
    repo = ROOT / "rooms" / "repo"
    if not (repo / ".git").exists():
        repo.mkdir(parents=True, exist_ok=True)
        subprocess.run(["git", "init", "-q", "-b", "main"], cwd=repo)
        (repo / "README.md").write_text("factory output repo\n")
        subprocess.run(["git", "-c", "user.email=f@f", "-c", "user.name=factory", "add", "-A"], cwd=repo)
        subprocess.run(["git", "-c", "user.email=f@f", "-c", "user.name=factory", "commit", "-qm", "init"], cwd=repo)
    wd = ROOT / "rooms" / f"card{card}-{worker}"
    if wd.exists():
        subprocess.run(["git", "worktree", "remove", "--force", str(wd)], cwd=repo); shutil.rmtree(wd, ignore_errors=True)
    subprocess.run(["git", "worktree", "add", "-q", "-B", f"card{card}/{worker}", str(wd)], cwd=repo, check=True)
    subprocess.run(["git", "config", "user.email", "factory@local"], cwd=wd); subprocess.run(["git", "config", "user.name", worker], cwd=wd)
    return wd

def run_card(ctx, card):
    p = json.loads(card["payload"]); cfg = ctx.cfg; cid = card["id"]
    workers = p.get("workers") or cfg["split_workers"]
    def one(i_model):
        i, model = i_model; w = f"w{i+1}"
        wd = make_room(cid, w)
        r = agent_block(ctx, ctx.board, cid, w, model, p["goal"], wd, p["checks"], cfg["max_retries"])
        r.update(worker=w, model=model, room=str(wd)); return r
    with ThreadPoolExecutor(len(workers)) as ex:
        results = list(ex.map(one, enumerate(workers)))
    passed = {r["worker"]: pathlib.Path(r["room"], "index.html").read_text() for r in results if r["ok"]}
    if not passed:
        ctx.board.finish(cid, "failed", {"results": results}); return
    verdict = judge_block(ctx, ctx.board, cid, cfg["judge"], passed)
    win = next(r for r in results if r["worker"] == verdict["winner"])
    out = ROOT / "output" / f"card{cid}"; out.mkdir(parents=True, exist_ok=True)
    shutil.copy(pathlib.Path(win["room"], "index.html"), out / "index.html")
    ctx.board.log(cid, "save", win["worker"], win["model"], 0, "saved", str(out / "index.html"))
    ctx.board.finish(cid, "done", {"winner": win, "verdict": verdict, "results": results, "awaiting": "human final verify"})

def listener(ctx, stop, once=False):
    while not stop.is_set():
        card = ctx.board.pick()
        if card:
            try: run_card(ctx, card)
            except Exception as e: ctx.board.finish(card["id"], "failed", {"error": repr(e)})
        elif once: return
        else: time.sleep(1)
