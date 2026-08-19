#!/usr/bin/env python3

import json
import os
import re
import subprocess
import sys
from pathlib import Path

import requests


# ============================================================
# Configuration
# ============================================================

REPO = Path.cwd()

API_KEY = os.environ.get("GEMINI_API_KEY")
MODEL = os.environ.get(
    "GEMINI_MODEL",
    "gemini-3.1-pro-preview",
)

API_URL = (
    f"https://generativelanguage.googleapis.com/"
    f"v1beta/models/{MODEL}:generateContent"
)

MAX_CONTEXT_FILE_SIZE = 120_000
MAX_LOG_SIZE = 80_000
MAX_DIFF_SIZE = 120_000


# ============================================================
# Safety boundaries
# ============================================================

DENY_PREFIXES = (
    ".github/",
    ".git/",
    "scripts/ai_repair.py",
)

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

IMPORTANT_FILES = (
    "CMakeLists.txt",
    "README.md",
    "BUILD.md",
    "TROUBLESHOOTING.md",
)


# ============================================================
# Command helper
# ============================================================

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
            if result.stdout:
                print(result.stdout)

            if result.stderr:
                print(result.stderr, file=sys.stderr)

        raise RuntimeError(
            "Command failed with exit code "
            f"{result.returncode}: {' '.join(cmd)}"
        )

    return result


# ============================================================
# File helpers
# ============================================================

def read_text(path: Path) -> str:
    try:
        data = path.read_text(
            encoding="utf-8",
            errors="replace",
        )
    except Exception:
        return ""

    if len(data) > MAX_CONTEXT_FILE_SIZE:
        return (
            data[:MAX_CONTEXT_FILE_SIZE]
            + "\n...[TRUNCATED]..."
        )

    return data


def normalize_path(path: str) -> str:
    path = path.strip()
    path = path.replace("\\", "/")

    while path.startswith("./"):
        path = path[2:]

    return path


def is_denied(path: str) -> bool:
    path = normalize_path(path)

    return any(
        path == prefix.rstrip("/")
        or path.startswith(prefix)
        for prefix in DENY_PREFIXES
    )


def is_allowed_source(path: str) -> bool:
    path = normalize_path(path)

    if not path:
        return False

    if is_denied(path):
        return False

    suffix = Path(path).suffix.lower()

    return suffix in ALLOWED_EXTENSIONS


# ============================================================
# Repository context
# ============================================================

def extract_referenced_files(log: str):
    patterns = [
        r"(?:^|\s)((?:src|tests|include|qml)/[^\s:'\"]+)",
        r"(?:^|\s)((?:src|tests|include|qml)/[A-Za-z0-9_./+\-]+\.(?:cpp|hpp|h|cc|cxx|qml|js))",
    ]

    found = set()

    for pattern in patterns:
        for match in re.findall(pattern, log):
            if isinstance(match, tuple):
                match = match[0]

            path = normalize_path(match)

            # Remove common compiler punctuation.
            path = path.rstrip("),;:'\"")

            if is_allowed_source(path):
                found.add(path)

    return sorted(found)


def collect_repository_context(log: str) -> str:
    context = []

    # Important project files.
    for name in IMPORTANT_FILES:
        path = REPO / name

        if path.exists() and path.is_file():
            context.append(
                f"\n===== {name} =====\n"
                f"{read_text(path)}"
            )

    # Files referenced by CI errors.
    for candidate in extract_referenced_files(log):
        path = REPO / candidate

        if not path.exists():
            continue

        if not path.is_file():
            continue

        if not is_allowed_source(candidate):
            continue

        context.append(
            f"\n===== {candidate} =====\n"
            f"{read_text(path)}"
        )

    return "\n".join(context)


# ============================================================
# CI log
# ============================================================

def get_failed_log() -> str:
    path = REPO / "ci-failure-tail.log"

    if not path.exists():
        return "No CI failure log was supplied."

    data = read_text(path)

    if len(data) > MAX_LOG_SIZE:
        data = data[-MAX_LOG_SIZE:]

    return data


# ============================================================
# Prompt
# ============================================================

