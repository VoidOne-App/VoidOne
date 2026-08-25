#!/usr/bin/env python3

"""
VoidOne Autonomous AI CI Repair Engine
======================================

Enterprise-grade autonomous CI diagnosis and repair engine.

Pipeline:

    CI failure
        ↓
    Failure classification
        ↓
    Repository context discovery
        ↓
    AI root-cause diagnosis
        ↓
    Candidate patch generation
        ↓
    Security / policy validation
        ↓
    Risk scoring
        ↓
    Patch application
        ↓
    CMake configure
        ↓
    Build
        ↓
    Tests
        ↓
    Independent local AI review
        ↓
    Success / rollback
        ↓
    Optional bounded retry

Design principles:

    - Fail closed
    - Least privilege
    - Minimal patches
    - Deterministic validation
    - Independent review
    - No autonomous merge
    - No autonomous push
    - No modification of the repair engine
    - No telemetry
    - No secrets in generated patches
    - Full auditability

The GitHub Actions workflow is responsible for:

    - creating the repair branch
    - committing the validated repair
    - pushing the branch
    - creating the draft PR

The engine only modifies the working tree.

"""

from __future__ import annotations

import argparse
import hashlib
import json
import logging
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple

import requests


# ============================================================================
# Logging
# ============================================================================

logging.basicConfig(
    level=logging.INFO,
    format="[VOIDONE-AI-ENGINE] %(asctime)s - %(levelname)s - %(message)s",
)

logger = logging.getLogger("VoidOneAIRepair")


# ============================================================================
# Constants
# ============================================================================

ENGINE_VERSION = "2.0.0"

MAX_LOG_CHARS = 20_000
MAX_FILE_CHARS = 12_000
MAX_CONTEXT_CHARS = 60_000

MAX_REFERENCED_FILES = 40
MAX_PATCH_CHARS = 120_000
MAX_PATCH_FILES = 25
MAX_PATCH_ADDED_LINES = 1_500
MAX_PATCH_REMOVED_LINES = 1_500

MAX_REPAIR_ATTEMPTS = 2

MIN_REPAIR_CONFIDENCE = 60
MIN_REVIEW_CONFIDENCE = 60

AI_REQUEST_TIMEOUT = 180
GEMINI_REQUEST_TIMEOUT = 150
PATCH_TIMEOUT = 60

PROTECTED_PATHS = (
    ".git/",
    "scripts/ai_repair.py",
    "scripts/requirements-ai-repair.txt",
)

ALLOWED_FILE_EXTENSIONS = {
    ".c",
    ".cc",
    ".cpp",
    ".cxx",
    ".h",
    ".hh",
    ".hpp",
    ".hxx",

    ".qml",
    ".qrc",
    ".ui",

    ".cmake",

    ".py",
    ".pyw",
    ".sh",
    ".bash",
    ".ps1",
    ".bat",
    ".cmd",

    ".yml",
    ".yaml",

    ".nsi",
    ".nsh",
    ".wxs",
    ".wxi",

    ".json",
    ".xml",
    ".rc",
    ".ini",
    ".cfg",
    ".conf",
    ".toml",

    ".txt",
    ".md",
}

ALLOWED_EXTENSIONLESS_FILES = {
    "CMakeLists.txt",
    "Makefile",
    "Dockerfile",
}

FORBIDDEN_PATCH_PATTERNS = (
    r"\bgit\s+push\b",
    r"\bgit\s+reset\b",
    r"\bgit\s+clean\b",
    r"\brm\s+-rf\b",
    r"\bmkfs\b",
    r"\bdd\s+if=",
    r"\bcurl\s+.*\|\s*(sh|bash)",
    r"\bwget\s+.*\|\s*(sh|bash)",
)

