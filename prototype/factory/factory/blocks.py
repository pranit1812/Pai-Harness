"""Lego blocks: agent -> deterministic checks -> retry with feedback -> judge (fresh context)."""
import json, os, subprocess, html.parser, pathlib
from .router import extract_files

class _V(html.parser.HTMLParser):
    VOID = {"meta","link","br","img","input","hr","area","base","col","embed","source","track","wbr"}
    def __init__(s): super().__init__(); s.stack=[]; s.err=[]
    def handle_starttag(s,t,a):
        if t not in s.VOID: s.stack.append(t)
    def handle_endtag(s,t):
        if t in s.VOID: return
        if not s.stack or s.stack[-1]!=t: s.err.append(f"unexpected </{t}> (open: {s.stack[-1] if s.stack else None})")
        else: s.stack.pop()

# ---- deterministic checks (code, not model) ----
def check_file_exists(wd):
    return (pathlib.Path(wd, "index.html").exists(), "index.html present")
def check_html_valid(wd):
    p = pathlib.Path(wd, "index.html")
    if not p.exists(): return False, "no file"
    src = p.read_text(); v = _V(); v.feed(src)
    errs = v.err + ([f"unclosed {v.stack}"] if v.stack else [])
    if not src.lower().lstrip().startswith("<!doctype html"): errs.append("missing doctype")
    return (not errs, "; ".join(errs) or "valid")
def check_tests_pass(wd):
    if not pathlib.Path(wd, "test_page.py").exists(): return False, "no test_page.py"
    r = subprocess.run(["python3", "test_page.py"], cwd=wd, capture_output=True, text=True, timeout=30)
    return (r.returncode == 0, (r.stdout + r.stderr).strip()[-300:])
CHECKS = {"file_exists": check_file_exists, "html_valid": check_html_valid, "tests_pass": check_tests_pass}

def agent_block(ctx, board, card, worker, model, goal, wd, checks, max_retries):
    """Agent step + checks; on failure the check output is fed back to the agent."""
    msgs = [{"role": "system", "content": "You are a coding agent. Reply ONLY with fenced files like ```index.html\\n...```. Always include index.html and test_page.py."},
            {"role": "user", "content": goal}]
    for attempt in range(1, max_retries + 2):
        board.log(card, "agent", worker, model, attempt, "running")
        out = ctx.router.call(model, msgs)
        for name, body in extract_files(out).items():
            pathlib.Path(wd, name).write_text(body)
        res = {c: CHECKS[c](wd) for c in checks}
        failed = {k: v[1] for k, v in res.items() if not v[0]}
        for k, (ok, d) in res.items():
            board.log(card, f"check:{k}", worker, model, attempt, "pass" if ok else "fail", d)
        if not failed:
            subprocess.run(["git", "add", "-A"], cwd=wd); subprocess.run(["git", "commit", "-qm", f"{worker} attempt {attempt}"], cwd=wd)
            return {"ok": True, "attempts": attempt}
        msgs += [{"role": "assistant", "content": out},
                 {"role": "user", "content": "FAILED CHECKS:\n" + json.dumps(failed) + "\nFix and resend all files."}]
    return {"ok": False, "attempts": attempt, "failed": failed}

def judge_block(ctx, board, card, model, candidates):
    """Judge in a FRESH context: sees only the goal and artifacts, never the agents' chat."""
    msgs = [{"role": "system", "content": "You are a JUDGE. Pick the best landing page. Reply JSON {winner, scores, reason}."},
            {"role": "user", "content": "CANDIDATES:" + json.dumps(candidates)}]
    board.log(card, "judge", "judge", model, 1, "running")
    out = ctx.router.call(model, msgs)
    try: v = json.loads(out[out.index("{"): out.rindex("}") + 1])
    except Exception: v = {"winner": next(iter(candidates)), "reason": "judge unparsable, fallback"}
    if v.get("winner") not in candidates: v["winner"] = next(iter(candidates))  # deterministic guard
    board.log(card, "judge", "judge", model, 1, "verdict", json.dumps(v))
    return v