def build_prompt(log: str, context: str) -> str:
    return f"""
You are the senior repair engineer for the VoidOne project.

PROJECT
-------
VoidOne is a C++/Qt application.

Known stack:
- C++
- Qt 6.8
- QML
- CMake
- Ninja
- Linux CI
- Windows CI
- Unit tests
- clang-tidy
- AddressSanitizer
- UndefinedBehaviorSanitizer

MISSION
-------
Repair ONE real CI failure.

Your job is to identify the root cause from the supplied CI evidence
and generate the smallest safe production-quality patch.

STRICT RULES
------------
1. Diagnose the actual failure before proposing a change.
2. Fix the root cause, not merely the visible symptom.
3. Make the smallest reasonable change.
4. Do not perform unrelated refactoring.
5. Do not rewrite complete files unnecessarily.
6. Do not remove tests.
7. Do not weaken tests.
8. Do not disable sanitizers.
9. Do not disable clang-tidy or static analysis.
10. Do not modify GitHub Actions workflows.
11. Do not modify this AI repair agent.
12. Do not modify files under .github/.
13. Do not modify files under .git/.
14. Do not modify scripts/ai_repair.py.
15. Do not change dependency versions unless the CI evidence clearly
    proves that dependency resolution is the root cause.
16. Preserve existing architecture.
17. Preserve existing coding style.
18. Preserve Qt/QML behavior.
19. Never invent APIs, classes, functions, variables, or files.
20. Only modify files directly required for the fix.
21. If the evidence is insufficient, return NO_PATCH.
22. Never generate a patch for an unrelated problem.
23. The patch must apply cleanly to the supplied repository state.
24. The patch must be a unified git diff.
25. Do not include Markdown fences inside the patch field.
26. Do not include explanatory prose inside the patch field.

IMPORTANT
---------
The repository state supplied to you is the exact state being repaired.

You must reason from:
1. CI failure log
2. Repository context
3. Existing source code

Do not assume files or APIs that are not present.

FAILED CI LOG
-------------
{log}

REPOSITORY CONTEXT
------------------
{context}
"""


# ============================================================
# Gemini request
# ============================================================

def call_gemini(prompt: str) -> dict:
    if not API_KEY:
        raise RuntimeError(
            "GEMINI_API_KEY is not set."
        )

    schema = {
        "type": "object",
        "properties": {
            "status": {
                "type": "string",
                "enum": [
                    "PATCH",
                    "NO_PATCH",
                ],
                "description": (
                    "PATCH if a safe repair is supported by "
                    "the evidence, otherwise NO_PATCH."
                ),
            },
            "reason": {
                "type": "string",
                "description": (
                    "Short technical diagnosis of the CI failure."
                ),
            },
            "patch": {
                "type": "string",
                "description": (
                    "Minimal unified git diff. Empty when status "
                    "is NO_PATCH."
                ),
            },
        },
        "required": [
            "status",
            "reason",
            "patch",
        ],
        "additionalProperties": False,
    }

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
            "responseMimeType": "application/json",
            "responseSchema": schema,
            "thinkingConfig": {
                "thinkingLevel": "high",
            },
        },
    }

    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": API_KEY,
    }

    print()
    print("========================================")
    print("Calling Gemini")
    print(f"Model: {MODEL}")
    print("========================================")

    response = requests.post(
        API_URL,
        headers=headers,
        json=payload,
        timeout=600,
    )

    if response.status_code != 200:
        print("Gemini API response:")
        print(response.text)

        raise RuntimeError(
            f"Gemini API request failed: "
            f"HTTP {response.status_code}"
        )

    try:
        body = response.json()
    except json.JSONDecodeError as exc:
        raise RuntimeError(
            "Gemini returned invalid JSON."
        ) from exc

    try:
        text = body["candidates"][0]["content"]["parts"][0]["text"]
    except (KeyError, IndexError, TypeError) as exc:
        print(json.dumps(body, indent=2))
        raise RuntimeError(
            "Gemini response did not contain expected content."
        ) from exc

    try:
        result = json.loads(text)
    except json.JSONDecodeError as exc:
        print("Gemini text:")
        print(text)

        raise RuntimeError(
            "Gemini structured output was not valid JSON."
        ) from exc

    return result


# ============================================================
# Patch extraction
# ============================================================

def clean_patch(patch: str) -> str:
    patch = patch.strip()

    # Be tolerant if the model accidentally included fences.
    if patch.startswith("```"):
        lines = patch.splitlines()

        if lines and lines[0].strip().startswith("```"):
            lines = lines[1:]

        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]

        patch = "\n".join(lines).strip()

    return patch