SECRET_PATTERNS = (
    r"(?i)api[_-]?key\s*[:=]\s*['\"][^'\"]{12,}['\"]",
    r"(?i)secret\s*[:=]\s*['\"][^'\"]{12,}['\"]",
    r"(?i)password\s*[:=]\s*['\"][^'\"]{8,}['\"]",
    r"(?i)private[_-]?key",
    r"-----BEGIN .* PRIVATE KEY-----",
    r"AIza[0-9A-Za-z_-]{20,}",
    r"ghp_[A-Za-z0-9]{30,}",
    r"github_pat_[A-Za-z0-9_]{20,}",
)

FAILURE_CATEGORIES = (
    "compile",
    "link",
    "cmake",
    "dependency",
    "test",
    "packaging",
    "workflow",
    "python",
    "qml",
    "unknown",
)


# ============================================================================
# Data models
# ============================================================================

@dataclass
class PatchMetrics:
    files: int = 0
    added_lines: int = 0
    removed_lines: int = 0
    patch_chars: int = 0


@dataclass
class RepairAttempt:
    attempt: int
    diagnosis: str = ""
    confidence: float = 0
    risk_score: float = 0
    patch_hash: str = ""
    patch_metrics: PatchMetrics = field(
        default_factory=PatchMetrics
    )
    build_passed: bool = False
    tests_passed: bool = False
    review_decision: str = ""
    review_confidence: float = 0
    review_reason: str = ""
    duration_seconds: float = 0
    success: bool = False
    failure_reason: str = ""


@dataclass
class RepairReport:
    engine_version: str
    repository: str
    failure_category: str
    attempts: List[RepairAttempt] = field(
        default_factory=list
    )
    final_status: str = "FAILED"
    final_reason: str = ""
    total_duration_seconds: float = 0
    generated_at: float = field(
        default_factory=time.time
    )


@dataclass(frozen=True)
class EnvironmentConfig:
    repo_dir: Path

    gemini_api_key: str
    gemini_model: str

    local_model_url: str
    local_model_name: str

    build_timeout: int
    test_timeout: int

    max_attempts: int
    min_repair_confidence: int
    min_review_confidence: int

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

            max_attempts=max(
                1,
                min(
                    int(
                        os.getenv(
                            "AI_REPAIR_MAX_ATTEMPTS",
                            str(MAX_REPAIR_ATTEMPTS),
                        )
                    ),
                    MAX_REPAIR_ATTEMPTS,
                ),
            ),

            min_repair_confidence=int(
                os.getenv(
                    "AI_REPAIR_MIN_CONFIDENCE",
                    str(MIN_REPAIR_CONFIDENCE),
                )
            ),

            min_review_confidence=int(
                os.getenv(
                    "AI_REPAIR_MIN_REVIEW_CONFIDENCE",
                    str(MIN_REVIEW_CONFIDENCE),
                )
            ),
        )


# ============================================================================
# Command execution
# ============================================================================

def run_command(
    command: List[str],
    cwd: Path,
    timeout: int,
) -> Tuple[int, str, str]:

    logger.info(
        "$ %s",
        " ".join(command),
    )

    process: Optional[subprocess.Popen[str]] = None

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

        if process is not None:
            process.kill()

            stdout, stderr = process.communicate()

        else:
            stdout = ""
            stderr = ""

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


# ============================================================================
# Path security
# ============================================================================

def normalize_repo_path(
    path: str,
) -> Optional[str]:

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

    return (
        Path(normalized)
        .suffix
        .lower()
        in ALLOWED_FILE_EXTENSIONS
    )


# ============================================================================
# Failure classification
# ============================================================================

