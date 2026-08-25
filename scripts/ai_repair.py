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

Repair policy:

    Allowed:
        - Source code
        - CMake
        - QML
        - Tests
        - Build scripts
        - Packaging files
        - GitHub Actions workflows
        - CI/CD scripts
        - Python / shell / PowerShell automation
        - NSIS / WiX configuration
        - Other repository files required to repair CI

    Protected:
        - .git/
        - scripts/ai_repair.py
        - scripts/requirements-ai-repair.txt
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

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
MAX_REFERENCED_FILES = 40

PROTECTED_PATHS = (
    ".git/",
    "scripts/ai_repair.py",
    "scripts/requirements-ai-repair.txt",
)

ALLOWED_FILE_EXTENSIONS = {
    # C / C++
    ".c",
    ".cc",
    ".cpp",
    ".cxx",
    ".h",
    ".hh",
    ".hpp",
    ".hxx",

    # Qt / QML
    ".qml",
    ".qrc",
    ".ui",

    # CMake / build
    ".cmake",

    # Python / scripting
    ".py",
    ".pyw",
    ".sh",
    ".bash",
    ".ps1",
    ".bat",
    ".cmd",

    # CI
    ".yml",
    ".yaml",

    # Packaging
    ".nsi",
    ".nsh",
    ".wxs",
    ".wxi",

    # Configuration / metadata
    ".json",
    ".xml",
    ".rc",
    ".ini",
    ".cfg",
    ".conf",
    ".toml",

    # Documentation / text
    ".txt",
    ".md",
}