def validate_patch_text(patch: str):
    if not patch:
        raise RuntimeError(
            "Gemini returned an empty patch."
        )

    if len(patch) > MAX_DIFF_SIZE:
        raise RuntimeError(
            "Gemini patch is unexpectedly large."
        )

    if "diff --git " not in patch:
        raise RuntimeError(
            "Generated output is not a git unified diff."
        )

    # Basic safety check before git even sees the patch.
    changed_paths = []

    for line in patch.splitlines():
        if line.startswith("+++ b/"):
            changed_paths.append(
                normalize_path(line[6:])
            )

        elif line.startswith("--- a/"):
            changed_paths.append(
                normalize_path(line[6:])
            )

    if not changed_paths:
        raise RuntimeError(
            "Could not determine files modified by patch."
        )

    unique_paths = sorted(set(changed_paths))

    print()
    print("Patch files:")

    for path in unique_paths:
        print(f"  - {path}")

        if is_denied(path):
            raise RuntimeError(
                f"Patch attempts to modify denied path: {path}"
            )

        if not is_allowed_source(path):
            raise RuntimeError(
                f"Patch attempts to modify unsupported file: {path}"
            )


# ============================================================
# Apply patch safely
# ============================================================

def apply_patch(patch: str):
    patch_file = REPO / ".ai-repair.patch"

    try:
        patch_file.write_text(
            patch,
            encoding="utf-8",
        )

        print()
        print("========================================")
        print("Checking patch")
        print("========================================")

        run(
            [
                "git",
                "apply",
                "--check",
                "--whitespace=error",
                str(patch_file),
            ]
        )

        print()
        print("Patch check passed.")

        run(
            [
                "git",
                "apply",
                "--whitespace=error",
                str(patch_file),
            ]
        )

    finally:
        try:
            patch_file.unlink()
        except FileNotFoundError:
            pass


# ============================================================
# Verify resulting tree
# ============================================================

def verify_changes():
    print()
    print("========================================")
    print("Verifying repository changes")
    print("========================================")

    result = run(
        [
            "git",
            "status",
            "--short",
        ]
    )

    if not result.stdout.strip():
        raise RuntimeError(
            "Patch applied successfully but produced no "
            "working-tree changes."
        )

    print(result.stdout)

    diff_check = run(
        [
            "git",
            "diff",
            "--check",
        ]
    )

    if diff_check.stdout:
        print(diff_check.stdout)

    diff = run(
        [
            "git",
            "diff",
            "--stat",
        ]
    )

    if diff.stdout:
        print(diff.stdout)

    # Never allow the agent to modify itself or CI files,
    # even if something unexpected happened.
    changed = run(
        [
            "git",
            "diff",
            "--name-only",
        ]
    )

    for raw_path in changed.stdout.splitlines():
        path = normalize_path(raw_path)

        if is_denied(path):
            raise RuntimeError(
                f"Safety violation: modified denied path: {path}"
            )

        if not is_allowed_source(path):
            raise RuntimeError(
                f"Safety violation: modified unsupported path: {path}"
            )


# ============================================================
# Main
# ============================================================

def main():
    print("========================================")
    print("VoidOne AI Repair Agent")
    print("========================================")
    print(f"Model: {MODEL}")
    print(f"Repository: {REPO}")

    log = get_failed_log()

    if not log.strip():
        raise RuntimeError(
            "CI failure log is empty."
        )

    print()
    print("Collecting repository context...")

    context = collect_repository_context(log)

    print(
        f"Collected approximately "
        f"{len(context):,} context characters."
    )

    prompt = build_prompt(
        log=log,
        context=context,
    )

    result = call_gemini(prompt)

    status = str(
        result.get("status", "")
    ).strip().upper()

    reason = str(
        result.get("reason", "")
    ).strip()

    patch = clean_patch(
        str(
            result.get("patch", "")
        )
    )

    print()
    print("========================================")
    print("Gemini diagnosis")
    print("========================================")
    print(reason or "No diagnosis supplied.")

    if status == "NO_PATCH":
        print()
        print(
            "Gemini determined that there is not enough "
            "evidence for a safe automatic repair."
        )
        return 2

    if status != "PATCH":
        raise RuntimeError(
            f"Unexpected Gemini status: {status!r}"
        )

    validate_patch_text(patch)

    print()
    print("========================================")
    print("Applying validated patch")
    print("========================================")

    apply_patch(patch)

    verify_changes()

    print()
    print("========================================")
    print("AI REPAIR PATCH APPLIED SUCCESSFULLY")
    print("========================================")

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())

    except KeyboardInterrupt:
        print(
            "\nInterrupted.",
            file=sys.stderr,
        )
        sys.exit(130)

    except Exception as exc:
        print(
            f"\nAI repair failed: {exc}",
            file=sys.stderr,
        )
        sys.exit(1)