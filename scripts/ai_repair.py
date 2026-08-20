#!/usr/bin/env python3
import os
import sys
import re
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
        self.gemini_model = os.getenv("GEMINI_MODEL", "gemini-2.5-pro").strip()
        self.local_model_url = os.getenv("LOCAL_MODEL_URL", "http://127.0.0.1:11434/v1").rstrip("/")
        self.local_model_name = os.getenv("LOCAL_MODEL_NAME", "qwen2.5-coder:1.5b").strip()
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

def parse_json_safely(raw_text: str) -> Optional[Dict[str, Any]]:
    """پاک‌سازی رشته‌های JSON محصور شده در بلاک‌های Markdown."""
    cleaned = raw_text.strip()
    if "```json" in cleaned:
        cleaned = cleaned.split("```json")[1].split("```")[0].strip()
    elif "```" in cleaned:
        cleaned = cleaned.split("```")[1].split("```")[0].strip()
    
    try:
        return json.loads(cleaned)
    except json.JSONDecodeError as e:
        logger.error(f"Failed to parse JSON response: {e}")
        return None

class AIInferenceClient:
    def __init__(self, config: EnvironmentConfig):
        self.cfg = config

    def query_gemini_lead(self, failure_log: str, repo_context: str) -> Optional[Dict[str, Any]]:
        if not self.cfg.gemini_api_key:
            logger.warning("GEMINI_API_KEY is missing! Fallback to local model.")
            return self.query_local_coder(failure_log, repo_context)

        endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{self.cfg.gemini_model}:generateContent?key={self.cfg.gemini_api_key}"
        prompt = f"""You are Lead C++/Qt Engineer for VoidOne.
Analyze CI log and fix the root cause with a minimal unified diff patch.

STRICT CONSTRAINTS:
1. Do NOT modify files under .github/ or scripts/.
2. Respond strictly with JSON in this exact schema:
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
                raw_json = res.json()["candidates"][0]["content"]["parts"][0]["text"]
                return parse_json_safely(raw_json)
            else:
                logger.error(f"Gemini API returned status code {res.status_code}: {res.text}")
        except Exception as e:
            logger.error(f"Gemini API Error: {e}")

        logger.info("Fallback to local Ollama Qwen model...")
        return self.query_local_coder(failure_log, repo_context)

    def query_local_coder(self, failure_log: str, repo_context: str) -> Optional[Dict[str, Any]]:
        """اجرای پشتیبان در صورت قطع شدن یا عدم دسترسی به Gemini API."""
        endpoint = f"{self.cfg.local_model_url}/chat/completions"
        prompt = f"""You are C++/Qt AI Repair Engine. Analyze failure and produce unified diff patch.
Respond ONLY with JSON:
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
            "model": self.cfg.local_model_name,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.2
        }
        try:
            res = requests.post(endpoint, json=payload, timeout=120)
            if res.status_code == 200:
                content = res.json()["choices"][0]["message"]["content"]
                return parse_json_safely(content)
        except Exception as e:
            logger.error(f"Local Model (Ollama) Error: {e}")
        return None

def apply_patch_safely(repo_dir: Path, patch_text: str) -> bool:
    if not patch_text or not patch_text.strip():
        logger.error("Received empty patch.")
        return False

    # بررسی خطوط فایل‌های هدف در Diff برای جلوگیری از تغییر فایل‌های حیاتی
    diff_target_files = re.findall(r"--- a/(.*)\n\+\+\+ b/(.*)", patch_text)
    for orig_file, new_file in diff_target_files:
        for protected in PROTECTED_PATHS:
            if orig_file.startswith(protected) or new_file.startswith(protected):
                logger.error(f"Patch attempts to modify protected path: {protected}")
                return False

    patch_file = repo_dir / "candidate.patch"
    patch_file.write_text(patch_text, encoding="utf-8")
    
    code, out, err = run_command(["git", "apply", "--check", "candidate.patch"], cwd=repo_dir)
    if code == 0:
        code, out, err = run_command(["git", "apply", "candidate.patch"], cwd=repo_dir)
        logger.info("Patch applied successfully via git apply!")
    else:
        logger.error(f"Git apply check failed: {err}")

    patch_file.unlink(missing_ok=True)
    return code == 0

def validate_build(repo_dir: Path) -> bool:
    logger.info("Validating patch with CMake build test...")
    code, _, err = run_command(["cmake", "-S", ".", "-B", "build", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release"], cwd=repo_dir)
    if code != 0:
        logger.error(f"CMake configuration failed: {err}")
        return False
    code, _, err = run_command(["cmake", "--build", "build", "--parallel"], cwd=repo_dir)
    if code != 0:
        logger.error(f"CMake compilation failed: {err}")
        return False
    return True

def main():
    parser = argparse.ArgumentParser(description="VoidOne Autonomous AI CI Repair Engine")
    parser.add_argument("--log-file", required=True, help="Path to CI failure log file")
    args = parser.parse_args()

    cfg = EnvironmentConfig()
    log_path = Path(args.log_file)
    log_tail = log_path.read_text(encoding="utf-8", errors="ignore")[-8000:] if log_path.exists() else ""

    if not log_tail:
        logger.error("CI Failure log is empty or missing.")
        sys.exit(1)

    repo_context = collect_repo_context(cfg.repo_dir, log_tail)
    client = AIInferenceClient(cfg)
    gemini_plan = client.query_gemini_lead(log_tail, repo_context)

    if not gemini_plan or gemini_plan.get("status") != "PATCH":
        logger.error("AI engine could not generate a valid fix plan.")
        sys.exit(1)

    logger.info(f"AI Diagnosis: {gemini_plan.get('diagnosis')}")

    if not apply_patch_safely(cfg.cfg.repo_dir if hasattr(cfg, 'cfg') else cfg.repo_dir, gemini_plan.get("patch", "")):
        logger.error("Failed to apply generated patch safely.")
        sys.exit(1)

    if not validate_build(cfg.repo_dir):
        logger.warning("Build validation failed after patch. Rolling back changes...")
        run_command(["git", "checkout", "."], cwd=cfg.repo_dir)
        sys.exit(1)

    logger.info("Successfully repaired, validated, and verified build!")
    sys.exit(0)

if __name__ == "__main__":
    main()
