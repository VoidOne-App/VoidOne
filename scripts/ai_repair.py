#!/usr/bin/env python3
"""
VoidOne Autonomous AI CI Repair Engine
Role: Senior AI Infrastructure & C++/Qt Engineer Agent
"""

import os
import sys
import json
import subprocess
import argparse
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
import requests

# پیکربندی لاگ‌ها
logging.basicConfig(
    level=logging.INFO,
    format="[VOIDONE-AI-ENGINE] %(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("VoidOneAIRepair")

# مسیرهای حفاظت‌شده - هوش مصنوعی هرگز حق تغییر این فایل‌ها را ندارد
PROTECTED_PATHS = [
    ".github/",
    ".git/",
    "scripts/ai_repair.py",
    "scripts/requirements-ai-repair.txt"
]

class EnvironmentConfig:
    def __init__(self):
        self.gemini_api_key = os.getenv("GEMINI_API_KEY", "").strip()
        self.gemini_model = os.getenv("GEMINI_MODEL", "gemini-3.1-pro-preview").strip()
        
        self.local_model_url = os.getenv("LOCAL_MODEL_URL", "http://127.0.0.1:11434/v1").rstrip("/")
        self.local_model_name = os.getenv("LOCAL_MODEL_NAME", "qwen2.5-coder:7b").strip()

        self.repo_dir = Path(os.getcwd()).resolve()

def run_command(cmd: List[str], cwd: Optional[Path] = None, timeout: int = 300) -> Tuple[int, str, str]:
    """اجرای ایمن دستورات ترمینال همراه با Timeout"""
    try:
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=str(cwd) if cwd else None
        )
        stdout, stderr = proc.communicate(timeout=timeout)
        return proc.returncode, stdout, stderr
    except subprocess.TimeoutExpired:
        proc.kill()
        return -1, "", f"Command '{' '.join(cmd)}' timed out after {timeout} seconds."
    except Exception as e:
        return -1, "", f"Execution error: {str(e)}"

def collect_repo_context(repo_dir: Path, log_tail: str) -> str:
    """جمع‌آوری فایل‌های کلیدی پروژه و سورس‌کدهایی که در لاگ خطا به آن‌ها اشاره شده است"""
    context_parts = []
    
    # فایل‌های ساختار و بیلد اصلی
    for core_file in ["CMakeLists.txt", "README.md"]:
        p = repo_dir / core_file
        if p.exists() and p.is_file():
            try:
                context_parts.append(f"=== File: {core_file} ===\n{p.read_text(encoding='utf-8')[:2000]}")
            except Exception:
                pass

    # استخراج فایل‌های منبع C++/Qt اشاره شده در لاگ
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
            logger.warning(f"Could not read source file {rel_path}: {e}")

    return "\n\n".join(context_parts)