def classify_failure(
    failure_log: str,
) -> str:

    text = failure_log.lower()

    rules = {
        "compile": (
            "compilation",
            "compile",
            "error:",
            "undeclared",
            "no member named",
            "fatal error",
        ),

        "link": (
            "undefined reference",
            "unresolved external",
            "linker",
            "ld returned",
        ),

        "cmake": (
            "cmake error",
            "cmake configure",
            "could not find",
            "configuration failed",
        ),

        "dependency": (
            "package not found",
            "dependency",
            "missing library",
            "could not find package",
        ),

        "test": (
            "ctest",
            "test failed",
            "assertion failed",
            "failed test",
        ),

        "packaging": (
            "nsis",
            "wix",
            "msi",
            "installer",
            "packaging",
        ),

        "workflow": (
            "github actions",
            "workflow",
            "setup-python",
            "actions/",
            "runner",
        ),

        "python": (
            "traceback",
            "python",
            "modulenotfounderror",
        ),

        "qml": (
            "qml",
            "qqml",
            "qtquick",
        ),
    }

    for category, keywords in rules.items():

        if any(
            keyword in text
            for keyword in keywords
        ):
            return category

    return "unknown"


# ============================================================================
# Repository context
# ============================================================================

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
            r"((?:\.github/)?"
            r"[A-Za-z0-9_.\-/]+/"
            r"(?:Dockerfile|Makefile))"
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
        "CTestTestfile.cmake",
    ]

    for filename in core_files:

        path = repo_dir / filename

        if not path.is_file():
            continue

        content = read_file_limited(path)

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

        content = read_file_limited(path)

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


# ============================================================================
# JSON extraction
# ============================================================================

def extract_json_object(
    text: str,
) -> Optional[Dict[str, Any]]:

    if not text:
        return None

    cleaned = text.strip()

    fenced_match = re.search(
        r"```(?:json)?\s*(.*?)\s*```",
        cleaned,
        flags=re.DOTALL | re.IGNORECASE,
    )

    if fenced_match:
        cleaned = fenced_match.group(1).strip()

    try:

        result = json.loads(cleaned)

        if isinstance(result, dict):
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

                except json.JSONDecodeError:
                    return None

    return None


# ============================================================================
# AI response validation
# ============================================================================

def validate_patch_response(
    response: Optional[Dict[str, Any]],
) -> bool:

    if not isinstance(
        response,
        dict,
    ):
        return False

    if response.get("status") != "PATCH":
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

    if not isinstance(
        diagnosis,
        str,
    ) or not diagnosis.strip():
        return False

    if not isinstance(
        patch,
        str,
    ) or not patch.strip():
        return False

    if not isinstance(
        confidence,
        (int, float),
    ):
        return False

    if not 0 <= confidence <= 100:
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

    return isinstance(
        reason,
        str,
    )


# ============================================================================
# Patch intelligence
# ============================================================================

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


def calculate_patch_metrics(
    patch: str,
) -> PatchMetrics:

    files = extract_patch_files(
        patch
    )

    added = 0
    removed = 0

    for line in patch.splitlines():

        if line.startswith("+++"):
            continue

        if line.startswith("---"):
            continue

        if line.startswith("+"):
            added += 1

        elif line.startswith("-"):
            removed += 1

    return PatchMetrics(
        files=len(files),
        added_lines=added,
        removed_lines=removed,
        patch_chars=len(patch),
    )


def patch_hash(
    patch: str,
) -> str:

    return hashlib.sha256(
        patch.encode("utf-8")
    ).hexdigest()


def calculate_risk_score(
    metrics: PatchMetrics,
    failure_category: str,
) -> float:

    score = 0.0

    score += min(
        metrics.files * 4,
        35,
    )

    score += min(
        metrics.added_lines / 50,
        25,
    )

    score += min(
        metrics.removed_lines / 50,
        20,
    )

    if failure_category in {
        "workflow",
        "packaging",
    }:
        score += 10

    if metrics.patch_chars > 50_000:
        score += 10

    return min(
        score,
        100,
    )


