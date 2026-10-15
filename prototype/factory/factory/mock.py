"""Offline deterministic mock models so the factory runs with zero keys."""
import json
GOOD = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>Glitch Factory</title>
<meta name="viewport" content="width=device-width, initial-scale=1"></head>
<body><header><h1>Glitch Factory</h1><nav><a href="#features">Features</a></nav></header>
<main><section id="hero"><p>Ship software with agents, verified by code.</p><a id="cta" href="#signup">Get started</a></section>
<section id="features"><h2>Features</h2><ul><li>Router</li><li>Rooms</li><li>Judges</li></ul></section></main>
<footer><p>2026</p></footer></body></html>
"""
MIN = """<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>Factory</title></head>
<body><h1>Factory</h1><a id="cta" href="#">Start</a></body></html>
"""
BROKEN = """<html><body><h1>Factory<div><p>oops</body>"""
TEST = """import re, pathlib
html = pathlib.Path(__file__).with_name('index.html').read_text()
assert '<title>' in html, 'missing title'
assert 'id="cta"' in html, 'missing call to action'
print('ok')
"""
def mock_reply(spec, messages, ctx):
    last = messages[-1]["content"]
    if "JUDGE" in messages[0]["content"]:
        # fresh-context judge: scores on length/structure of what it is shown
        cands = json.loads(last.split("CANDIDATES:", 1)[1])
        scores = {k: min(10, 3 + v.count("<section") * 2 + v.count("<meta") + v.count("<nav")) for k, v in cands.items()}
        win = max(scores, key=scores.get)
        return json.dumps({"winner": win, "scores": scores, "reason": "most complete semantic structure"})
    style = spec.get("style", "full")
    if style == "broken" and "FAILED CHECKS" in last:
        style = "minimal"  # learns from deterministic feedback on retry
    html = {"full": GOOD, "minimal": MIN, "broken": BROKEN}[style]
    return f"```index.html\n{html}```\n```test_page.py\n{TEST}```"
