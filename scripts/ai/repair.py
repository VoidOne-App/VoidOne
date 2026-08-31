from __future__ import annotations
from pathlib import Path
import os, requests
from .diagnosis import diagnose

PROMPT = """You are VoidOne's CI repair engineer. Diagnose the supplied failure and return ONLY a unified git diff. Prioritize GitHub Actions, Windows packaging, Qt deployment, NSIS, WiX, MSI and artifacts. Make the smallest safe fix. Never modify .ai/, scripts/ai/, validators or the repair engine. Never disable tests or security."""

def generate_patch(repo: Path, log: str, diagnosis: dict) -> str:
    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("GEMINI_API_KEY is required for patch generation")
    model = os.getenv("GEMINI_MODEL", "gemini-2.5-pro")
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    context = []
    for rel in diagnosis.get("workflow_files", [])[:20] + diagnosis.get("package_files", [])[:20]:
        p = repo / rel
        if p.is_file():
            context.append(f"=== {rel} ===\n{p.read_text(encoding='utf-8', errors='replace')[:16000]}")
    prompt = PROMPT + "\n\nFAILURE:\n" + log[-16000:] + "\n\nCONTEXT:\n" + "\n\n".join(context)
    r = requests.post(endpoint, headers={"x-goog-api-key": key}, json={"contents":[{"parts":[{"text":prompt}]}],"generationConfig":{"temperature":0.1}}, timeout=180)
    r.raise_for_status()
    return r.json()["candidates"][0]["content"]["parts"][0]["text"].strip().replace("```diff", "").replace("```", "").strip()
