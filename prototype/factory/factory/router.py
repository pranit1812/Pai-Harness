"""Omni router: one call() across mock, cloud (LiteLLM/OpenAI-compatible) and local (Ollama, llama.cpp, vLLM) endpoints."""
import json, os, re, urllib.request

def _http(base, model, messages, key=None, timeout=120):
    req = urllib.request.Request(base.rstrip("/") + "/chat/completions",
        data=json.dumps({"model": model, "messages": messages, "temperature": 0.2}).encode(),
        headers={"Content-Type": "application/json", "Authorization": f"Bearer {key or 'none'}"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.load(r)["choices"][0]["message"]["content"]

def ollama_models(base):
    try:
        with urllib.request.urlopen(base.replace("/v1", "") + "/api/tags", timeout=2) as r:
            return [m["name"] for m in json.load(r)["models"]]
    except Exception:
        return []

class Router:
    def __init__(self, cfg):
        self.cfg = cfg
        self.models = dict(cfg["models"])
        local = ollama_models(cfg.get("auto_local", "http://localhost:11434/v1"))
        for m in local:  # auto-register every local Ollama model
            self.models[f"ollama/{m}"] = {"provider": "openai", "base_url": cfg["auto_local"], "model": m}
        self.local = local

    def call(self, name, messages, ctx=None):
        spec = self.models[name]
        if spec["provider"] == "mock":
            from .mock import mock_reply
            return mock_reply(spec, messages, ctx or {})
        key = os.environ.get(spec.get("api_key_env", ""), None)
        return _http(spec["base_url"], spec["model"], messages, key)

def extract_files(text):
    """Parse ```path\n...``` fenced blocks from model output into {path: content}."""
    return {m.group(1).strip(): m.group(2) for m in re.finditer(r"```(?:file:)?([\w./-]+\.\w+)\n(.*?)```", text, re.S)}
