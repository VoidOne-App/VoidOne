#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import argparse
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
import requests

logging.basicConfig(level=logging.INFO, format="[VOIDONE-AI-ENGINE] %(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger("VoidOneAIRepair")

PROTECTED_PATHS = [".github/", ".git/", "scripts/ai_repair.py", "scripts/requirements-ai-repair.txt"]

class EnvironmentConfig:
    def __init__(self):
        self.gemini_api_key = os.getenv("GEMINI_API_KEY", "").strip()
        self.gemini_model = os.getenv("GEMINI_MODEL", "gemini-3.1-pro-preview").strip()
        self.local_model_url = os.getenv("LOCAL_MODEL_URL", "http://127.0.0.1:11434/v1").rstrip("/")
        self.local_model_name = os.getenv("LOCAL_MODEL_NAME", "qwen2.5-coder:7b").strip()
        self.repo_dir = Path(os.getcwd()).resolve()

def run_command(cmd: List[str], cwd: Optional[Path] = None, timeout: int = 300) -> Tuple[int, str, str]:
    try:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd=str(cwd) if cwd else None)
        stdout, stderr = proc.communicate(timeout=timeout)
        return proc.returncode, stdout, stderr
    except subprocess.TimeoutExpired:
        proc.kill()
        return -1, "", f"Timeout after {timeout} seconds."
    except Exception as e:
        return -1, "", str(e)

def collect_repo_context(repo_dir: Path, log_tail: str) -> str:
    context_parts = []
    for core_file in ["CMakeLists.txt", "README.md"]:
        p = repo_dir / core_file
        if p.exists() and p.is_file():
            try:
                context_parts.append(f"=== File: {core_file} ===\n{p.read_text(encoding='utf-8')[:2000]}")
            except Exception:
                pass

    extensions = {".cpp", ".hpp", ".h", ".cc", ".cxx", ".qml", ".cmake"}
    mentioned_files = set()
    for token in log_tail.split():
        token_clean = token.strip(":'\",()[]")
        if any(token_clean.endswith(ext) for ext in extensions):
            target_path = repo_dir / token_clean
            if target_path.exists() and target_path.is_file():
                mentioned_files.add(token_clean)

    for rel_path in sorted(mentioned_files):
        p = repo_dir / rel_path
        try:
            content = p.read_text(encoding='utf-8')
            if len(content) > 6000:
                content = content[:6000] + "\n... [TRUNCATED] ..."
            context_parts.append(f"=== Source File: {rel_path} ===\n{content}")
        except Exception as e:
            logger.warning(f"Could not read {rel_path}: {e}")

    return "\n\n".join(context_parts)

class AIInferenceClient:
    def __init__(self, config: EnvironmentConfig):
        self.cfg = config

    def query_gemini_lead(self, failure_log: str, repo_context: str) -> Optional[Dict[str, Any]]:
        if not self.cfg.gemini_api_key:
            logger.error("GEMINI_API_KEY is missing!")
            return None

        endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{self.cfg.gemini_model}:generateContent?key={self.cfg.gemini_api_key}"
        prompt = f"""You are Lead C++/Qt Engineer for VoidOne.
Analyze CI log and fix the root cause with a minimal unified diff patch.

STRICT CONSTRAINTS:
1. Do NOT modify files under .github/ or scripts/.
2. Respond strictly with JSON:
{{
  "status": "PATCH",
  "diagnosis": "explanation",
  "patch": "UNIFIED_DIFF_PATCH_TEXT"
}}

LOG:
{failure_log}

CONTEXT:
{repo_context}
"""
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"responseMimeType": "application/json"}
        }
        try:
            res = requests.post(endpoint, json=payload, timeout=90)
            if res.status_code == 200:
                return json.loads(res.json()["candidates"][0]["content"]["parts"][0]["text"])
        except Exception as e:
            logger.error(f"Gemini API Error: {e}")
        return None

def apply_patch_safely(repo_dir: Path, patch_text: str) -> bool:
    if not patch_text or not patch_text.strip():
        return False
    for path in PROTECTED_PATHS:
        if path in patch_text:
            return False

    patch_file = repo_dir / "candidate.patch"
    patch_file.write_text(patch_text, encoding="utf-8")
    code, _, _ = run_command(["git", "apply", "--check", "candidate.patch"], cwd=repo_dir)
    if code == 0:
        code, _, _ = run_command(["git", "apply", "candidate.patch"], cwd=repo_dir)
    patch_file.unlink(missing_ok=True)
    return code == 0

def validate_build(repo_dir: Path) -> bool:
    code, _, _ = run_command(["cmake", "-S", ".", "-B", "build", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release"], cwd=repo_dir)
    if code != 0:
        return False
    code, _, _ = run_command(["cmake", "--build", "build", "--parallel"], cwd=repo_dir)
    return code == 0

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--log-file", required=True)
    args = parser.parse_args()

    cfg = EnvironmentConfig()
    log_path = Path(args.log_file)
    log_tail = log_path.read_text(encoding="utf-8", errors="ignore")[-8000:] if log_path.exists() else ""

    repo_context = collect_repo_context(cfg.repo_dir, log_tail)
    client = AIInferenceClient(cfg)
    gemini_plan = client.query_gemini_lead(log_tail, repo_context)

    if not gemini_plan or gemini_plan.get("status") != "PATCH":
        sys.exit(1)

    if not apply_patch_safely(cfg.repo_dir, gemini_plan["patch"]):
        sys.exit(1)

    if not validate_build(cfg.repo_dir):
        run_command(["git", "checkout", "."], cwd=cfg.repo_dir)
        sys.exit(1)

    logger.info("Successfully repaired and validated!")
    sys.exit(0)

if __name__ == "__main__":
    main()
