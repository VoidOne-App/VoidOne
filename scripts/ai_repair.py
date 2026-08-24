#!/usr/bin/env python3

"""
VoidOne Autonomous AI CI Repair Engine

Pipeline:
    CI failure log
        ↓
    Repository context collection
        ↓
    Gemini diagnosis + candidate patch
        ↓
    Patch security validation
        ↓
    Patch application
        ↓
    CMake configure
        ↓
    Build
        ↓
    Tests
        ↓
    Local Qwen review
        ↓
    Success / rollback

The engine NEVER commits or pushes changes itself.
The GitHub Actions workflow is responsible for creating a branch
and opening a draft PR after validation succeeds.
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
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import requests


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

logging.basicConfig(
    level=logging.INFO,
    format="[VOIDONE-AI-ENGINE] %(asctime)s - %(levelname)s - %(message)s",
)

logger = logging.getLogger("VoidOneAIRepair")


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

MAX_LOG_CHARS = 20_000
MAX_FILE_CHARS = 12_000
MAX_CONTEXT_CHARS = 60_000

PROTECTED_PATHS = (
    ".git/",
    ".github/",
    "scripts/ai_repair.py",
    "scripts/requirements-ai-repair.txt",
)

ALLOWED_SOURCE_EXTENSIONS = {
    ".c",
    ".cc",
    ".cpp",
    ".cxx",
    ".h",
    ".hh",
    ".hpp",
    ".hxx",
    ".qml",
    ".cmake",
}

BUILD_DIRECTORIES = (
    "build",
    "build-debug",
    "build-release",
    "build-ci",
    "build-codeql",
)


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class EnvironmentConfig:
    repo_dir: Path

    gemini_api_key: str
    gemini_model: str

    local_model_url: str
    local_model_name: str

    build_timeout: int
    test_timeout: int

    @classmethod
    def from_environment(cls, repo_dir: Path) -> "EnvironmentConfig":
        return cls(
            repo_dir=repo_dir.resolve(),

            gemini_api_key=os.getenv("GEMINI_API_KEY", "").strip(),
            gemini_model=os.getenv(
                "GEMINI_MODEL",
                "gemini-2.5-pro",
            ).strip(),

            local_model_url=os.getenv(
                "LOCAL_MODEL_URL",
                "http://127.0.0.1:11434/v1",
            ).rstrip("/"),

            local_model_name=os.getenv(
                "LOCAL_MODEL_NAME",
                "qwen2.5-coder:1.5b",
            ).strip(),

            build_timeout=int(
                os.getenv("AI_REPAIR_BUILD_TIMEOUT", "900")
            ),

            test_timeout=int(
                os.getenv("AI_REPAIR_TEST_TIMEOUT", "600")
            ),
        )


# ---------------------------------------------------------------------------
# Command execution
# ---------------------------------------------------------------------------

def run_command(
    command: List[str],
    cwd: Path,
    timeout: int,
) -> Tuple[int, str, str]:

    logger.info("$ %s", " ".join(command))

    try:
        process = subprocess.Popen(
            command,
            cwd=str(cwd),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            errors="replace",
        )

        stdout, stderr = process.communicate(timeout=timeout)

        return process.returncode, stdout, stderr

    except subprocess.TimeoutExpired:
        process.kill()

        stdout, stderr = process.communicate()

        return (
            -1,
            stdout,
            f"Command timed out after {timeout} seconds.\n{stderr}",
        )

    except Exception as exc:
        return -1, "", str(exc)


# ---------------------------------------------------------------------------
# Path security
# ---------------------------------------------------------------------------

def normalize_repo_path(path: str) -> Optional[str]:
    """
    Convert a patch path into a safe repository-relative POSIX path.

    Reject:
      - absolute paths
      - Windows drive paths
      - ../ traversal
      - empty paths
    """

    path = path.strip().replace("\\", "/")

    if not path:
        return None

    if path.startswith("/"):
        return None

    if re.match(r"^[A-Za-z]:/", path):
        return None

    path = re.sub(r"^\./", "", path)

    parts = Path(path).parts

    if ".." in parts:
        return None

    return path


def is_protected_path(path: str) -> bool:
    normalized = path.replace("\\", "/").lstrip("./")

    for protected in PROTECTED_PATHS:
        protected_normalized = protected.replace("\\", "/").lstrip("./")

        if normalized == protected_normalized.rstrip("/"):
            return True

        if normalized.startswith(protected_normalized):
            return True

    return False


# ---------------------------------------------------------------------------
# Repository context
# ---------------------------------------------------------------------------

def read_file_limited(path: Path, limit: int = MAX_FILE_CHARS) -> str:
    try:
        text = path.read_text(
            encoding="utf-8",
            errors="replace",
        )

        if len(text) > limit:
            return text[:limit] + "\n... [TRUNCATED] ..."

        return text

    except Exception as exc:
        logger.warning("Unable to read %s: %s", path, exc)
        return ""


def extract_referenced_files(
    repo_dir: Path,
    log_text: str,
) -> List[str]:

    candidates = set()

    # Common compiler / CMake path patterns.
    patterns = [
        r"(?<![\w./-])([A-Za-z0-9_.\-/]+\.(?:cpp|cc|cxx|c|hpp|hh|hxx|h|qml|cmake))",
        r"(?:--|\s)([A-Za-z0-9_.\-/]+/CMakeLists\.txt)",
    ]

    for pattern in patterns:
        for match in re.findall(pattern, log_text):
            path = normalize_repo_path(match)

            if not path:
                continue

            if is_protected_path(path):
                continue

            target = repo_dir / path

            if target.is_file():
                candidates.add(path)

    return sorted(candidates)


def collect_repository_context(
    repo_dir: Path,
    failure_log: str,
) -> str:

    sections: List[str] = []

    core_files = [
        "CMakeLists.txt",
        "README.md",
        "CMakePresets.json",
    ]

    for filename in core_files:
        path = repo_dir / filename

        if path.is_file():
            content = read_file_limited(path)

            if content:
                sections.append(
                    f"=== FILE: {filename} ===\n{content}"
                )

    referenced_files = extract_referenced_files(
        repo_dir,
        failure_log,
    )

    for relative_path in referenced_files[:25]:

        path = repo_dir / relative_path
        content = read_file_limited(path)

        if content:
            sections.append(
                f"=== FILE: {relative_path} ===\n{content}"
            )

    context = "\n\n".join(sections)

    if len(context) > MAX_CONTEXT_CHARS:
        context = context[:MAX_CONTEXT_CHARS] + (
            "\n... [CONTEXT TRUNCATED] ..."
        )

    return context


# ---------------------------------------------------------------------------
# JSON parsing
# ---------------------------------------------------------------------------

def extract_json_object(text: str) -> Optional[Dict[str, Any]]:
    """
    Robustly extract a JSON object from an AI response.

    Handles:
      - plain JSON
      - ```json ... ```
      - surrounding explanatory text
    """

    if not text:
        return None

    cleaned = text.strip()

    # Markdown fenced JSON.
    fenced = re.search(
        r"```(?:json)?\s*(\{.*?\})\s*```",
        cleaned,
        flags=re.DOTALL,
    )

    if fenced:
        cleaned = fenced.group(1)

    try:
        result = json.loads(cleaned)

        if isinstance(result, dict):
            return result

    except json.JSONDecodeError:
        pass

    # Try extracting the first JSON object.
    start = cleaned.find("{")
    end = cleaned.rfind("}")

    if start >= 0 and end > start:

        candidate = cleaned[start:end + 1]

        try:
            result = json.loads(candidate)

            if isinstance(result, dict):
                return result

        except json.JSONDecodeError as exc:
            logger.error(
                "Unable to parse AI JSON response: %s",
                exc,
            )

    return None


# ---------------------------------------------------------------------------
# AI response validation
# ---------------------------------------------------------------------------

def validate_patch_response(
    response: Optional[Dict[str, Any]],
) -> bool:

    if not response:
        return False

    if response.get("status") != "PATCH":
        return False

    diagnosis = response.get("diagnosis")

    patch = response.get("patch")

    if not isinstance(diagnosis, str):
        return False

    if not isinstance(patch, str):
        return False

    if not patch.strip():
        return False

    return True


# ---------------------------------------------------------------------------
# Gemini
# ---------------------------------------------------------------------------

class AIInferenceClient:

    def __init__(self, config: EnvironmentConfig):
        self.config = config

    def query_gemini(
        self,
        failure_log: str,
        repo_context: str,
    ) -> Optional[Dict[str, Any]]:

        if not self.config.gemini_api_key:
            logger.warning(
                "GEMINI_API_KEY is missing. "
                "Using local model."
            )

            return self.query_local_reviewer(
                failure_log,
                repo_context,
                role="repair",
            )

        endpoint = (
            "https://generativelanguage.googleapis.com/"
            "v1beta/models/"
            f"{self.config.gemini_model}"
            ":generateContent"
        )

        prompt = f"""