def validate_patch_security(
    repo_dir: Path,
    patch: str,
) -> Tuple[bool, str]:

    del repo_dir

    if not patch.strip():
        return False, "Empty patch."

    if len(patch) > MAX_PATCH_CHARS:
        return False, "Patch exceeds maximum size."

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

    if len(files) > MAX_PATCH_FILES:
        return (
            False,
            "Patch modifies too many files.",
        )

    metrics = calculate_patch_metrics(
        patch
    )

    if metrics.added_lines > MAX_PATCH_ADDED_LINES:
        return (
            False,
            "Patch adds too many lines.",
        )

    if metrics.removed_lines > MAX_PATCH_REMOVED_LINES:
        return (
            False,
            "Patch removes too many lines.",
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
                f"Protected path modification: {path}",
            )

        if not is_allowed_file_path(
            normalized
        ):
            return (
                False,
                f"Unexpected file type: {path}",
            )

    # Inspect only added content for dangerous commands.
    # Deleted historical lines should not cause a false rejection.
    added_content = "\n".join(
        line[1:]
        for line in patch.splitlines()
        if line.startswith("+")
        and not line.startswith("+++")
    )

    for pattern in FORBIDDEN_PATCH_PATTERNS:

        if re.search(
            pattern,
            added_content,
            flags=re.IGNORECASE,
        ):
            return (
                False,
                f"Suspicious command detected: {pattern}",
            )

    for pattern in SECRET_PATTERNS:

        if re.search(
            pattern,
            added_content,
        ):
            return (
                False,
                "Potential secret detected in patch.",
            )

    return (
        True,
        "Patch passed security validation.",
    )


# ============================================================================
# Patch application
# ============================================================================

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
            timeout=PATCH_TIMEOUT,
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
            timeout=PATCH_TIMEOUT,
        )

        if apply_code != 0:

            logger.error(
                "git apply failed:\n%s",
                apply_err,
            )

            return False

        return True

    finally:

        if (
            patch_path
            and patch_path.exists()
        ):
            patch_path.unlink(
                missing_ok=True
            )


# ============================================================================
# Git state
# ============================================================================

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
            f"Unable to read git status: {stderr}"
        )

    return [
        line
        for line in stdout.splitlines()
        if line.strip()
    ]


