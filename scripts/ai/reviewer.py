from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Any

import requests


def _parse(text: str) -> dict[str, Any]:
    text = text.strip()
    m = re.search(r"```(?:json)?\s*(.*?)\s*```", text, re.I | re.S)
    if m:
        text = m.group(1).strip()
    try:
        value = json.loads(text)
        return value if isinstance(value, dict) else {}
    except json.JSONDecodeError:
        start, end = text.find("{"), text.rfind("}")
        if start >= 0 and end > start:
            try:
                value = json.loads(text[start:end + 1])
                return value if isinstance(value, dict) else {}
            except json.JSONDecodeError:
                pass
    return {}


def _review_prompt(log: str, diagnosis: dict[str, Any], patch: str) -> str:
    return f"""Act as an independent VoidOne release/security reviewer.

Review this candidate patch against the CI failure. Reject unrelated or broad
changes, workflow permission escalation, secret/credential material, telemetry,
destructive commands, disabled tests, unsafe artifact handling, broken Windows
packaging, invalid YAML, invalid NSIS/WiX, or a patch that does not plausibly fix
the failure. The product remains C++23/Qt6; Python changes are tooling only.

Return ONLY JSON:
{{"decision":"APPROVE|REJECT","confidence":0-100,"reason":"..."}}

DIAGNOSIS:
{json.dumps(diagnosis, ensure_ascii=False)}

CI FAILURE:
{log[-18000:]}

PATCH:
{patch[:100000]}
""".strip()


def review(repo: Path, log: str, patch: str, diagnosis: dict[str, Any], policy: Any) -> tuple[bool, str]:
    del repo, policy
    key = os.getenv("GEMINI_API_KEY", "").strip()
    if not key:
        return False, "Independent reviewer unavailable: GEMINI_API_KEY is missing."
    model = os.getenv("GEMINI_REVIEW_MODEL", os.getenv("GEMINI_MODEL", "gemini-2.5-pro")).strip()
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    try:
        response = requests.post(
            endpoint,
            headers={"x-goog-api-key": key, "Content-Type": "application/json"},
            json={
                "contents": [{"parts": [{"text": _review_prompt(log, diagnosis, patch)}]}],
                "generationConfig": {"temperature": 0.0, "responseMimeType": "application/json"},
            },
            timeout=150,
        )
        response.raise_for_status()
        data = response.json()
        text = data["candidates"][0]["content"]["parts"][0]["text"]
        result = _parse(text)
        decision = result.get("decision")
        confidence = float(result.get("confidence", 0))
        reason = str(result.get("reason", ""))
        if decision == "APPROVE" and confidence >= 70:
            return True, reason
        return False, f"Reviewer rejected patch ({confidence:.0f}%): {reason}"
    except Exception as exc:
        return False, f"Independent reviewer failed: {exc}"