ALLOWED_EXTENSIONLESS_FILES = {
    "CMakeLists.txt",
    "Makefile",
    "Dockerfile",
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
    def from_environment(
        cls,
        repo_dir: Path,
    ) -> "EnvironmentConfig":

        return cls(
            repo_dir=repo_dir.resolve(),

            gemini_api_key=os.getenv(
                "GEMINI_API_KEY",
                "",
            ).strip(),

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
                os.getenv(
                    "AI_REPAIR_BUILD_TIMEOUT",
                    "900",
                )
            ),

            test_timeout=int(
                os.getenv(
                    "AI_REPAIR_TEST_TIMEOUT",
                    "600",
                )
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

    logger.info(
        "$ %s",
        " ".join(command),
    )

    try:

        process = subprocess.Popen(
            command,
            cwd=str(cwd),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            errors="replace",
        )

        stdout, stderr = process.communicate(
            timeout=timeout,
        )

        return (
            process.returncode,
            stdout,
            stderr,
        )

    except subprocess.TimeoutExpired:

        process.kill()

        stdout, stderr = process.communicate()

        return (
            -1,
            stdout,
            (
                f"Command timed out after "
                f"{timeout} seconds.\n"
                f"{stderr}"
            ),
        )

    except Exception as exc:

        return (
            -1,
            "",
            str(exc),
        )


# ---------------------------------------------------------------------------
# Path security
# ---------------------------------------------------------------------------

def normalize_repo_path(
    path: str,
) -> Optional[str]:
    """
    Convert a patch path into a safe repository-relative POSIX path.

    Reject:
        - absolute paths
        - Windows drive paths
        - parent traversal
        - empty paths
    """

    path = path.strip().replace(
        "\\",
        "/",
    )

    if not path:
        return None

    if path.startswith("/"):
        return None

    if re.match(
        r"^[A-Za-z]:/",
        path,
    ):
        return None

    path = re.sub(
        r"^\./",
        "",
        path,
    )

    parts = Path(path).parts

    if ".." in parts:
        return None

    return path


def is_protected_path(
    path: str,
) -> bool:

    normalized = (
        path
        .replace("\\", "/")
        .lstrip("./")
    )

    for protected in PROTECTED_PATHS:

        protected_normalized = (
            protected
            .replace("\\", "/")
            .lstrip("./")
            .rstrip("/")
        )

        if normalized == protected_normalized:
            return True

        if normalized.startswith(
            protected_normalized + "/"
        ):
            return True

    return False


def is_allowed_file_path(
    path: str,
) -> bool:

    normalized = normalize_repo_path(
        path
    )

    if normalized is None:
        return False

    if is_protected_path(
        normalized
    ):
        return False

    filename = Path(
        normalized
    ).name

    if filename in ALLOWED_EXTENSIONLESS_FILES:
        return True

    suffix = Path(
        normalized
    ).suffix.lower()

    return suffix in ALLOWED_FILE_EXTENSIONS


# ---------------------------------------------------------------------------
# Repository context
# ---------------------------------------------------------------------------

def read_file_limited(
    path: Path,
    limit: int = MAX_FILE_CHARS,
) -> str:

    try:

        text = path.read_text(
            encoding="utf-8",
            errors="replace",
        )

        if len(text) > limit:

            return (
                text[:limit]
                + "\n... [TRUNCATED] ..."
            )

        return text

    except Exception as exc:

        logger.warning(
            "Unable to read %s: %s",
            path,
            exc,
        )

        return ""


def extract_referenced_files(
    repo_dir: Path,
    log_text: str,
) -> List[str]:

    candidates: Set[str] = set()

    patterns = [
        (
            r"(?<![\w./-])"
            r"([A-Za-z0-9_.\-/]+"
            r"\.(?:cpp|cc|cxx|c|hpp|hh|hxx|h|"
            r"qml|cmake|py|sh|bash|ps1|bat|cmd|"
            r"yml|yaml|nsi|nsh|wxs|wxi|json|xml))"
        ),
        (
            r"(?:--|\s)"
            r"([A-Za-z0-9_.\-/]+/CMakeLists\.txt)"
        ),
        (
            r"((?:\.github/)?"
            r"[A-Za-z0-9_.\-/]+"
            r"/(?:Dockerfile|Makefile))"
        ),
    ]

    for pattern in patterns:

        for match in re.findall(
            pattern,
            log_text,
        ):

            path = normalize_repo_path(
                match
            )

            if not path:
                continue

            if is_protected_path(
                path
            ):
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

        if not path.is_file():
            continue

        content = read_file_limited(
            path
        )

        if content:

            sections.append(
                f"=== FILE: {filename} ===\n"
                f"{content}"
            )

    referenced_files = extract_referenced_files(
        repo_dir,
        failure_log,
    )

    for relative_path in referenced_files[
        :MAX_REFERENCED_FILES
    ]:

        path = repo_dir / relative_path

        content = read_file_limited(
            path
        )

        if content:

            sections.append(
                f"=== FILE: {relative_path} ===\n"
                f"{content}"
            )

    context = "\n\n".join(
        sections
    )

    if len(context) > MAX_CONTEXT_CHARS:

        context = (
            context[:MAX_CONTEXT_CHARS]
            + "\n... [CONTEXT TRUNCATED] ..."
        )

    return context


# ---------------------------------------------------------------------------
# JSON parsing
# ---------------------------------------------------------------------------

def extract_json_object(
    text: str,
) -> Optional[Dict[str, Any]]:
    """
    Extract the first balanced JSON object.

    Supports:
        - plain JSON
        - fenced JSON
        - explanatory text around JSON
    """

    if not text:
        return None

    cleaned = text.strip()

    fenced_match = re.search(
        r"```(?:json)?\s*(.*?)\s*```",
        cleaned,
        flags=re.DOTALL | re.IGNORECASE,
    )

    if fenced_match:

        cleaned = fenced_match.group(
            1
        ).strip()

    try:

        result = json.loads(
            cleaned
        )

        if isinstance(
            result,
            dict,
        ):
            return result

    except json.JSONDecodeError:
        pass

    start = cleaned.find("{")

    if start < 0:
        return None

    depth = 0
    in_string = False
    escaped = False

    for index in range(
        start,
        len(cleaned),
    ):

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

                candidate = cleaned[
                    start:index + 1
                ]

                try:

                    result = json.loads(
                        candidate
                    )

                    if isinstance(
                        result,
                        dict,
                    ):
                        return result

                except json.JSONDecodeError as exc:

                    logger.error(
                        "Unable to parse AI JSON response: %s",
                        exc,
                    )

                return None

    return None


# ---------------------------------------------------------------------------
# AI response validation
# ---------------------------------------------------------------------------

def validate_patch_response(
    response: Optional[Dict[str, Any]],
) -> bool:

    if not isinstance(
        response,
        dict,
    ):
        return False

    if response.get(
        "status"
    ) != "PATCH":
        return False

    diagnosis = response.get(
        "diagnosis"
    )

    patch = response.get(
        "patch"
    )

    confidence = response.get(
        "confidence"
    )

    files = response.get(
        "files"
    )

    if not isinstance(
        diagnosis,
        str,
    ):
        return False

    if not diagnosis.strip():
        return False

    if not isinstance(
        patch,
        str,
    ):
        return False

    if not patch.strip():
        return False

    if not isinstance(
        confidence,
        (int, float),
    ):
        return False

    if not 0 <= confidence <= 100:
        return False

    if files is not None:

        if not isinstance(
            files,
            list,
        ):
            return False

        if not all(
            isinstance(item, str)
            for item in files
        ):
            return False

    return True


def validate_review_response(
    response: Optional[Dict[str, Any]],
) -> bool:

    if not isinstance(
        response,
        dict,
    ):
        return False

    decision = response.get(
        "decision"
    )

    confidence = response.get(
        "confidence"
    )

    reason = response.get(
        "reason"
    )

    if decision not in {
        "APPROVE",
        "REJECT",
    }:
        return False

    if not isinstance(
        confidence,
        (int, float),
    ):
        return False

    if not 0 <= confidence <= 100:
        return False

    if not isinstance(
        reason,
        str,
    ):
        return False

    return True


# ---------------------------------------------------------------------------
# Gemini / Local AI
# ---------------------------------------------------------------------------

class AIInferenceClient:

    def __init__(
        self,
        config: EnvironmentConfig,
    ):
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
You are the lead C++23 / Qt6 / CMake / CI engineer
for the VoidOne project.

Your task is to diagnose a failed CI build and propose
the smallest safe patch that fixes the ROOT CAUSE.

The repository contains a native PC gaming platform.
CI may involve:
- C++
- Qt6
- QML
- CMake
- Ninja
- GitHub Actions
- Python automation
- shell scripts
- PowerShell
- Windows packaging
- NSIS
- WiX
- tests

REPAIR POLICY:

You MAY modify repository files required to fix the failure,
including:

- source code
- headers
- QML
- tests
- CMake files
- build scripts
- Python scripts
- shell scripts
- PowerShell scripts
- GitHub Actions workflows
- CI configuration
- packaging configuration
- NSIS files
- WiX files
- configuration files

You MUST NOT modify:

- .git/
- scripts/ai_repair.py
- scripts/requirements-ai-repair.txt

STRICT RULES:

1. Fix the ROOT CAUSE.
2. Prefer the smallest maintainable change.
3. Do not rewrite unrelated parts of the project.
4. Do not disable tests.
5. Do not weaken security.
6. Do not add telemetry or tracking.
7. Do not introduce secrets.
8. Do not download or execute arbitrary external programs
   as part of the patch.
9. Do not modify the AI repair engine itself.
10. Do not modify Git metadata.
11. Do not use git push, git reset, git clean, or destructive
    repository commands inside the patch.
12. The patch MUST be a valid unified git diff.
13. If there is insufficient information to safely repair the
    failure, return "NO_FIX".

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
                "responseMimeType": (
                    "application/json"
                ),
            },
        }

        try:

            response = requests.post(
                endpoint,
                params={
                    "key":
                        self.config.gemini_api_key,
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

            result = extract_json_object(
                text
            )

            if validate_patch_response(
                result
            ):

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
You are the final security and correctness reviewer
for the VoidOne project.

Review the proposed AI-generated patch.

Protected files:

- .git/
- scripts/ai_repair.py
- scripts/requirements-ai-repair.txt

The patch MAY modify:

- source code
- CMake
- QML
- tests
- scripts
- GitHub Actions
- CI/CD
- packaging
- NSIS
- WiX
- configuration

REJECT the patch if it:

- modifies protected files
- contains path traversal
- modifies .git/
- modifies the AI repair engine
- introduces unrelated changes
- disables tests
- weakens security
- adds telemetry or tracking
- introduces secrets
- contains suspicious destructive commands
- does not address the CI failure
- contains an obviously unsafe CI modification

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
You are the fallback C++23 / Qt6 / CMake / CI engineer
for VoidOne.

Analyze the CI failure and create the smallest safe
unified git diff.

You MAY repair:

- source code
- CMake
- QML
- tests
- scripts
- GitHub Actions
- CI/CD
- packaging
- NSIS
- WiX
- configuration

Never modify:

- .git/
- scripts/ai_repair.py
- scripts/requirements-ai-repair.txt

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
            "model":
                self.config.local_model_name,

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

            result = extract_json_object(
                text
            )

            if role == "review":

                if validate_review_response(
                    result
                ):
                    return result

                return None

            if validate_patch_response(
                result
            ):
                return result

            return None

        except Exception as exc:

            logger.error(
                "Local model request failed: %s",
                exc,
            )

            return None


# ---------------------------------------------------------------------------
# Patch validation
# ---------------------------------------------------------------------------

def extract_patch_files(
    patch: str,
) -> List[str]:

    files: Set[str] = set()

    patterns = [
        r"^---\s+a/(.+)$",
        r"^\+\+\+\s+b/(.+)$",
        r"^rename from\s+(.+)$",
        r"^rename to\s+(.+)$",
    ]

    for pattern in patterns:

        for match in re.findall(
            pattern,
            patch,
            flags=re.MULTILINE,
        ):

            if match == "/dev/null":
                continue

            normalized = normalize_repo_path(
                match
            )

            if normalized:
                files.add(normalized)

    return sorted(files)


def validate_patch_security(
    repo_dir: Path,
    patch: str,
) -> Tuple[bool, str]:

    del repo_dir

    if not patch.strip():
        return False, "Empty patch."

    if "\x00" in patch:
        return False, "Patch contains NUL byte."

    if (
        "--- a/" not in patch
        or "+++ b/" not in patch
    ):
        return (
            False,
            "Patch is not a valid unified git diff.",
        )

    files = extract_patch_files(
        patch
    )

    if not files:

        return (
            False,
            "No patch files detected.",
        )

    for path in files:

        normalized = normalize_repo_path(
            path
        )

        if normalized is None:

            return (
                False,
                f"Unsafe path detected: {path}",
            )

        if is_protected_path(
            normalized
        ):

            return (
                False,
                f"Protected path modification: "
                f"{path}",
            )

        if not is_allowed_file_path(
            normalized
        ):

            return (
                False,
                f"Unexpected file type in patch: "
                f"{path}",
            )

    forbidden_patterns = [
        r"\bgit\s+push\b",
        r"\bgit\s+reset\b",
        r"\bgit\s+clean\b",
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
                f"Suspicious command detected: "
                f"{pattern}",
            )

    return (
        True,
        "Patch passed security validation.",
    )


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

            patch_path = Path(
                temp.name
            )

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

        if (
            patch_path
            and patch_path.exists()
        ):

            patch_path.unlink(
                missing_ok=True
            )


# ---------------------------------------------------------------------------
# Repository snapshot
# ---------------------------------------------------------------------------

def get_git_status(
    repo_dir: Path,
) -> List[str]:

    code, stdout, stderr = run_command(
        [
            "git",
            "status",
            "--porcelain",
            "--untracked-files=all",
        ],
        cwd=repo_dir,
        timeout=60,
    )

    if code != 0:

        raise RuntimeError(
            f"Unable to read git status: "
            f"{stderr}"
        )

    return [
        line
        for line in stdout.splitlines()
        if line.strip()
    ]


def create_repository_snapshot(
    repo_dir: Path,
) -> Set[str]:

    status = get_git_status(
        repo_dir
    )

    code, _, stderr = run_command(
        [
            "git",
            "diff",
            "HEAD",
        ],
        cwd=repo_dir,
        timeout=60,
    )

    if code != 0:

        raise RuntimeError(
            f"Unable to inspect repository: "
            f"{stderr}"
        )

    untracked: Set[str] = set()

    for line in status:

        if line.startswith(
            "?? "
        ):

            path = normalize_repo_path(
                line[3:]
            )

            if path:
                untracked.add(path)

    return untracked


def rollback(
    repo_dir: Path,
    original_untracked: Set[str],
) -> None:

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
            "git reset failed: %s",
            stderr,
        )

    code, _, stderr = run_command(
        [
            "git",
            "clean",
            "-fd",
            "--exclude=.git/",
        ],
        cwd=repo_dir,
        timeout=60,
    )

    if code != 0:

        logger.error(
            "git clean failed: %s",
            stderr,
        )

    # Original untracked files must survive rollback.
    # If one was removed by a patch, git clean cannot restore it.
    # Such files are therefore intentionally excluded from
    # the AI repair process by the clean repository requirement.


# ---------------------------------------------------------------------------
# Build validation
# ---------------------------------------------------------------------------

def clean_build_directory(
    repo_dir: Path,
) -> None:

    build_dir = repo_dir / "build"

    if build_dir.exists():

        logger.info(
            "Removing previous build directory."
        )

        shutil.rmtree(
            build_dir,
            ignore_errors=True,
        )


def validate_build(
    config: EnvironmentConfig,
) -> bool:

    repo_dir = config.repo_dir

    clean_build_directory(
        repo_dir
    )

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
# Git diff
# ---------------------------------------------------------------------------

def git_diff(
    repo_dir: Path,
) -> str:

    code, stdout, stderr = run_command(
        [
            "git",
            "diff",
            "HEAD",
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

    failure_log = failure_log[
        -MAX_LOG_CHARS:
    ]

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

    try:

        original_untracked = (
            create_repository_snapshot(
                config.repo_dir
            )
        )

        initial_status = get_git_status(
            config.repo_dir
        )

    except RuntimeError as exc:

        logger.error(
            "Unable to inspect repository: %s",
            exc,
        )

        return 1

    if initial_status:

        logger.error(
            "Repository contains changes before "
            "AI repair."
        )

        for line in initial_status:
            logger.error(
                "  %s",
                line,
            )

        return 1

    logger.info(
        "Collecting repository context..."
    )

    repo_context = collect_repository_context(
        config.repo_dir,
        failure_log,
    )

    client = AIInferenceClient(
        config
    )

    logger.info(
        "Requesting repair diagnosis..."
    )

    repair = client.query_gemini(
        failure_log,
        repo_context,
    )

    if not validate_patch_response(
        repair
    ):

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
            "Security validation rejected patch: "
            "%s",
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

    if not validate_build(
        config
    ):

        rollback(
            config.repo_dir,
            original_untracked,
        )

        logger.error(
            "Post-patch validation failed."
        )

        return 1

    applied_diff = git_diff(
        config.repo_dir
    )

    current_status = get_git_status(
        config.repo_dir
    )

    if (
        not applied_diff.strip()
        and not current_status
    ):

        rollback(
            config.repo_dir,
            original_untracked,
        )

        logger.error(
            "No repository changes detected "
            "after repair."
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

        rollback(
            config.repo_dir,
            original_untracked,
        )

        logger.error(
            "Final AI review unavailable. "
            "Failing closed."
        )

        return 1

    if not validate_review_response(
        review
    ):

        rollback(
            config.repo_dir,
            original_untracked,
        )

        logger.error(
            "Final AI reviewer returned "
            "an invalid response."
        )

        return 1

    decision = review.get(
        "decision"
    )

    review_confidence = review.get(
        "confidence"
    )

    review_reason = review.get(
        "reason",
        "unknown",
    )

    if decision != "APPROVE":

        rollback(
            config.repo_dir,
            original_untracked,
        )

        logger.error(
            "Local AI reviewer rejected "
            "the patch: %s",
            review_reason,
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
        "Reviewer Confidence: %s",
        review_confidence,
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
    sys.exit(
        main()
    )