def rollback(
    repo_dir: Path,
) -> None:

    logger.warning(
        "Rolling back AI-generated changes."
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


# ============================================================================
# Build validation
# ============================================================================

def clean_build_directory(
    repo_dir: Path,
) -> None:

    build_dir = repo_dir / "build"

    if build_dir.exists():

        shutil.rmtree(
            build_dir,
            ignore_errors=True,
        )


def validate_build(
    config: EnvironmentConfig,
) -> Tuple[bool, bool, str]:

    repo_dir = config.repo_dir

    clean_build_directory(
        repo_dir
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

        return (
            False,
            False,
            (
                "CMake configuration failed:\n"
                f"{configure_out[-4000:]}\n"
                f"{configure_err[-4000:]}"
            ),
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

        return (
            False,
            False,
            (
                "Build failed:\n"
                f"{build_out[-4000:]}\n"
                f"{build_err[-4000:]}"
            ),
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

        return (
            True,
            False,
            (
                "CTest failed:\n"
                f"{test_out[-4000:]}\n"
                f"{test_err[-4000:]}"
            ),
        )

    return (
        True,
        True,
        "Build and tests passed.",
    )


# ============================================================================
# AI Client
# ============================================================================

class AIInferenceClient:

    def __init__(
        self,
        config: EnvironmentConfig,
    ):
        self.config = config

    # ------------------------------------------------------------------------
    # Gemini
    # ------------------------------------------------------------------------

    def query_gemini(
        self,
        failure_log: str,
        repo_context: str,
        category: str,
        previous_validation: str = "",
    ) -> Optional[Dict[str, Any]]:

        if not self.config.gemini_api_key:

            logger.warning(
                "GEMINI_API_KEY missing. "
                "Using local model."
            )

            return self.query_local(
                failure_log,
                repo_context,
                category,
                previous_validation,
                role="repair",
            )

        endpoint = (
            "https://generativelanguage.googleapis.com/"
            "v1beta/models/"
            f"{self.config.gemini_model}"
            ":generateContent"
        )

        prompt = self.build_repair_prompt(
            failure_log,
            repo_context,
            category,
            previous_validation,
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

        started = time.monotonic()

        try:

            response = requests.post(
                endpoint,
                params={
                    "key":
                        self.config.gemini_api_key,
                },
                json=payload,
                timeout=GEMINI_REQUEST_TIMEOUT,
            )

            logger.info(
                "Gemini request completed in %.2fs.",
                time.monotonic() - started,
            )

            if response.status_code != 200:

                logger.error(
                    "Gemini HTTP %s: %s",
                    response.status_code,
                    response.text[:1000],
                )

                return self.query_local(
                    failure_log,
                    repo_context,
                    category,
                    previous_validation,
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

        except Exception as exc:

            logger.error(
                "Gemini request failed: %s",
                exc,
            )

        return self.query_local(
            failure_log,
            repo_context,
            category,
            previous_validation,
            role="repair",
        )

    # ------------------------------------------------------------------------
    # Prompt
    # ------------------------------------------------------------------------

    def build_repair_prompt(
        self,
        failure_log: str,
        repo_context: str,
        category: str,
        previous_validation: str,
    ) -> str:

        return f"""
You are the principal CI reliability engineer for VoidOne.

VoidOne is a native C++23 / Qt6 PC gaming platform.

Your responsibility is to diagnose a CI failure and produce
the smallest safe production-quality patch that fixes the
actual root cause.

Failure category:
{category}

Engineering priorities:

1. Root-cause correctness
2. Minimal change surface
3. Maintainability
4. Security
5. Deterministic CI behavior
6. Backward compatibility
7. Test preservation

Allowed:

- C++
- headers
- QML
- CMake
- tests
- Python
- shell
- PowerShell
- GitHub Actions
- CI/CD configuration
- NSIS
- WiX
- configuration files
- build scripts

Protected:

- .git/
- scripts/ai_repair.py
- scripts/requirements-ai-repair.txt

Never:

- disable tests
- remove validation
- introduce telemetry
- introduce tracking
- introduce secrets
- hardcode credentials
- weaken security
- rewrite unrelated architecture
- modify Git metadata
- execute destructive commands
- install arbitrary software from the patch
- modify the AI repair engine

The patch must be a unified git diff.

If a safe repair cannot be determined, return NO_FIX.

Previous validation feedback:

{previous_validation or "None. This is the first repair attempt."}

Return ONLY JSON:

{{
  "status": "PATCH" | "NO_FIX",
  "diagnosis": "root cause",
  "confidence": 0-100,
  "files": ["file1", "file2"],
  "patch": "unified git diff"
}}

CI FAILURE:

{failure_log}

REPOSITORY CONTEXT:

{repo_context}
""".strip()

    # ------------------------------------------------------------------------
    # Local model
    # ------------------------------------------------------------------------

    def query_local(
        self,
        failure_log: str,
        repo_context: str,
        category: str,
        previous_validation: str,
        role: str,
        patch: str = "",
    ) -> Optional[Dict[str, Any]]:

        endpoint = (
            f"{self.config.local_model_url}"
            "/chat/completions"
        )

        if role == "review":

            prompt = f"""
You are the independent security reviewer for VoidOne.

Review this AI-generated CI repair.

Failure category:
{category}

Reject if the patch:

- modifies protected files
- contains path traversal
- adds secrets
- adds telemetry
- disables tests
- weakens security
- performs destructive operations
- contains unrelated changes
- does not address the failure
- is unnecessarily large
- is suspicious or unsafe

Protected:

.git/
scripts/ai_repair.py
scripts/requirements-ai-repair.txt

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

            prompt = self.build_repair_prompt(
                failure_log,
                repo_context,
                category,
                previous_validation,
            )

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
                timeout=AI_REQUEST_TIMEOUT,
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

        except Exception as exc:

            logger.error(
                "Local AI request failed: %s",
                exc,
            )

        return None


# ============================================================================
# Audit report
# ============================================================================

def write_report(
    report: RepairReport,
    repo_dir: Path,
) -> None:

    report_dir = repo_dir / ".voidone"

    report_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    report_path = (
        report_dir
        / "ai-repair-report.json"
    )

    report_path.write_text(
        json.dumps(
            asdict(report),
            indent=2,
            ensure_ascii=False,
        ),
        encoding="utf-8",
    )

    logger.info(
        "Repair audit report written to %s",
        report_path,
    )


# ============================================================================
# Main repair cycle
# ============================================================================

def perform_repair_attempt(
    config: EnvironmentConfig,
    client: AIInferenceClient,
    failure_log: str,
    repo_context: str,
    category: str,
    attempt_number: int,
    previous_validation: str,
) -> RepairAttempt:

    started = time.monotonic()

    attempt = RepairAttempt(
        attempt=attempt_number
    )

    repair = client.query_gemini(
        failure_log,
        repo_context,
        category,
        previous_validation,
    )

    if not validate_patch_response(
        repair
    ):

        attempt.failure_reason = (
            "AI did not produce a valid repair."
        )

        return attempt

    diagnosis = str(
        repair.get(
            "diagnosis",
            "",
        )
    )

    confidence = float(
        repair.get(
            "confidence",
            0,
        )
    )

    patch = str(
        repair.get(
            "patch",
            "",
        )
    )

    attempt.diagnosis = diagnosis
    attempt.confidence = confidence

    metrics = calculate_patch_metrics(
        patch
    )

    attempt.patch_metrics = metrics
    attempt.patch_hash = patch_hash(
        patch
    )

    attempt.risk_score = calculate_risk_score(
        metrics,
        category,
    )

    logger.info(
        "Repair confidence: %.1f",
        confidence,
    )

    logger.info(
        "Patch risk score: %.1f",
        attempt.risk_score,
    )

    if confidence < config.min_repair_confidence:

        attempt.failure_reason = (
            "Repair confidence below policy threshold."
        )

        return attempt

    if attempt.risk_score >= 80:

        attempt.failure_reason = (
            "Patch risk score exceeds safety threshold."
        )

        return attempt

    safe, reason = validate_patch_security(
        config.repo_dir,
        patch,
    )

    if not safe:

        attempt.failure_reason = (
            f"Security validation failed: {reason}"
        )

        return attempt

    if not apply_patch(
        config.repo_dir,
        patch,
    ):

        attempt.failure_reason = (
            "Patch application failed."
        )

        return attempt

    build_passed, tests_passed, validation_output = (
        validate_build(config)
    )

    attempt.build_passed = build_passed
    attempt.tests_passed = tests_passed

    if not build_passed or not tests_passed:

        attempt.failure_reason = validation_output

        rollback(
            config.repo_dir
        )

        attempt.duration_seconds = (
            time.monotonic() - started
        )

        return attempt

    applied_diff = git_diff(
        config.repo_dir
    )

    if not applied_diff.strip():

        attempt.failure_reason = (
            "No repository changes detected."
        )

        rollback(
            config.repo_dir
        )

        attempt.duration_seconds = (
            time.monotonic() - started
        )

        return attempt

    review = client.query_local(
        failure_log,
        repo_context,
        category,
        "",
        role="review",
        patch=applied_diff,
    )

    if not validate_review_response(
        review
    ):

        rollback(
            config.repo_dir
        )

        attempt.failure_reason = (
            "Independent AI review unavailable."
        )

        attempt.duration_seconds = (
            time.monotonic() - started
        )

        return attempt

    review_confidence = float(
        review.get(
            "confidence",
            0,
        )
    )

    decision = str(
        review.get(
            "decision",
            "REJECT",
        )
    )

    reason = str(
        review.get(
            "reason",
            "",
        )
    )

    attempt.review_decision = decision
    attempt.review_confidence = review_confidence
    attempt.review_reason = reason

    if (
        decision != "APPROVE"
        or review_confidence
        < config.min_review_confidence
    ):

        rollback(
            config.repo_dir
        )

        attempt.failure_reason = (
            "Independent reviewer rejected the patch."
        )

        attempt.duration_seconds = (
            time.monotonic() - started
        )

        return attempt

    attempt.success = True

    attempt.duration_seconds = (
        time.monotonic() - started
    )

    return attempt


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
            "Repository does not exist: %s",
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
    )[-MAX_LOG_CHARS:]

    if not failure_log.strip():

        logger.error(
            "CI failure log is empty."
        )

        return 1

    config = EnvironmentConfig.from_environment(
        repo_dir
    )

    initial_status = get_git_status(
        repo_dir
    )

    if initial_status:

        logger.error(
            "Repository is not clean before AI repair."
        )

        for line in initial_status:
            logger.error(
                "  %s",
                line,
            )

        return 1

    started = time.monotonic()

    category = classify_failure(
        failure_log
    )

    logger.info(
        "Failure category: %s",
        category,
    )

    repo_context = collect_repository_context(
        repo_dir,
        failure_log,
    )

    client = AIInferenceClient(
        config
    )

    report = RepairReport(
        engine_version=ENGINE_VERSION,
        repository=str(repo_dir),
        failure_category=category,
    )

    previous_validation = ""

    for attempt_number in range(
        1,
        config.max_attempts + 1,
    ):

        logger.info(
            "=================================================="
        )

        logger.info(
            "AI REPAIR ATTEMPT %d/%d",
            attempt_number,
            config.max_attempts,
        )

        logger.info(
            "=================================================="
        )

        attempt = perform_repair_attempt(
            config,
            client,
            failure_log,
            repo_context,
            category,
            attempt_number,
            previous_validation,
        )

        report.attempts.append(
            attempt
        )

        if attempt.success:

            report.final_status = "SUCCESS"

            report.final_reason = (
                "Repair generated, validated, "
                "built, tested and independently reviewed."
            )

            break

        previous_validation = (
            attempt.failure_reason
        )

        logger.warning(
            "Attempt %d failed: %s",
            attempt_number,
            attempt.failure_reason,
        )

    report.total_duration_seconds = (
        time.monotonic() - started
    )

    write_report(
        report,
        repo_dir,
    )

    if report.final_status == "SUCCESS":

        logger.info(
            "=================================================="
        )

        logger.info(
            "VOIDONE AI REPAIR SUCCESS"
        )

        logger.info(
            "Engine version: %s",
            ENGINE_VERSION,
        )

        logger.info(
            "Failure category: %s",
            category,
        )

        logger.info(
            "Attempts: %d",
            len(report.attempts),
        )

        logger.info(
            "Duration: %.2fs",
            report.total_duration_seconds,
        )

        logger.info(
            "Build: PASSED"
        )

        logger.info(
            "Tests: PASSED"
        )

        logger.info(
            "Independent review: APPROVED"
        )

        logger.info(
            "=================================================="
        )

        return 0

    logger.error(
        "=================================================="
    )

    logger.error(
        "VOIDONE AI REPAIR FAILED"
    )

    logger.error(
        "Failure category: %s",
        category,
    )

    logger.error(
        "Attempts: %d",
        len(report.attempts),
    )

    logger.error(
        "Reason: %s",
        report.final_reason or (
            report.attempts[-1].failure_reason
            if report.attempts
            else "Unknown"
        ),
    )

    logger.error(
        "=================================================="
    )

    return 1


if __name__ == "__main__":
    sys.exit(
        main()
    )