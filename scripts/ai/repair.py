from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Any

import requests


MAX_RESPONSE = 180000
EXPERIENTIAL_PROVIDERS = {"experiential", "experiential-labs", "experiential_labs", "explabs"}


def _json(text: str) -> dict[str, Any]:
    text = text.strip()
    fenced = re.search(r"```(?:json)?\s*(.*?)\s*```", text, re.I | re.S)
    if fenced:
        text = fenced.group(1).strip()
    try:
        value = json.loads(text)
        if isinstance(value, dict):
            return value
    except json.JSONDecodeError:
        pass
    start = text.find("{")
    end = text.rfind("}")
    if start >= 0 and end > start:
        try:
            value = json.loads(text[start:end + 1])
            if isinstance(value, dict):
                return value
        except json.JSONDecodeError:
            pass
    return {}


def _prompt(repo: Path, log: str, diagnosis: dict[str, Any], context: str, previous: str = "") -> str:
    return f"""You are VoidOne's principal CI/package reliability engineer.

The product is C++23 + Qt6. Python is engineering automation only.
The observed failures are primarily GitHub Actions, Windows packaging,
Qt deployment, NSIS/WiX/MSI and artifact publication.

Diagnose the actual root cause and propose the smallest production-safe patch.
Prefer fixing configuration, packaging, workflow ordering, paths, tool versions,
artifact contracts and validation rather than changing application code.
Never disable tests/security, add telemetry, credentials, destructive commands,
or modify .ai/ or scripts/ai/ infrastructure.

Return ONLY JSON with:
{{"status":"PATCH|NO_FIX","diagnosis":"...","confidence":0-100,"patch":"unified git diff"}}

FAILURE:
{log[-24000:]}

DIAGNOSIS:
{json.dumps(diagnosis, ensure_ascii=False)}

PREVIOUS VALIDATION:
{previous or "none"}

REPOSITORY CONTEXT:
{context[:60000]}
""".strip()


def _gemini(prompt: str) -> dict[str, Any]:
    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("GEMINI_API_KEY is not configured")
    model = os.getenv("GEMINI_MODEL", "gemini-2.5-pro").strip()
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    response = requests.post(
        endpoint,
        headers={"x-goog-api-key": key, "Content-Type": "application/json"},
        json={
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.05, "responseMimeType": "application/json"},
        },
        timeout=180,
    )
    response.raise_for_status()
    data = response.json()
    text = data["candidates"][0]["content"]["parts"][0]["text"]
    return _json(text[:MAX_RESPONSE])


def _experiential_labs(prompt: str) -> dict[str, Any]:
    key = os.getenv("EXPLABS_API_KEY", "").strip()
    if not key:
        raise RuntimeError("EXPLABS_API_KEY is not configured")
    base_url = os.getenv("EXPLABS_BASE_URL", "https://api.experientiallabs.ai/v1").rstrip("/")
    model = os.getenv("EXPLABS_MODEL", "claude-fable-5.1").strip()
    response = requests.post(
        f"{base_url}/chat/completions",
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        json={
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.05,
        },
        timeout=180,
    )
    response.raise_for_status()
    data = response.json()
    text = data["choices"][0]["message"]["content"]
    if isinstance(text, list):
        text = "".join(str(part.get("text", "")) if isinstance(part, dict) else str(part) for part in text)
    return _json(str(text)[:MAX_RESPONSE])


def generate_patch(repo: Path, log: str, diagnosis: dict[str, Any], context: str, previous: str = "") -> dict[str, Any]:
    provider = os.getenv("AI_REPAIR_PROVIDER", "gemini").strip().lower()
    prompt = _prompt(repo, log, diagnosis, context, previous)
    if provider in EXPERIENTIAL_PROVIDERS:
        result = _experiential_labs(prompt)
    elif provider == "gemini":
        result = _gemini(prompt)
    else:
        raise RuntimeError(f"Unsupported AI_REPAIR_PROVIDER: {provider}")
    result["provider"] = provider
    result["model"] = os.getenv(
        "EXPLABS_MODEL" if provider in EXPERIENTIAL_PROVIDERS else "GEMINI_MODEL",
        "claude-fable-5.1" if provider in EXPERIENTIAL_PROVIDERS else "gemini-2.5-pro",
    ).strip()
    return result
