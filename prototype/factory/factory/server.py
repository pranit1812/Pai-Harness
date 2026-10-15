"""Dashboard + trigger API (stdlib only). POST /cards to add a card from phone/Slack/webhook."""
import json, http.server, pathlib
DASH = pathlib.Path(__file__).with_name("dashboard.html").read_text()
def serve(ctx, port):
    class H(http.server.BaseHTTPRequestHandler):
        def log_message(self, *a): pass
        def _send(self, body, ct="application/json"):
            b = body.encode(); self.send_response(200); self.send_header("Content-Type", ct); self.end_headers(); self.wfile.write(b)
        def do_GET(self):
            if self.path.startswith("/api/state"):
                s = ctx.board.snapshot(); s["models"] = list(ctx.router.models); s["local"] = ctx.router.local
                return self._send(json.dumps(s))
            if self.path.startswith("/output/"):
                f = ctx.root / self.path.lstrip("/")
                if f.exists(): return self._send(f.read_text(), "text/html")
            self._send(DASH, "text/html")
        def do_POST(self):
            d = json.loads(self.rfile.read(int(self.headers["Content-Length"])) or "{}")
            from .pipelines import PIPELINES
            pl = d.get("pipeline", "landing_page")
            cid = ctx.board.add(d.get("title", pl), pl, {**PIPELINES[pl], **d.get("payload", {})}, d.get("source", "api"))
            self._send(json.dumps({"id": cid}))
    srv = http.server.ThreadingHTTPServer(("0.0.0.0", port), H); return srv
