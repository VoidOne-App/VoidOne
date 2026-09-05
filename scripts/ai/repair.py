from __future__ import annotations

import json
import os
import re
from pathlib import Path
from typing import Any

import requests


MAX_RESPONSE = 180000
EXPERIENTIAL_PROVIDERS = {"experiential", "experiential-labs", "experiential_labs", "explabs"}
DEFAULT_BASE_URL = "https://api.experientiallabs.ai/v1"
DEFAULT_MODELS = {
    "diagnosis": "deepseek-v4-flash",
    "second_opinion": "qwen3.8-27b",
    "repair": "claude-fable-5.1",
    "review": "gpt-5.6-luna",
}


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


def _prompt(repo: Path, log: str, diagnosis: dict[str, Any], context: str, previous: str = "", model_feedback: str = "") -> str:
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

LOCAL DIAGNOSIS:
{json.dumps(diagnosis, ensure_ascii=False)}

MODEL FEEDBACK:
{model_feedback or "none"}

PREVIOUS VALIDATION:
{previous or "none"}

REPOSITORY CONTEXT:
{context[:60000]}
""".strip()


def _experiential_config() -> tuple[str, str]:
    key = os.getenv("EXPLABS_API_KEY", "").strip()
    if not key:
        raise RuntimeError("EXPLABS_API_KEY is not configured")
    return os.getenv("EXPLABS_BASE_URL", DEFAULT_BASE_URL).rstrip("/"), key


def _experiential_models() -> set[str]:
    base_url, key = _experiential_config()
    response = requests.get(
        f"{base_url}/models",
        headers={"Authorization": f"Bearer {key}"},
        timeout=30,
    )
    response.raise_for_status()
    data = response.json()
    return {str(item.get("id", "")) for item in data.get("data", []) if isinstance(item, dict)}


def _experiential_call(model: str, prompt: str) -> dict[str, Any]:
    base_url, key = _experiential_config()
    available = _experiential_models()
    if model not in available:
        raise RuntimeError(f"Experiential model is not available to this key: {model}")

    # Experiential's official quickstart recommends a minimal OpenAI-compatible
    # request. In particular, some Claude routes reject sampling parameters.
    response = requests.post(
        f"{base_url}/chat/completions",
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        json={"model": model, "messages": [{"role": "user", "content": prompt}]},
        timeout=180,
    )
    response.raise_for_status()
    data = response.json()
    text = data["choices"][0]["message"]["content"]
    if isinstance(text, list):
        text = "".join(str(part.get("text", "")) if isinstance(part, dict) else str(part) for part in text)
    return _json(str(text)[:MAX_RESPONSE])


def _model(role: str) -> str:
    return os.getenv(f"EXPLABS_{role.upper()}_MODEL", DEFAULT_MODELS[role]).strip()


def _model_analysis(prompt: str) -> str:
    result = _experiential_call(_model("diagnosis"), prompt)
    return json.dumps(result, ensure_ascii=False)


def _second_opinion(prompt: str) -> str:
    result = _experiential_call(_model("second_opinion"), prompt)
    return json.dumps(result, ensure_ascii=False)


def generate_patch(repo: Path, log: str, diagnosis: dict[str, Any], context: str, previous: str = "") -> dict[str, Any]:
    provider = os.getenv("AI_REPAIR_PROVIDER", "experiential-labs").strip().lower()
    if provider not in EXPERIENTIAL_PROVIDERS:
        raise RuntimeError("VoidOne's zero-budget repair pipeline requires AI_REPAIR_PROVIDER=experiential-labs")

    analysis_prompt = f"""You are VoidOne's fast CI failure analyst.
Return ONLY JSON with keys: root_cause, evidence, proposed_fix, confidence.
Do not write a patch. Focus on the actual failure and the smallest safe fix.

CI FAILURE:
{log[-24000:]}

LOCAL DIAGNOSIS:
{json.dumps(diagnosis, ensure_ascii=False)}

REPOSITORY CONTEXT:
{context[:40000]}"""
    fast_analysis = _model_analysis(analysis_prompt)

    second_prompt = f"""You are VoidOne's second-opinion CI engineer.
Return ONLY JSON with keys: agreement, risks, recommendation, confidence.
Challenge the first diagnosis. Do not write a patch.

FIRST ANALYSIS:
{fast_analysis}

CI FAILURE:
{log[-18000:]}

LOCAL DIAGNOSIS:
{json.dumps(diagnosis, ensure_ascii=False)}"""
    second_opinion = _second_opinion(second_prompt)

    repair_prompt = _prompt(
        repo,
        log,
        diagnosis,
        context,
        previous,
        model_feedback=f"Fast diagnosis: {fast_analysis}\nSecond opinion: {second_opinion}",
    )
    result = _experiential_call(_model("repair"), repair_prompt)
    result["provider"] = provider
    result["model"] = _model("repair")
    result["analysis_model"] = _model("diagnosis")
    result["second_opinion_model"] = _model("second_opinion")
    result["analysis"] = _json(fast_analysis)
    result["second_opinion"] = _json(second_opinion)
    return result
