#!/usr/bin/env python3

"""
VoidOne Autonomous AI CI Repair Engine

Architecture:

    CI Failure
        ↓
    Log Collection
        ↓
    Repository Context
        ↓
    Gemini Lead Engineer
        ↓
    Local Qwen Coder Fallback
        ↓
    Patch Validation
        ↓
    Safe Patch Application
        ↓
    CMake Configure
        ↓
    Build
        ↓
    Tests
        ↓
    Success / Safe Rollback

Design goals:
- No third-party Python dependency required.
- Gemini as primary reasoning model.
- Local OpenAI-compatible Qwen model as fallback.
- Strict protected paths.
- Safe patch application.
- No destructive "git checkout ." rollback.
- JSON-only model contract.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple
from urllib import error as urllib_error
from urllib import request as urllib_request


# ============================================================================
# Logging
# ============================================================================

logging.basicConfig(
    level=logging.INFO,
    format="[VOIDONE-AI-ENGINE] %(asctime)s - %(levelname)s - %(message)s",
)

logger = logging.getLogger("VoidOneAIRepair")


# ============================================================================
# Security Policy
# ============================================================================

PROTECTED_PATHS = (
    ".git/",
    ".github/",
    "scripts/ai_repair.py",
    "scripts/requirements-ai-repair.txt",
)

MAX_LOG_SIZE = 12000
MAX_CONTEXT_FILE_SIZE = 8000
MAX_TOTAL_CONTEXT_SIZE = 40000

SOURCE_EXTENSIONS = {
    ".cpp",
    ".hpp",
    ".h",
    ".cc",
    ".cxx",
    ".qml",
    ".cmake",
}

TEST_COMMAND = ["ctest", "--test-dir", "build", "--output-on-failure"]


# ============================================================================
# Environment Configuration
# ============================================================================

class EnvironmentConfig:
    def __init__(self) -> None:
        # ------------------------------------------------------------------
        # Gemini
        # ------------------------------------------------------------------
        self.gemini_api_key = os.getenv("GEMINI_API_KEY", "").strip()

        self.gemini_model = os.getenv(
            "GEMINI_MODEL",
            "gemini-2.5-pro",
        ).strip()

        # ------------------------------------------------------------------
        # Local OpenAI-compatible endpoint
        #
        # Default assumes Ollama.
        # ------------------------------------------------------------------
        self.local_model_url = os.getenv(
            "LOCAL_MODEL_URL",
            "http://127.0.0.1:11434/v1",
        ).strip().rstrip("/")

        # Qwen3-Coder-Next can be supplied here.
        #
        # Example:
        # QWEN3-CODER-NEXT
        # qwen3-coder-next
        # or the exact local runtime model identifier.
        self.local_model_name = os.getenv(
            "LOCAL_MODEL_NAME",
            "qwen3-coder-next",
        ).strip()

        # ------------------------------------------------------------------
        # Build configuration
        # ------------------------------------------------------------------
        self.build_dir = os.getenv(
            "VOIDONE_BUILD_DIR",
            "build",
        ).strip()

        self.cmake_generator = os.getenv(
            "CMAKE_GENERATOR",
            "Ninja",
        ).strip()

        self.build_type = os.getenv(
            "CMAKE_BUILD_TYPE",
            "Release",
        ).strip()

        self.run_tests = os.getenv(
            "VOIDONE_AI_RUN_TESTS",
            "true",
        ).strip().lower() not in {
            "0",
            "false",
            "no",
            "off",
        }

        self.repo_dir = Path(
            os.getenv(
                "GITHUB_WORKSPACE",
                os.getcwd(),
            )
        ).resolve()


# ============================================================================
# Command Execution
# ============================================================================

def run_command(
    cmd: List[str],
    cwd: Optional[Path] = None,
    timeout: int = 300,
) -> Tuple[int, str, str]:

    logger.debug("Running command: %s", " ".join(cmd))

    try:
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            cwd=str(cwd) if cwd else None,
        )

        stdout, stderr = process.communicate(timeout=timeout)

        return process.returncode, stdout, stderr

    except subprocess.TimeoutExpired:
        process.kill()

        stdout, stderr = process.communicate()

        return (
            -1,
            stdout,
            f"Timeout after {timeout} seconds.\n{stderr}",
        )

    except Exception as exc:
        return -1, "", str(exc)


# ============================================================================
# HTTP JSON
# ============================================================================

def http_json_post(
    url: str,
    payload: Dict[str, Any],
    headers: Optional[Dict[str, str]] = None,
    timeout: int = 120,
) -> Tuple[int, str]:

    body = json.dumps(payload).encode("utf-8")

    request_headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "VoidOne-AI-Repair/1.0",
    }

    if headers:
        request_headers.update(headers)

    req = urllib_request.Request(
        url,
        data=body,
        headers=request_headers,
        method="POST",
    )

    try:
        with urllib_request.urlopen(req, timeout=timeout) as response:
            status = response.status
            response_body = response.read().decode(
                "utf-8",
                errors="replace",
            )

            return status, response_body

    except urllib_error.HTTPError as exc:
        response_body = exc.read().decode(
            "utf-8",
            errors="replace",
        )

        return exc.code, response_body

    except urllib_error.URLError as exc:
        return -1, f"Network error: {exc}"

    except Exception as exc:
        return -1, str(exc)


# ============================================================================
# JSON Parsing
# ============================================================================

def extract_json_object(text: str) -> Optional[str]:
    """
    Extract the first balanced JSON object from model output.

    Handles:
    - raw JSON
    - ```json ... ```
    - surrounding explanation
    """

    if not text:
        return None

    cleaned = text.strip()

    # Markdown fenced block.
    fenced = re.search(
        r"```(?:json)?\s*(\{.*?\})\s*```",
        cleaned,
        flags=re.DOTALL | re.IGNORECASE,
    )

    if fenced:
        return fenced.group(1).strip()

    # Direct JSON.
    if cleaned.startswith("{") and cleaned.endswith("}"):
        return cleaned

    # Search for first balanced object.
    start = cleaned.find("{")

    if start == -1:
        return None

    depth = 0
    in_string = False
    escaped = False

    for index in range(start, len(cleaned)):

        char = cleaned[index]

        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False

            continue

        if char == '"':
            in_string = True

        elif char == "{":
            depth += 1

        elif char == "}":
            depth -= 1

            if depth == 0:
                return cleaned[start:index + 1]

    return None


def parse_json_safely(
    raw_text: str,
) -> Optional[Dict[str, Any]]:

    json_text = extract_json_object(raw_text)

    if not json_text:
        logger.error("AI response did not contain a JSON object.")
        return None

    try:
        result = json.loads(json_text)

    except json.JSONDecodeError as exc:
        logger.error(
            "Failed to parse AI JSON response: %s",
            exc,
        )
        return None

    if not isinstance(result, dict):
        logger.error("AI response JSON root is not an object.")
        return None

    return result


# ============================================================================
# Path Security
# ============================================================================

def normalize_repo_path(path: str) -> str:
    return path.replace("\\", "/").lstrip("./")


def is_protected_path(path: str) -> bool:

    normalized = normalize_repo_path(path)

    for protected in PROTECTED_PATHS:
        protected_normalized = protected.replace("\\", "/")

        if (
            normalized == protected_normalized.rstrip("/")
            or normalized.startswith(protected_normalized)
        ):
            return True

    return False


# ============================================================================
# Repository Context
# ============================================================================

def read_text_file(
    path: Path,
    max_size: int = MAX_CONTEXT_FILE_SIZE,
) -> str:

    try:
        content = path.read_text(
            encoding="utf-8",
            errors="replace",
        )

    except Exception as exc:
        logger.warning(
            "Unable to read %s: %s",
            path,
            exc,
        )

        return ""

    if len(content) > max_size:
        content = (
            content[:max_size]
            + "\n... [TRUNCATED] ..."
        )

    return content


def collect_repo_context(
    repo_dir: Path,
    log_tail: str,
) -> str:

    context_parts: List[str] = []

    # ------------------------------------------------------------------
    # Core project files
    # ------------------------------------------------------------------

    core_files = [
        "CMakeLists.txt",
        "README.md",
        "CMakePresets.json",
    ]

    for relative in core_files:

        path = repo_dir / relative

        if path.exists() and path.is_file():

            content = read_text_file(path)

            if content:
                context_parts.append(
                    f"=== File: {relative} ===\n{content}"
                )

    # ------------------------------------------------------------------
    # Detect source files mentioned by CI log
    # ------------------------------------------------------------------

    mentioned_files = set()

    for token in re.split(r"\s+", log_tail):

        token_clean = token.strip(
            "'\",()[]{}<>:"
        )

        if "/" not in token_clean and "\\" not in token_clean:
            continue

        suffix = Path(token_clean).suffix.lower()

        if suffix not in SOURCE_EXTENSIONS:
            continue

        candidate = repo_dir / token_clean

        if (
            candidate.exists()
            and candidate.is_file()
        ):
            try:
                relative = candidate.relative_to(repo_dir)
                mentioned_files.add(
                    relative.as_posix()
                )
            except ValueError:
                continue

    # ------------------------------------------------------------------
    # Read referenced source files
    # ------------------------------------------------------------------

    for relative in sorted(mentioned_files):

        path = repo_dir / relative

        content = read_text_file(
            path,
            MAX_CONTEXT_FILE_SIZE,
        )

        if content:
            context_parts.append(
                f"=== Source File: {relative} ===\n{content}"
            )

    context = "\n\n".join(context_parts)

    if len(context) > MAX_TOTAL_CONTEXT_SIZE:
        context = (
            context[:MAX_TOTAL_CONTEXT_SIZE]
            + "\n... [TOTAL CONTEXT TRUNCATED] ..."
        )

    return context


# ============================================================================
# AI Prompt
# ============================================================================

def build_repair_prompt(
    failure_log: str,
    repo_context: str,
) -> str:

    return f"""