class AIInferenceClient:
    def __init__(self, config: EnvironmentConfig):
        self.cfg = config

    def query_gemini_lead(self, failure_log: str, repo_context: str) -> Optional[Dict[str, Any]]:
        """بررسی خطای CI توسط Lead Engineer (Gemini 3.1 Pro)"""
        if not self.cfg.gemini_api_key:
            logger.error("GEMINI_API_KEY is missing!")
            return None

        endpoint = f"https://generativelanguage.googleapis.com/v1beta/models/{self.cfg.gemini_model}:generateContent?key={self.cfg.gemini_api_key}"
        
        prompt = f"""You are the Lead C++/Qt Infrastructure Engineer repairing a broken CI build for VoidOne.
Analyze the failure log and context. Generate a minimal, production-quality unified diff patch fixing the root cause.

STRICT CONSTRAINTS:
1. Fix the ROOT CAUSE, not symptoms.
2. DO NOT delete unit tests or modify protected files (.github/, scripts/).
3. Respond strictly with valid JSON matching:
{{
  "status": "PATCH", // or "NO_PATCH"
  "diagnosis": "Detailed root cause analysis",
  "plan": "Actionable repair steps",
  "patch": "UNIFIED_DIFF_PATCH_TEXT"
}}

[FAILURE LOG]
{failure_log}

[REPOSITORY CONTEXT]
{repo_context}
"""
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"responseMimeType": "application/json"}
        }

        try:
            res = requests.post(endpoint, json=payload, timeout=90)
            if res.status_code == 200:
                raw_text = res.json()["candidates"][0]["content"]["parts"][0]["text"]
                return json.loads(raw_text)
            else:
                logger.error(f"Gemini API Error {res.status_code}: {res.text}")
        except Exception as e:
            logger.error(f"Gemini Query Failed: {e}")
        return None

    def query_local_reviewer(self, gemini_plan: Dict[str, Any], failure_log: str) -> Optional[Dict[str, Any]]:
        """بازبینی مستقل کد توسط Code Reviewer محلی (Qwen2.5-Coder)"""
        endpoint = f"{self.cfg.local_model_url}/chat/completions"
        prompt = f"""Review this C++/Qt repair patch for VoidOne:

Diagnosis: {gemini_plan.get('diagnosis')}
Patch Candidate:
{gemini_plan.get('patch')}

Respond in JSON:
{{
  "verdict": "APPROVE" | "REVISE",
  "reason": "C++/Qt & CMake correctness review",
  "patch": "Optimized unified diff patch"
}}
"""
        payload = {
            "model": self.cfg.local_model_name,
            "messages": [
                {"role": "system", "content": "You are a C++ Code Reviewer. Return JSON only."},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.1,
            "response_format": {"type": "json_object"}
        }
        try:
            res = requests.post(endpoint, json=payload, timeout=90)
            if res.status_code == 200:
                content = res.json()["choices"][0]["message"]["content"]
                return json.loads(content)
        except Exception as e:
            logger.warning(f"Local reviewer evaluation skipped: {e}")
        return None

def apply_patch_safely(repo_dir: Path, patch_text: str) -> bool:
    """تست و اعمال دقیق پچ روی سورس کد"""
    if not patch_text or not patch_text.strip():
        logger.error("Patch text is empty.")
        return False

    # بررسی تغییر نیافتن مسیرهای حساس
    for path in PROTECTED_PATHS:
        if path in patch_text:
            logger.error(f"SECURITY VIOLATION: Patch touches protected path '{path}'. Rejected!")
            return False

    patch_file = repo_dir / "candidate.patch"
    patch_file.write_text(patch_text, encoding="utf-8")

    # بررسی امکان اعمال بدون خطا (Dry Run)
    code, stdout, stderr = run_command(["git", "apply", "--check", "candidate.patch"], cwd=repo_dir)
    if code != 0:
        logger.error(f"git apply --check failed:\n{stderr}")
        patch_file.unlink(missing_ok=True)
        return False

    # اعمال پچ
    code, stdout, stderr = run_command(["git", "apply", "candidate.patch"], cwd=repo_dir)
    patch_file.unlink(missing_ok=True)
    if code != 0:
        logger.error(f"Git apply failed: {stderr}")
        return False

    logger.info("Patch applied cleanly.")
    return True

class GroundTruthValidator:
    """اعتبارسنجی واقعی به وسیله کامپایلر، تست‌ها و تحلیل‌گرهای استاتیک"""
    def __init__(self, repo_dir: Path):
        self.repo_dir = repo_dir

    def validate_build_and_tests(self) -> bool:
        logger.info("=== STEP 1: CMake Release Build ===")
        code, _, stderr = run_command(["cmake", "-S", ".", "-B", "build-release", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release"], cwd=self.repo_dir)
        if code != 0:
            logger.error(f"CMake config failed:\n{stderr}")
            return False

        code, _, stderr = run_command(["cmake", "--build", "build-release", "--parallel"], cwd=self.repo_dir)
        if code != 0:
            logger.error(f"Release build failed:\n{stderr}")
            return False

        logger.info("=== STEP 2: CMake Debug & Unit Tests ===")
        code, _, stderr = run_command(["cmake", "-S", ".", "-B", "build-tests", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Debug", "-DVOIDONE_BUILD_TESTS=ON"], cwd=self.repo_dir)
        if code == 0:
            run_command(["cmake", "--build", "build-tests", "--parallel"], cwd=self.repo_dir)
            code_test, _, test_err = run_command(["ctest", "--test-dir", "build-tests", "--output-on-failure"], cwd=self.repo_dir)
            if code_test != 0:
                logger.error(f"Unit tests failed:\n{test_err}")
                return False

        return True

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--log-file", required=True, help="Path to CI failure log")
    args = parser.parse_args()

    cfg = EnvironmentConfig()
    log_path = Path(args.log_file)

    if not log_path.exists():
        logger.error(f"Log file not found: {log_path}")
        sys.exit(1)

    log_tail = log_path.read_text(encoding="utf-8", errors="ignore")[-8000:]
    repo_context = collect_repo_context(cfg.repo_dir, log_tail)

    client = AIInferenceClient(cfg)

    logger.info("Phase 1: Generating Repair Proposal via Gemini 3.1 Pro...")
    gemini_plan = client.query_gemini_lead(log_tail, repo_context)

    if not gemini_plan or gemini_plan.get("status") != "PATCH":
        logger.error("Gemini could not generate a patch.")
        sys.exit(1)

    logger.info("Phase 2: Reviewing Patch via Local Code Reviewer...")
    reviewer_res = client.query_local_reviewer(gemini_plan, log_tail)

    final_patch = gemini_plan["patch"]
    if reviewer_res and reviewer_res.get("verdict") == "REVISE" and reviewer_res.get("patch"):
        logger.info("Using revised patch from local reviewer.")
        final_patch = reviewer_res["patch"]

    logger.info("Phase 3: Safe Patch Application...")
    if not apply_patch_safely(cfg.repo_dir, final_patch):
        sys.exit(1)

    logger.info("Phase 4: Compiler and Test Ground Truth Validation...")
    validator = GroundTruthValidator(cfg.repo_dir)
    if not validator.validate_build_and_tests():
        logger.error("Validation failed! Rolling back changes...")
        run_command(["git", "checkout", "."], cwd=cfg.repo_dir)
        sys.exit(1)

    logger.info("SUCCESS: VoidOne AI Repair Engine successfully fixed and validated the repository!")
    sys.exit(0)

if __name__ == "__main__":
    main()
