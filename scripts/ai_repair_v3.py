#!/usr/bin/env python3
"""VoidOne Autonomous AI CI Repair Engine v3.

Generates and validates a minimal candidate patch. Repository validation is
performed by the real VoidOne CI workflow after the candidate branch is pushed,
so Windows/MSVC/Qt/installer behavior is tested by the authoritative pipeline.
This process never pushes, merges, changes the repair engine, or edits Git data.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import logging
import os
import re
import subprocess
import tempfile
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any

import requests

LOG = logging.getLogger("VoidOneAIRepair")
logging.basicConfig(level=logging.INFO, format="[VOIDONE-AI-V3] %(levelname)s %(message)s")

ENGINE_VERSION = "3.0.0"
MAX_LOG = 24_000
MAX_CONTEXT = 80_000
MAX_PATCH = 120_000
MAX_FILES = 25
MAX_ADD = 1_500
MAX_DEL = 1_500
REQUEST_TIMEOUT = 180

PROTECTED = {
    ".git",
    ".github/workflows/ai-repair.yml",
    "scripts/ai_repair.py",
    "scripts/ai_repair_v3.py",
    "scripts/requirements-ai-repair.txt",
}

EXTENSIONS = {
    ".c", ".cc", ".cpp", ".cxx", ".h", ".hh", ".hpp", ".hxx",
    ".qml", ".qrc", ".ui", ".cmake", ".py", ".pyw", ".sh", ".bash",
    ".ps1", ".bat", ".cmd", ".yml", ".yaml", ".nsi", ".nsh", ".wxs",
    ".wxi", ".json", ".xml", ".rc", ".ini", ".cfg", ".conf", ".toml",
    ".txt", ".md",
}

DANGEROUS = (
    r"\bgit\s+(?:push|reset|clean|checkout)\b",
    r"\brm\s+-rf\b",
    r"\bmkfs(?:\.|\s)\b",
    r"\bdd\s+if=",
    r"\b(?:curl|wget)\b[^\n]*\|\s*(?:sh|bash|pwsh|powershell)\b",
    r"\b(?:Invoke-WebRequest|iwr)\b[^\n]*\|\s*(?:iex|Invoke-Expression)\b",
)

SECRETS = (
    r"-----BEGIN [^-]+ PRIVATE KEY-----",
    r"\bgh[pousr]_[A-Za-z0-9_]{20,}\b",
    r"\bgithub_pat_[A-Za-z0-9_]{20,}\b",
    r"\bAIza[0-9A-Za-z_-]{20,}\b",
    r"(?i)\b(?:api[_-]?key|secret|password|token)\s*[:=]\s*['\"][^'\"]{12,}['\"]",
)

@dataclass
class Metrics:
    files: int = 0
    added: int = 0
    removed: int = 0
    chars: int = 0

@dataclass
class Report:
    engine_version: str
    category: str
    diagnosis: str = ""
    confidence: float = 0
    patch_hash: str = ""
    metrics: Metrics = field(default_factory=Metrics)
    review_decision: str = ""
    review_confidence: float = 0
    review_reason: str = ""
    status: str = "FAILED"
    reason: str = ""
    duration_seconds: float = 0


def run(cmd: list[str], cwd: Path, timeout: int = 60) -> tuple[int, str, str]:
    LOG.info("$ %s", " ".join(cmd))
    try:
        p = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True, timeout=timeout, errors="replace")
        return p.returncode, p.stdout, p.stderr
    except subprocess.TimeoutExpired as exc:
        return -1, exc.stdout or "", f"timeout after {timeout}s\n{exc.stderr or ''}"
    except OSError as exc:
        return -1, "", str(exc)


def norm(path: str) -> str | None:
    p = path.strip().replace("\\", "/")
    if not p or p.startswith("/") or re.match(r"^[A-Za-z]:/", p):
        return None
    while p.startswith("./"):
        p = p[2:]
    parts = Path(p).parts
    if ".." in parts:
        return None
    return p


def protected(path: str) -> bool:
    p = (norm(path) or "").rstrip("/")
    return any(p == x or p.startswith(x + "/") for x in PROTECTED)


def allowed(path: str) -> bool:
    p = norm(path)
    if not p or protected(p):
        return False
    name = Path(p).name
    return name in {"CMakeLists.txt", "Makefile", "Dockerfile"} or Path(p).suffix.lower() in EXTENSIONS


def patch_files(patch: str) -> list[str]:
    found: set[str] = set()
    for line in patch.splitlines():
        if line.startswith(("--- ", "+++ ")):
            raw = line[4:].split("\t", 1)[0].strip()
            if raw in {"/dev/null", "a/dev/null", "b/dev/null"}:
                continue
            if raw.startswith(("a/", "b/")):
                raw = raw[2:]
            p = norm(raw)
            if p:
                found.add(p)
        elif line.startswith(("rename from ", "rename to ")):
            p = norm(line.split(" ", 2)[2])
            if p:
                found.add(p)
    return sorted(found)


def metrics(patch: str) -> Metrics:
    return Metrics(
        files=len(patch_files(patch)),
        added=sum(1 for x in patch.splitlines() if x.startswith("+") and not x.startswith("+++")),
        removed=sum(1 for x in patch.splitlines() if x.startswith("-") and not x.startswith("---")),
        chars=len(patch),
    )


def validate_patch(patch: str) -> tuple[bool, str, Metrics]:
    m = metrics(patch)
    if not patch.strip(): return False, "empty patch", m
    if len(patch) > MAX_PATCH: return False, "patch too large", m
    if "\x00" in patch: return False, "NUL byte", m
    if not re.search(r"^--- (?:a/.+|/dev/null)$", patch, re.M) or not re.search(r"^\+\+\+ (?:b/.+|/dev/null)$", patch, re.M):
        return False, "not a unified git diff", m
    if not m.files: return False, "no changed files", m
    if m.files > MAX_FILES: return False, "too many files", m
    if m.added > MAX_ADD or m.removed > MAX_DEL: return False, "patch line limit exceeded", m
    for path in patch_files(patch):
        if not allowed(path): return False, f"disallowed path: {path}", m
    added = "\n".join(x[1:] for x in patch.splitlines() if x.startswith("+") and not x.startswith("+++"))
    for pattern in DANGEROUS:
        if re.search(pattern, added, re.I): return False, f"dangerous command: {pattern}", m
    for pattern in SECRETS:
        if re.search(pattern, added): return False, "possible secret in patch", m
    return True, "ok", m


def read(path: Path, limit: int = 14_000) -> str:
    try:
        s = path.read_text(encoding="utf-8", errors="replace")
        return s if len(s) <= limit else s[:limit] + "\n...[TRUNCATED]..."
    except OSError:
        return ""


def context(repo: Path, log: str) -> str:
    files = ["CMakeLists.txt", "CMakePresets.json", "BUILD.md", "README.md", "SECURITY.md", "installer.nsi", "installer.wxs"]
    candidates: set[str] = set(files)
    for match in re.findall(r"(?:\.github/)?[A-Za-z0-9_.\-/]+\.(?:cpp|cc|cxx|h|hpp|qml|cmake|py|ps1|yml|yaml|nsi|nsh|wxs|wxi|json|xml)", log):
        p = norm(match)
        if p and not protected(p) and (repo / p).is_file(): candidates.add(p)
    chunks = []
    for p in sorted(candidates):
        text = read(repo / p)
        if text: chunks.append(f"=== FILE: {p} ===\n{text}")
    result = "\n\n".join(chunks)
    return result[:MAX_CONTEXT] + ("\n...[TRUNCATED]..." if len(result) > MAX_CONTEXT else "")


def category(log: str) -> str:
    t = log.lower()
    rules = {
        "packaging": ("nsis", "wix", "msi", "installer"),
        "qml": ("qqml", "qtquick", "qml"),
        "link": ("undefined reference", "unresolved external", "linker"),
        "cmake": ("cmake error", "configuration failed", "could not find"),
        "test": ("ctest", "test failed", "assertion failed"),
        "dependency": ("package not found", "missing library", "dependency"),
        "workflow": ("github actions", "actions/", "runner", "workflow"),
        "python": ("traceback", "modulenotfounderror"),
        "compile": ("fatal error", "undeclared", "no member named", "compilation", "error:"),
    }
    for name, keys in rules.items():
        if any(k in t for k in keys): return name
    return "unknown"


def extract_json(text: str) -> dict[str, Any] | None:
    text = text.strip()
    m = re.search(r"```(?:json)?\s*(.*?)\s*```", text, re.S | re.I)
    if m: text = m.group(1).strip()
    try:
        obj = json.loads(text)
        return obj if isinstance(obj, dict) else None
    except json.JSONDecodeError:
        pass
    start = text.find("{")
    if start < 0: return None
    depth = 0; quoted = False; escaped = False
    for i in range(start, len(text)):
        c = text[i]
        if quoted:
            if escaped: escaped = False
            elif c == "\\": escaped = True
            elif c == '"': quoted = False
        elif c == '"': quoted = True
        elif c == "{": depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                try:
                    obj = json.loads(text[start:i+1])
                    return obj if isinstance(obj, dict) else None
                except json.JSONDecodeError:
                    return None
    return None


def repair_prompt(log: str, ctx: str, cat: str, previous: str) -> str:
    return f"""You are VoidOne's principal CI reliability engineer. Diagnose the real root cause of this CI failure and produce the smallest safe patch. Target project: C++23/Qt6 PC gaming platform. Category: {cat}.\n\nHard rules: never modify .github/workflows/ai-repair.yml, scripts/ai_repair.py, scripts/ai_repair_v3.py, or scripts/requirements-ai-repair.txt; never disable tests or security; never add telemetry, credentials, destructive commands, downloads piped to shells, unrelated refactors, or Git operations. Prefer changing the existing implementation rather than broad rewrites. The authoritative CI will validate the candidate on its real platform.\n\nPrevious validation: {previous or 'none'}\n\nReturn ONLY JSON: {{\"status\":\"PATCH\"|\"NO_FIX\",\"diagnosis\":\"...\",\"confidence\":0-100,\"patch\":\"unified git diff\"}}\n\nCI LOG:\n{log}\n\nREPOSITORY CONTEXT:\n{ctx}"""