You are the Lead C++23 / Qt6 / CMake engineer for the VoidOne project.

Your task is to diagnose a CI/build failure and propose the smallest safe
source-code change required to fix the ROOT CAUSE.

IMPORTANT SECURITY RULES:

1. NEVER modify:
   - .git/
   - .github/
   - scripts/
   - scripts/ai_repair.py
   - scripts/requirements-ai-repair.txt

2. Do not modify CI configuration.

3. Do not modify workflow files.

4. Do not disable tests.

5. Do not weaken compiler warnings.

6. Do not remove security checks.

7. Do not introduce secrets, credentials, tokens, or telemetry.

8. Prefer minimal, maintainable fixes.

9. Do not rewrite unrelated code.

10. If the failure cannot be safely fixed from source code, return:
    {{
      "status": "NO_FIX",
      "diagnosis": "reason",
      "patch": ""
    }}

11. If a safe source-code fix exists, return:
    {{
      "status": "PATCH",
      "diagnosis": "short technical explanation",
      "patch": "UNIFIED_DIFF_PATCH"
    }}

The patch MUST be a valid git unified diff.

Return ONLY JSON.

========================
CI FAILURE LOG
========================

{failure_log}

========================
REPOSITORY CONTEXT
========================

{repo_context}
""".strip()


# ============================================================================
# AI Client
# ============================================================================

class AIInferenceClient:

    def __init__(
        self,
        config: EnvironmentConfig,
    ) -> None:

        self.cfg = config

    # ------------------------------------------------------------------
    # Gemini
    # ------------------------------------------------------------------

    def query_gemini(
        self,
        failure_log: str,
        repo_context: str,
    ) -> Optional[Dict[str, Any]]:

        if not self.cfg.gemini_api_key:
            logger.warning(
                "GEMINI_API_KEY is missing."
            )

            return None

        endpoint = (
            "https://generativelanguage.googleapis.com/"
            "v1beta/models/"
            f"{self.cfg.gemini_model}:generateContent"
            f"?key={self.cfg.gemini_api_key}"
        )

        prompt = build_repair_prompt(
            failure_log,
            repo_context,
        )

        payload = {
            "contents": [
                {
                    "parts": [
                        {
                            "text": prompt,
                        }
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.1,
                "responseMimeType": "application/json",
            },
        }

        logger.info(
            "Querying Gemini lead engineer: %s",
            self.cfg.gemini_model,
        )

        status, response_text = http_json_post(
            endpoint,
            payload,
            timeout=120,
        )

        if status != 200:

            logger.error(
                "Gemini API failed: HTTP %s",
                status,
            )

            logger.debug(
                "Gemini response: %s",
                response_text[:2000],
            )

            return None

        try:

            response = json.loads(
                response_text
            )

            candidates = response.get(
                "candidates",
                [],
            )

            if not candidates:
                logger.error(
                    "Gemini returned no candidates."
                )

                return None

            content = candidates[0].get(
                "content",
                {},
            )

            parts = content.get(
                "parts",
                [],
            )

            if not parts:
                logger.error(
                    "Gemini returned no content parts."
                )

                return None

            raw_text = parts[0].get(
                "text",
                "",
            )

            return parse_json_safely(
                raw_text
            )

        except Exception as exc:

            logger.error(
                "Failed to parse Gemini response: %s",
                exc,
            )

            return None

    # ------------------------------------------------------------------
    # Local Qwen
    # ------------------------------------------------------------------

    def query_local_qwen(
        self,
        failure_log: str,
        repo_context: str,
    ) -> Optional[Dict[str, Any]]:

        endpoint = (
            f"{self.cfg.local_model_url}"
            "/chat/completions"
        )

        prompt = build_repair_prompt(
            failure_log,
            repo_context,
        )

        payload = {
            "model": self.cfg.local_model_name,
            "messages": [
                {
                    "role": "system",
                    "content": (
                        "You are a senior C++23, Qt6 and "
                        "CMake repair engineer. "
                        "Follow the JSON contract exactly."
                    ),
                },
                {
                    "role": "user",
                    "content": prompt,
                },
            ],
            "temperature": 0.1,
        }

        logger.info(
            "Querying local Qwen model: %s",
            self.cfg.local_model_name,
        )

        status, response_text = http_json_post(
            endpoint,
            payload,
            timeout=180,
        )

        if status != 200:

            logger.error(
                "Local model request failed: HTTP %s",
                status,
            )

            logger.debug(
                "Local model response: %s",
                response_text[:2000],
            )

            return None

        try:

            response = json.loads(
                response_text
            )

            choices = response.get(
                "choices",
                [],
            )

            if not choices:
                logger.error(
                    "Local model returned no choices."
                )

                return None

            message = choices[0].get(
                "message",
                {},
            )

            raw_text = message.get(
                "content",
                "",
            )

            return parse_json_safely(
                raw_text
            )

        except Exception as exc:

            logger.error(
                "Failed to parse local model response: %s",
                exc,
            )

            return None

    # ------------------------------------------------------------------
    # Unified inference
    # ------------------------------------------------------------------

    def repair(
        self,
        failure_log: str,
        repo_context: str,
    ) -> Optional[Dict[str, Any]]:

        # Gemini first.
        result = self.query_gemini(
            failure_log,
            repo_context,
        )

        if result:
            logger.info(
                "Gemini produced a repair plan."
            )

            return result

        # Qwen fallback.
        logger.info(
            "Falling back to local Qwen."
        )

        result = self.query_local_qwen(
            failure_log,
            repo_context,
        )

        if result:
            logger.info(
                "Local Qwen produced a repair plan."
            )

        return result


# ============================================================================
# Patch Validation
# ============================================================================

def validate_patch(
    patch_text: str,
) -> bool:

    if not patch_text.strip():
        logger.error(
            "AI returned an empty patch."
        )

        return False

    if "diff --git " not in patch_text:
        logger.error(
            "Patch does not contain a git diff header."
        )

        return False

    # --------------------------------------------------------------
    # Extract affected files.
    # --------------------------------------------------------------

    diff_files = re.findall(
        r"^diff --git a/(.+?) b/(.+?)$",
        patch_text,
        flags=re.MULTILINE,
    )

    if not diff_files:
        logger.error(
            "Could not identify files affected by patch."
        )

        return False

    for original, modified in diff_files:

        original = normalize_repo_path(original)
        modified = normalize_repo_path(modified)

        logger.info(
            "Patch target: %s -> %s",
            original,
            modified,
        )

        if is_protected_path(original):
            logger.error(
                "Protected path detected: %s",
                original,
            )

            return False

        if is_protected_path(modified):
            logger.error(
                "Protected path detected: %s",
                modified,
            )

            return False

        # Prevent obvious path traversal.
        if ".." in Path(original).parts:
            logger.error(
                "Path traversal detected: %s",
                original,
            )

            return False

        if ".." in Path(modified).parts:
            logger.error(
                "Path traversal detected: %s",
                modified,
            )

            return False

    return True


# ============================================================================
# Safe Patch Application
# ============================================================================

def apply_patch_safely(
    repo_dir: Path,
    patch_text: str,
) -> Optional[str]:

    if not validate_patch(patch_text):
        return None

    patch_file: Optional[Path] = None

    try:

        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            suffix=".patch",
            prefix="voidone-ai-",
            delete=False,
        ) as temp:

            temp.write(patch_text)
            patch_file = Path(temp.name)

        # --------------------------------------------------------------
        # First: dry-run validation.
        # --------------------------------------------------------------

        code, _, stderr = run_command(
            [
                "git",
                "apply",
                "--check",
                str(patch_file),
            ],
            cwd=repo_dir,
        )

        if code != 0:

            logger.error(
                "git apply --check failed:\n%s",
                stderr,
            )

            return None

        # --------------------------------------------------------------
        # Apply.
        # --------------------------------------------------------------

        code, _, stderr = run_command(
            [
                "git",
                "apply",
                "--index",
                str(patch_file),
            ],
            cwd=repo_dir,
        )

        if code != 0:

            logger.error(
                "Failed to apply AI patch:\n%s",
                stderr,
            )

            return None

        logger.info(
            "AI patch applied successfully."
        )

        return str(patch_file)

    except Exception as exc:

        logger.error(
            "Patch application error: %s",
            exc,
        )

        return None

    finally:

        if patch_file and patch_file.exists():

            try:
                patch_file.unlink()

            except Exception:
                pass


# ============================================================================
# Patch Rollback
# ============================================================================

def rollback_patch(
    repo_dir: Path,
    patch_text: str,
) -> bool:

    if not patch_text.strip():
        return True

    try:

        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            suffix=".patch",
            prefix="voidone-ai-rollback-",
            delete=False,
        ) as temp:

            temp.write(patch_text)
            patch_file = Path(temp.name)

        try:

            code, _, stderr = run_command(
                [
                    "git",
                    "apply",
                    "--reverse",
                    "--index",
                    str(patch_file),
                ],
                cwd=repo_dir,
            )

            if code != 0:

                logger.error(
                    "Patch rollback failed:\n%s",
                    stderr,
                )

                return False

            logger.info(
                "AI patch rolled back safely."
            )

            return True

        finally:

            patch_file.unlink(
                missing_ok=True
            )

    except Exception as exc:

        logger.error(
            "Rollback error: %s",
            exc,
        )

        return False


# ============================================================================
# Build Validation
# ============================================================================

def validate_build(
    repo_dir: Path,
    cfg: EnvironmentConfig,
) -> bool:

    build_dir = repo_dir / cfg.build_dir

    logger.info(
        "Configuring CMake..."
    )

    code, stdout, stderr = run_command(
        [
            "cmake",
            "-S",
            ".",
            "-B",
            str(build_dir),
            "-G",
            cfg.cmake_generator,
            f"-DCMAKE_BUILD_TYPE={cfg.build_type}",
        ],
        cwd=repo_dir,
        timeout=300,
    )

    if code != 0:

        logger.error(
            "CMake configuration failed."
        )

        logger.error(
            "%s",
            stderr[-6000:],
        )

        return False

    logger.info(
        "Building VoidOne..."
    )

    code, stdout, stderr = run_command(
        [
            "cmake",
            "--build",
            str(build_dir),
            "--config",
            cfg.build_type,
            "--parallel",
        ],
        cwd=repo_dir,
        timeout=900,
    )

    if code != 0:

        logger.error(
            "CMake build failed."
        )

        logger.error(
            "%s",
            stderr[-8000:],
        )

        return False

    logger.info(
        "Build validation succeeded."
    )

    # --------------------------------------------------------------
    # Tests
    # --------------------------------------------------------------

    if not cfg.run_tests:

        logger.info(
            "Tests disabled by configuration."
        )

        return True

    logger.info(
        "Running test suite..."
    )

    code, stdout, stderr = run_command(
        [
            "ctest",
            "--test-dir",
            str(build_dir),
            "--output-on-failure",
        ],
        cwd=repo_dir,
        timeout=900,
    )

    if code != 0:

        logger.error(
            "Test suite failed."
        )

        logger.error(
            "%s",
            stderr[-8000:],
        )

        return False

    logger.info(
        "Test suite passed."
    )

    return True


# ============================================================================
# Main
# ============================================================================

def main() -> int:

    parser = argparse.ArgumentParser(
        description=(
            "VoidOne Autonomous AI CI Repair Engine"
        )
    )

    parser.add_argument(
        "--log-file",
        required=True,
        help="Path to CI failure log.",
    )

    parser.add_argument(
        "--skip-tests",
        action="store_true",
        help="Skip tests during validation.",
    )

    args = parser.parse_args()

    # ------------------------------------------------------------------
    # Configuration
    # ------------------------------------------------------------------

    cfg = EnvironmentConfig()

    if args.skip_tests:
        cfg.run_tests = False

    logger.info(
        "Repository: %s",
        cfg.repo_dir,
    )

    logger.info(
        "Gemini model: %s",
        cfg.gemini_model,
    )

    logger.info(
        "Local model: %s",
        cfg.local_model_name,
    )

    # ------------------------------------------------------------------
    # Validate repository
    # ------------------------------------------------------------------

    if not (cfg.repo_dir / ".git").exists():

        logger.error(
            "Repository does not appear to be a Git repository."
        )

        return 1

    # ------------------------------------------------------------------
    # Read CI log
    # ------------------------------------------------------------------

    log_path = Path(
        args.log_file
    ).resolve()

    if not log_path.exists():

        logger.error(
            "CI failure log does not exist: %s",
            log_path,
        )

        return 1

    try:

        log_text = log_path.read_text(
            encoding="utf-8",
            errors="replace",
        )

    except Exception as exc:

        logger.error(
            "Could not read CI log: %s",
            exc,
        )

        return 1

    log_tail = log_text[-MAX_LOG_SIZE:]

    if not log_tail.strip():

        logger.error(
            "CI failure log is empty."
        )

        return 1

    # ------------------------------------------------------------------
    # Collect context
    # ------------------------------------------------------------------

    logger.info(
        "Collecting repository context..."
    )

    repo_context = collect_repo_context(
        cfg.repo_dir,
        log_tail,
    )

    logger.info(
        "Repository context size: %d characters",
        len(repo_context),
    )

    # ------------------------------------------------------------------
    # AI inference
    # ------------------------------------------------------------------

    client = AIInferenceClient(cfg)

    repair_plan = client.repair(
        log_tail,
        repo_context,
    )

    if not repair_plan:

        logger.error(
            "No valid AI repair plan was generated."
        )

        return 1

    status = str(
        repair_plan.get(
            "status",
            "",
        )
    ).upper()

    diagnosis = str(
        repair_plan.get(
            "diagnosis",
            "No diagnosis provided.",
        )
    )

    patch = str(
        repair_plan.get(
            "patch",
            "",
        )
    )

    logger.info(
        "AI Diagnosis: %s",
        diagnosis,
    )

    # ------------------------------------------------------------------
    # NO_FIX
    # ------------------------------------------------------------------

    if status == "NO_FIX":

        logger.warning(
            "AI determined that no safe automatic fix exists."
        )

        return 1

    # ------------------------------------------------------------------
    # Validate AI response
    # ------------------------------------------------------------------

    if status != "PATCH":

        logger.error(
            "Unexpected AI status: %s",
            status,
        )

        return 1

    if not validate_patch(patch):

        logger.error(
            "AI generated an invalid or unsafe patch."
        )

        return 1

    # ------------------------------------------------------------------
    # Apply patch
    # ------------------------------------------------------------------

    logger.info(
        "Applying AI-generated patch..."
    )

    patch_handle = apply_patch_safely(
        cfg.repo_dir,
        patch,
    )

    if patch_handle is None:

        logger.error(
            "Failed to apply AI patch safely."
        )

        return 1

    # ------------------------------------------------------------------
    # Validate build
    # ------------------------------------------------------------------

    logger.info(
        "Validating generated fix..."
    )

    if validate_build(
        cfg.repo_dir,
        cfg,
    ):

        logger.info(
            "=========================================="
        )

        logger.info(
            "AI REPAIR SUCCESS"
        )

        logger.info(
            "Patch applied, build validated, tests passed."
        )

        logger.info(
            "=========================================="
        )

        return 0

    # ------------------------------------------------------------------
    # Rollback ONLY our generated patch
    # ------------------------------------------------------------------

    logger.warning(
        "Validation failed."
    )

    logger.warning(
        "Rolling back ONLY the AI-generated patch..."
    )

    if rollback_patch(
        cfg.repo_dir,
        patch,
    ):

        logger.info(
            "Rollback completed safely."
        )

    else:

        logger.error(
            "CRITICAL: Automatic rollback failed."
        )

        return 2

    logger.error(
        "AI repair was rejected because validation failed."
    )

    return 1


# ============================================================================
# Entrypoint
# ============================================================================

if __name__ == "__main__":
    sys.exit(main())