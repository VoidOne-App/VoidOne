from __future__ import annotations
from pathlib import Path
import os, requests
from .policy import Policy

def review(repo: Path, log: str, patch: str, diagnosis: dict, policy: Policy) -> tuple[bool, str]:
    import re
    files = re.findall(r"^\+\+\+ b/(.+)$", patch, re.M)
    if not files or any(not policy.allowed_path(f) for f in files):
        return False, "Patch touches a forbidden or non-approved path."
    if re.search(r"(?i)(api[_-]?key|password|private[_-]?key|BEGIN .* PRIVATE KEY)", patch):
        return False, "Potential secret detected."
    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key: return False, "Independent reviewer unavailable."
    model = os.getenv("GEMINI_REVIEW_MODEL", os.getenv("GEMINI_MODEL", "gemini-2.5-pro"))
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    prompt = "Review this candidate patch for VoidOne. Reject unrelated changes, security weakening, test disabling, secret exposure, workflow abuse, or failure to fix the stated CI issue. Return APPROVE or REJECT with a reason.\n\nFAILURE:\n" + log[-10000:] + "\n\nPATCH:\n" + patch[:60000]
    try:
        r = requests.post(endpoint, headers={"x-goog-api-key": key}, json={"contents":[{"parts":[{"text":prompt}]}],"generationConfig":{"temperature":0}}, timeout=150)
        r.raise_for_status()
        text = r.json()["candidates"][0]["content"]["parts"][0]["text"]
        return (text.upper().startswith("APPROVE"), text[:2000])
    except Exception as exc:
        return False, f"Reviewer failed: {exc}"