def call_local(url: str, model: str, prompt: str) -> dict[str, Any] | None:
    try:
        r = requests.post(url.rstrip("/") + "/chat/completions", json={"model": model, "messages":[{"role":"user","content":prompt}], "temperature":0.1}, timeout=REQUEST_TIMEOUT)
        r.raise_for_status()
        return extract_json(r.json()["choices"][0]["message"]["content"])
    except Exception as exc:
        LOG.error("local AI failed: %s", exc)
        return None


def call_gemini(key: str, model: str, prompt: str) -> dict[str, Any] | None:
    endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    try:
        r = requests.post(endpoint, headers={"x-goog-api-key": key}, json={"contents":[{"parts":[{"text":prompt}]}], "generationConfig":{"temperature":0.1,"responseMimeType":"application/json"}}, timeout=REQUEST_TIMEOUT)
        r.raise_for_status()
        return extract_json(r.json()["candidates"][0]["content"]["parts"][0]["text"])
    except Exception as exc:
        LOG.error("Gemini failed: %s", exc)
        return None


def review_prompt(log: str, ctx: str, patch: str, cat: str) -> str:
    return f"""Act as an independent security and correctness reviewer for VoidOne. Review this candidate patch for CI failure category {cat}. Reject protected-file edits, secrets, telemetry, destructive behavior, test disabling, unrelated changes, excessive scope, or a patch that does not plausibly address the failure. Return ONLY JSON: {{\"decision\":\"APPROVE\"|\"REJECT\",\"confidence\":0-100,\"reason\":\"...\"}}\n\nCI LOG:\n{log}\n\nPATCH:\n{patch}\n\nCONTEXT:\n{ctx}"""