You are the lead C++23 / Qt6 engineer for the VoidOne project.

Your task is to diagnose a failed CI build and propose the smallest
safe source-code patch that fixes the ROOT CAUSE.

STRICT RULES:

1. Do NOT modify:
   - .git/
   - .github/
   - scripts/
   - CI workflows
   - dependency lock files unless absolutely required
2. Do NOT rewrite large portions of the project.
3. Do NOT change unrelated files.
4. Do NOT disable tests.
5. Do NOT suppress compiler warnings merely to make CI pass.
6. Do NOT add telemetry, networking, tracking, or external services.
7. Do NOT introduce secrets.
8. Prefer the smallest maintainable fix.
9. The patch MUST be a valid unified git diff.
10. If there is not enough information to safely produce a patch,
    return status "NO_FIX".

Return ONLY valid JSON:

{{
  "status": "PATCH" | "NO_FIX",
  "diagnosis": "short root-cause explanation",
  "confidence": 0-100,
  "files": ["path1", "path2"],
  "patch": "unified git diff"
}}

CI FAILURE LOG:
{failure_log}

REPOSITORY CONTEXT:
{repo_context}
""".strip()

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

        try:

            response = requests.post(
                endpoint,
                params={
                    "key": self.config.gemini_api_key,
                },
                json=payload,
                timeout=120,
            )

            if response.status_code != 200:
                logger.error(
                    "Gemini returned HTTP %s: %s",
                    response.status_code,
                    response.text[:1000],
                )

                return self.query_local_reviewer(
                    failure_log,
                    repo_context,
                    role="repair",
                )

            data = response.json()

            text = (
                data["candidates"][0]
                ["content"]["parts"][0]
                ["text"]
            )

            result = extract_json_object(text)

            if validate_patch_response(result):
                return result

            logger.error(
                "Gemini returned an invalid repair response."
            )

        except Exception as exc:
            logger.error(
                "Gemini request failed: %s",
                exc,
            )

        return self.query_local_reviewer(
            failure_log,
            repo_context,
            role="repair",
        )

    # -----------------------------------------------------------------------
    # Local Qwen
    # -----------------------------------------------------------------------

    def query_local_reviewer(
        self,
        failure_log: str,
        repo_context: str,
        role: str,
        patch: str = "",
    ) -> Optional[Dict[str, Any]]:

        endpoint = (
            f"{self.config.local_model_url}"
            "/chat/completions"
        )

        if role == "review":

            prompt = f"""
