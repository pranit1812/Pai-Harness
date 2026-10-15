"""Task board on SQLite: new -> picked_up -> done/failed, plus block run log."""
import sqlite3, json, time, threading
_lock = threading.Lock()
class Board:
    def __init__(self, path):
        self.db = sqlite3.connect(path, check_same_thread=False)
        self.db.executescript("""
        create table if not exists cards(id integer primary key, title text, pipeline text, payload text,
          status text default 'new', source text, result text, created real, updated real);
        create table if not exists runs(id integer primary key, card integer, block text, worker text,
          model text, attempt int, status text, detail text, ts real);""")
    def q(self, sql, *a):
        with _lock:
            cur = self.db.execute(sql, a); self.db.commit(); return cur
    def add(self, title, pipeline, payload, source="cli"):
        t = time.time()
        return self.q("insert into cards(title,pipeline,payload,source,created,updated) values(?,?,?,?,?,?)",
                      title, pipeline, json.dumps(payload), source, t, t).lastrowid
    def pick(self):
        with _lock:
            r = self.db.execute("select id from cards where status='new' order by id limit 1").fetchone()
            if not r: return None
            self.db.execute("update cards set status='picked_up',updated=? where id=?", (time.time(), r[0])); self.db.commit()
        return self.get(r[0])
    def get(self, cid):
        r = self.q("select id,title,pipeline,payload,status,source,result from cards where id=?", cid).fetchone()
        return dict(zip(["id","title","pipeline","payload","status","source","result"], r))
    def finish(self, cid, status, result):
        self.q("update cards set status=?,result=?,updated=? where id=?", status, json.dumps(result), time.time(), cid)
    def log(self, card, block, worker, model, attempt, status, detail=""):
        self.q("insert into runs(card,block,worker,model,attempt,status,detail,ts) values(?,?,?,?,?,?,?,?)",
               card, block, worker, model, attempt, status, str(detail)[:500], time.time())
    def snapshot(self):
        cards = [dict(zip(["id","title","status","source","result"], r)) for r in
                 self.q("select id,title,status,source,result from cards order by id desc limit 50")]
        runs = [dict(zip(["card","block","worker","model","attempt","status","detail","ts"], r)) for r in
                self.q("select card,block,worker,model,attempt,status,detail,ts from runs order by id desc limit 200")]
        return {"cards": cards, "runs": runs}