def apply(repo: Path, patch: str) -> tuple[bool, str]:
    ok, reason, _ = validate_patch(patch)
    if not ok: return False, reason
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".patch", dir=repo, delete=False) as f:
        f.write(patch); path = Path(f.name)
    try:
        code, _, err = run(["git", "apply", "--check", "--whitespace=error-all", str(path)], repo)
        if code: return False, f"git apply --check failed: {err[-4000:]}"
        code, _, err = run(["git", "apply", "--whitespace=error-all", str(path)], repo)
        if code: return False, f"git apply failed: {err[-4000:]}"
        return True, "ok"
    finally:
        path.unlink(missing_ok=True)


def diff(repo: Path) -> str:
    code, out, err = run(["git", "diff", "--no-ext-diff", "--binary", "HEAD"], repo)
    return out if code == 0 else ""


def write_report(report: Report, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(asdict(report), indent=2, ensure_ascii=False), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", default=".")
    parser.add_argument("--log-file", required=True)
    parser.add_argument("--report-file", default=os.getenv("AI_REPAIR_REPORT_FILE", ""))
    args = parser.parse_args()
    repo = Path(args.repo).resolve(); log_path = Path(args.log_file).resolve()
    if not repo.is_dir() or not log_path.is_file(): return 2
    code, status, _ = run(["git", "status", "--porcelain", "--untracked-files=all"], repo)
    if code or status.strip():
        LOG.error("repository must be clean")
        return 2
    log = log_path.read_text(encoding="utf-8", errors="replace")[-MAX_LOG:]
    cat = category(log); started = time.monotonic(); report = Report(ENGINE_VERSION, cat)
    ctx = context(repo, log)
    local_url = os.getenv("LOCAL_MODEL_URL", "http://127.0.0.1:11434/v1")
    local_model = os.getenv("LOCAL_MODEL_NAME", "qwen2.5-coder:7b")
    gemini_key = os.getenv("GEMINI_API_KEY", "").strip()
    gemini_model = os.getenv("GEMINI_MODEL", "gemini-2.5-pro").strip()
    prompt = repair_prompt(log, ctx, cat, "")
    result = call_gemini(gemini_key, gemini_model, prompt) if gemini_key else None
    if not result: result = call_local(local_url, local_model, prompt)
    if not result or result.get("status") != "PATCH":
        report.reason = "AI did not produce a safe candidate patch"
    else:
        report.diagnosis = str(result.get("diagnosis", "")); report.confidence = float(result.get("confidence", 0) or 0)
        patch = str(result.get("patch", "")); report.patch_hash = hashlib.sha256(patch.encode()).hexdigest(); report.metrics = metrics(patch)
        if report.confidence < int(os.getenv("AI_REPAIR_MIN_CONFIDENCE", "70")):
            report.reason = "repair confidence below threshold"
        else:
            ok, reason = validate_patch(patch)
            if not ok: report.reason = reason
            elif not apply(repo, patch): report.reason = "patch application failed"
            else:
                applied = diff(repo)
                if not applied:
                    report.reason = "candidate produced no git diff"
                else:
                    review = call_local(local_url, local_model, review_prompt(log, ctx, applied, cat))
                    if not review or review.get("decision") != "APPROVE" or float(review.get("confidence", 0) or 0) < int(os.getenv("AI_REPAIR_MIN_REVIEW_CONFIDENCE", "75")):
                        report.reason = "independent local review rejected or unavailable"
                        run(["git", "reset", "--hard", "HEAD"], repo)
                    else:
                        report.review_decision = "APPROVE"; report.review_confidence = float(review.get("confidence", 0)); report.review_reason = str(review.get("reason", "")); report.status = "CANDIDATE_READY"
    report.duration_seconds = time.monotonic() - started
    destination = Path(args.report_file) if args.report_file else repo / ".voidone" / "ai-repair-report.json"
    write_report(report, destination)
    LOG.info("status=%s category=%s confidence=%.1f", report.status, cat, report.confidence)
    return 0 if report.status == "CANDIDATE_READY" else 1

if __name__ == "__main__":
    raise SystemExit(main())
