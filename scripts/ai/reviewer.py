from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Any

import requests

DEFAULT_BASE_URL = "https://api.experientiallabs.ai/v1"
DEFAULT_REVIEW_MODEL = "gpt-5.6-luna"


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


def _experiential_models(base_url: str, key: str) -> set[str]:
    response = requests.get(
        f"{base_url}/models",
        headers={"Authorization": f"Bearer {key}"},
        timeout=30,
    )
    response.raise_for_status()
    data = response.json()
    return {str(item.get("id", "")) for item in data.get("data", []) if isinstance(item, dict)}


def review(repo: Path, log: str, patch: str, diagnosis: dict[str, Any], policy: Any) -> tuple[bool, str]:
    del repo, policy
    key = os.getenv("EXPLABS_API_KEY", "").strip()
    if not key:
        return False, "Independent reviewer unavailable: EXPLABS_API_KEY is missing."

    base_url = os.getenv("EXPLABS_BASE_URL", DEFAULT_BASE_URL).rstrip("/")
    model = os.getenv("EXPLABS_REVIEW_MODEL", DEFAULT_REVIEW_MODEL).strip()
    try:
        available = _experiential_models(base_url, key)
        if model not in available:
            return False, f"Independent reviewer model is not available to this key: {model}"

        # Keep this request minimal. Experiential documents that some Claude
        # routes reject explicit sampling parameters, so the reviewer sends only
        # model + messages and lets the gateway/model defaults apply.
        response = requests.post(
            f"{base_url}/chat/completions",
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            json={"model": model, "messages": [{"role": "user", "content": _review_prompt(log, diagnosis, patch)}]},
            timeout=150,
        )
        response.raise_for_status()
        data = response.json()
        text = data["choices"][0]["message"]["content"]
        if isinstance(text, list):
            text = "".join(str(part.get("text", "")) if isinstance(part, dict) else str(part) for part in text)
        result = _parse(str(text))
        decision = result.get("decision")
        confidence = float(result.get("confidence", 0))
        reason = str(result.get("reason", ""))
        if decision == "APPROVE" and confidence >= 70:
            return True, f"{model}: {reason}"
        return False, f"Reviewer rejected patch ({confidence:.0f}%): {reason}"
    except Exception as exc:
        return False, f"Independent reviewer failed: {exc}"
