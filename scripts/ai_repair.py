#!/usr/bin/env python3

import os
import re
import subprocess
import sys
from pathlib import Path

import requests


REPO = Path.cwd()
API_KEY = os.environ.get("GEMINI_API_KEY")
MODEL = os.environ.get("GEMINI_MODEL", "gemini-3.1-pro-preview")

MAX_CONTEXT_FILE_SIZE = 120_000
MAX_LOG_SIZE = 80_000

# AI is NOT allowed to modify these paths.
DENY_PREFIXES = (
    ".github/",
    ".git/",
    "scripts/ai_repair.py",
)

# Keep automatic repairs focused.
ALLOWED_EXTENSIONS = {
    ".cpp",
    ".hpp",
    ".h",
    ".cc",
    ".cxx",
    ".qml",
    ".js",
    ".cmake",
    ".txt",
}

IMPORTANT_FILES = [
    "CMakeLists.txt",
    "README.md",
    "BUILD.md",
    "TROUBLESHOOTING.md",
]


def run(cmd, check=True, capture=True):
    print(f"+ {' '.join(cmd)}")

    result = subprocess.run(
        cmd,
        cwd=REPO,
        text=True,
        capture_output=capture,
    )

    if check and result.returncode != 0:
        if capture:
            print(result.stdout)
            print(result.stderr, file=sys.stderr)
        raise RuntimeError(
            f"Command failed with exit code {result.returncode}: {' '.join(cmd)}"
        )

    return result


def read_text(path):
    try:
        data = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""

    if len(data) > MAX_CONTEXT_FILE_SIZE:
        return data[:MAX_CONTEXT_FILE_SIZE] + "\n...[TRUNCATED]..."

    return data


def collect_repository_context(log):
    context = []

    for name in IMPORTANT_FILES:
        path = REPO / name
        if path.exists():
            context.append(
                f"\n===== {name} =====\n{read_text(path)}"
            )

    # Extract file paths mentioned in compiler/build errors.
    candidates = set(
        re.findall(
            r"(?:^|\s)((?:src|tests|include|qml)/[A-Za-z0-9_./+-]+\.(?:cpp|hpp|h|cc|cxx|qml|js))",
            log,
        )
    )

    for candidate in candidates:
        path = REPO / candidate

        if not path.exists():
            continue

        if path.suffix.lower() not in ALLOWED_EXTENSIONS:
            continue

        context.append(
            f"\n===== {candidate} =====\n{read_text(path)}"
        )

    return "\n".join(context)


def get_failed_log():
    path = REPO / "ci-failure-tail.log"

    if path.exists():
        data = read_text(path)
    else:
        data = "No CI failure log was supplied."

    return data[-MAX_LOG_SIZE:]


def build_prompt(log, context):
    return f"""
You are the senior repair engineer for the VoidOne project.

Project:
- C++23
- Qt 6.8
- QML
- CMake
- Ninja
- Linux and Windows CI
- Unit tests
- AddressSanitizer / UndefinedBehaviorSanitizer
- clang-tidy/static analysis

Your task is to repair ONE real CI failure.

STRICT RULES:

1. Diagnose the actual failure before changing anything.
2. Make the smallest possible production-quality fix.
3. Do NOT refactor unrelated code.
4. Do NOT rewrite files unnecessarily.
5. Do NOT remove tests.
6. Do NOT weaken tests.
7. Do NOT disable sanitizers.
8. Do NOT disable static analysis.
9. Do NOT modify GitHub Actions workflows.
10. Do NOT modify this AI repair agent.
11. Do NOT modify CI configuration merely to hide the failure.
12. Do NOT change dependency versions unless the log proves that this is the actual cause.
13. Preserve existing architecture and coding style.
14. Preserve Qt/QML behavior.
15. Prefer fixing the root cause rather than suppressing the symptom.
16. Never invent APIs, classes, functions, or files.
17. If the evidence is insufficient, return NO_PATCH.
18. The patch MUST be a unified diff.
19. Only modify source/configuration files directly required to fix the failure.
20. Do not include explanations outside the requested format.

OUTPUT FORMAT:

PATCH:
```diff
<minimal unified diff>