You are the final security and correctness reviewer for VoidOne.

Review the proposed AI patch.

Reject the patch if it:
- modifies protected paths
- introduces unrelated changes
- disables tests
- weakens security
- adds telemetry
- contains suspicious commands
- breaks C++/Qt architecture
- does not address the CI failure

Return ONLY JSON:

{{
  "decision": "APPROVE" | "REJECT",
  "confidence": 0-100,
  "reason": "short explanation"
}}

CI FAILURE:
{failure_log}

PATCH:
{patch}

REPOSITORY CONTEXT:
{repo_context}
""".strip()

        else:

            prompt = f"""
You are the fallback C++23 / Qt6 repair engineer for VoidOne.

Analyze the CI failure and create the smallest safe unified diff.

Never modify:
- .git/
- .github/
- scripts/

Return ONLY JSON:

{{
  "status": "PATCH" | "NO_FIX",
  "diagnosis": "root cause",
  "confidence": 0-100,
  "files": [],
  "patch": "unified git diff"
}}

CI FAILURE:
{failure_log}

REPOSITORY CONTEXT:
{repo_context}
""".strip()

        payload = {
            "model": self.config.local_model_name,
            "messages": [
                {
                    "role": "user",
                    "content": prompt,
                }
            ],
            "temperature": 0.1,
        }

        try:

            response = requests.post(
                endpoint,
                json=payload,
                timeout=180,
            )

            response.raise_for_status()

            data = response.json()

            text = (
                data["choices"][0]
                ["message"]["content"]
            )

            return extract_json_object(text)

        except Exception as exc:
            logger.error(
                "Local model request failed: %s",
                exc,
            )

            return None


# ---------------------------------------------------------------------------
# Patch validation
# ---------------------------------------------------------------------------

def extract_patch_files(patch: str) -> List[str]:

    files = []

    patterns = [
        r"^--- a/(.+)$",
        r"^\+\+\+ b/(.+)$",
    ]

    for pattern in patterns:

        for match in re.findall(
            pattern,
            patch,
            flags=re.MULTILINE,
        ):

            path = normalize_repo_path(match)

            if path:
                files.append(path)

    return sorted(set(files))


def validate_patch_security(
    repo_dir: Path,
    patch: str,
) -> Tuple[bool, str]:

    if not patch.strip():
        return False, "Empty patch."

    if "\x00" in patch:
        return False, "Patch contains NUL byte."

    # We intentionally require git diff structure.
    if "--- a/" not in patch or "+++ b/" not in patch:
        return False, "Patch is not a valid unified git diff."

    files = extract_patch_files(patch)

    if not files:
        return False, "No patch files detected."

    for path in files:

        if is_protected_path(path):
            return (
                False,
                f"Protected path modification: {path}",
            )

        if normalize_repo_path(path) is None:
            return (
                False,
                f"Unsafe path detected: {path}",
            )

        suffix = Path(path).suffix.lower()

        if suffix not in ALLOWED_SOURCE_EXTENSIONS:

            # Permit CMakeLists.txt without extension.
            if Path(path).name != "CMakeLists.txt":
                return (
                    False,
                    f"Unexpected file type in patch: {path}",
                )

    # Dangerous shell-ish constructs.
    forbidden_patterns = [
        r"\bgit\s+push\b",
        r"\bgit\s+reset\b",
        r"\brm\s+-rf\b",
        r"\bcurl\s+.*\|\s*(sh|bash)",
        r"\bwget\s+.*\|\s*(sh|bash)",
        r"\bchmod\s+\+x\b",
    ]

    for pattern in forbidden_patterns:

        if re.search(
            pattern,
            patch,
            flags=re.IGNORECASE,
        ):
            return (
                False,
                f"Suspicious command detected: {pattern}",
            )

    return True, "Patch passed security validation."


# ---------------------------------------------------------------------------
# Patch application
# ---------------------------------------------------------------------------

def apply_patch(
    repo_dir: Path,
    patch: str,
) -> bool:

    safe, reason = validate_patch_security(
        repo_dir,
        patch,
    )

    if not safe:
        logger.error(
            "Patch rejected: %s",
            reason,
        )

        return False

    patch_path: Optional[Path] = None

    try:

        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            suffix=".patch",
            dir=repo_dir,
            delete=False,
        ) as temp:

            temp.write(patch)
            patch_path = Path(temp.name)

        check_code, _, check_err = run_command(
            [
                "git",
                "apply",
                "--check",
                "--whitespace=error-all",
                str(patch_path),
            ],
            cwd=repo_dir,
            timeout=60,
        )

        if check_code != 0:

            logger.error(
                "git apply --check failed:\n%s",
                check_err,
            )

            return False

        apply_code, _, apply_err = run_command(
            [
                "git",
                "apply",
                "--whitespace=error-all",
                str(patch_path),
            ],
            cwd=repo_dir,
            timeout=60,
        )

        if apply_code != 0:

            logger.error(
                "git apply failed:\n%s",
                apply_err,
            )

            return False

        logger.info(
            "Patch successfully applied."
        )

        return True

    finally:

        if patch_path and patch_path.exists():
            patch_path.unlink(missing_ok=True)


# ---------------------------------------------------------------------------
# Build validation
# ---------------------------------------------------------------------------

def clean_build_directory(repo_dir: Path) -> None:

    build_dir = repo_dir / "build"

    if build_dir.exists():

        logger.info(
            "Removing previous build directory."
        )

        import shutil

        shutil.rmtree(
            build_dir,
            ignore_errors=True,
        )


def validate_build(
    config: EnvironmentConfig,
) -> bool:

    repo_dir = config.repo_dir

    clean_build_directory(repo_dir)

    logger.info(
        "Configuring CMake..."
    )

    configure_code, configure_out, configure_err = run_command(
        [
            "cmake",
            "-S",
            ".",
            "-B",
            "build",
            "-G",
            "Ninja",
            "-DCMAKE_BUILD_TYPE=Release",
            "-DBUILD_TESTING=ON",
        ],
        cwd=repo_dir,
        timeout=config.build_timeout,
    )

    if configure_code != 0:

        logger.error(
            "CMake configuration failed:\n%s\n%s",
            configure_out[-5000:],
            configure_err[-5000:],
        )

        return False

    logger.info(
        "Building patched project..."
    )

    build_code, build_out, build_err = run_command(
        [
            "cmake",
            "--build",
            "build",
            "--parallel",
        ],
        cwd=repo_dir,
        timeout=config.build_timeout,
    )

    if build_code != 0:

        logger.error(
            "Build failed:\n%s\n%s",
            build_out[-5000:],
            build_err[-5000:],
        )

        return False

    logger.info(
        "Running CTest..."
    )

    test_code, test_out, test_err = run_command(
        [
            "ctest",
            "--test-dir",
            "build",
            "--output-on-failure",
            "--timeout",
            "120",
        ],
        cwd=repo_dir,
        timeout=config.test_timeout,
    )

    if test_code != 0:

        logger.error(
            "CTest failed:\n%s\n%s",
            test_out[-5000:],
            test_err[-5000:],
        )

        return False

    logger.info(
        "Build and tests passed successfully."
    )

    return True


# ---------------------------------------------------------------------------
# Git state
# ---------------------------------------------------------------------------

def git_diff(repo_dir: Path) -> str:

    code, stdout, stderr = run_command(
        [
            "git",
            "diff",
            "--",
        ],
        cwd=repo_dir,
        timeout=60,
    )

    if code != 0:
        logger.warning(
            "Unable to obtain git diff: %s",
            stderr,
        )

        return ""

    return stdout


def rollback(repo_dir: Path) -> None:

    logger.warning(
        "Rolling back AI-generated changes..."
    )

    code, _, stderr = run_command(
        [
            "git",
            "reset",
            "--hard",
            "HEAD",
        ],
        cwd=repo_dir,
        timeout=60,
    )

    if code != 0:
        logger.error(
            "Rollback failed: %s",
            stderr,
        )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:

    parser = argparse.ArgumentParser(
        description=(
            "VoidOne Autonomous AI CI Repair Engine"
        )
    )

    parser.add_argument(
        "--log-file",
        required=True,
        help="Path to the CI failure log.",
    )

    parser.add_argument(
        "--repo",
        default=".",
        help="Repository root.",
    )

    args = parser.parse_args()

    repo_dir = Path(
        args.repo
    ).resolve()

    log_file = Path(
        args.log_file
    ).resolve()

    if not repo_dir.is_dir():
        logger.error(
            "Repository directory does not exist: %s",
            repo_dir,
        )

        return 1

    if not log_file.is_file():
        logger.error(
            "Failure log does not exist: %s",
            log_file,
        )

        return 1

    failure_log = log_file.read_text(
        encoding="utf-8",
        errors="replace",
    )

    failure_log = failure_log[-MAX_LOG_CHARS:]

    if not failure_log.strip():
        logger.error(
            "CI failure log is empty."
        )

        return 1

    config = EnvironmentConfig.from_environment(
        repo_dir
    )

    logger.info(
        "Repository: %s",
        config.repo_dir,
    )

    logger.info(
        "Collecting repository context..."
    )

    repo_context = collect_repository_context(
        config.repo_dir,
        failure_log,
    )

    client = AIInferenceClient(config)

    logger.info(
        "Requesting repair diagnosis..."
    )

    repair = client.query_gemini(
        failure_log,
        repo_context,
    )

    if not validate_patch_response(repair):

        logger.error(
            "AI failed to produce a valid repair patch."
        )

        return 1

    diagnosis = repair.get(
        "diagnosis",
        "No diagnosis provided.",
    )

    confidence = repair.get(
        "confidence",
        "unknown",
    )

    patch = repair.get(
        "patch",
        "",
    )

    logger.info(
        "Diagnosis: %s",
        diagnosis,
    )

    logger.info(
        "AI confidence: %s",
        confidence,
    )

    safe, reason = validate_patch_security(
        config.repo_dir,
        patch,
    )

    if not safe:

        logger.error(
            "Security validation rejected patch: %s",
            reason,
        )

        return 1

    if not apply_patch(
        config.repo_dir,
        patch,
    ):

        logger.error(
            "Patch application failed."
        )

        return 1

    logger.info(
        "Running post-patch validation..."
    )

    if not validate_build(config):

        rollback(config.repo_dir)

        logger.error(
            "Post-patch validation failed."
        )

        return 1

    applied_diff = git_diff(
        config.repo_dir
    )

    if not applied_diff.strip():

        logger.error(
            "No git changes detected after repair."
        )

        return 1

    logger.info(
        "Requesting final local AI review..."
    )

    review = client.query_local_reviewer(
        failure_log,
        repo_context,
        role="review",
        patch=applied_diff,
    )

    if not review:

        rollback(config.repo_dir)

        logger.error(
            "Final AI review unavailable. "
            "Failing closed."
        )

        return 1

    if review.get("decision") != "APPROVE":

        rollback(config.repo_dir)

        logger.error(
            "Local AI reviewer rejected the patch: %s",
            review.get("reason", "unknown"),
        )

        return 1

    logger.info(
        "Final AI review approved the patch."
    )

    logger.info(
        "=================================================="
    )

    logger.info(
        "VOIDONE AI REPAIR SUCCESS"
    )

    logger.info(
        "Diagnosis: %s",
        diagnosis,
    )

    logger.info(
        "AI Confidence: %s",
        confidence,
    )

    logger.info(
        "Reviewer: APPROVED"
    )

    logger.info(
        "Build: PASSED"
    )

    logger.info(
        "Tests: PASSED"
    )

    logger.info(
        "=================================================="
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())