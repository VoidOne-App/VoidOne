from __future__ import annotations

from pathlib import Path
import re


def validate_workflow(repo: Path) -> tuple[bool, str]:
    root = repo / ".github" / "workflows"
    if not root.is_dir():
        return False, "Missing .github/workflows directory."
    files = sorted(root.glob("*.y*ml"))
    if not files:
        return False, "No workflow files found."
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        if re.search(r"^on:", text, re.M) is None:
            return False, f"Workflow has no trigger: {path.relative_to(repo)}"
        for pattern in (r"curl\s+.*\|\s*(sh|bash)", r"wget\s+.*\|\s*(sh|bash)", r"git\s+push\s+--force", r"chmod\s+777"):
            if re.search(pattern, text, re.I):
                return False, f"Suspicious workflow command: {path.relative_to(repo)}"
    ci = next((p for p in files if "VoidOne CI/CD" in p.read_text(encoding="utf-8", errors="replace")), None)
    if ci is None:
        return False, "Authoritative VoidOne CI/CD workflow not found."
    text = ci.read_text(encoding="utf-8", errors="replace")
    for marker in ("actions/checkout@", "ilammy/msvc-dev-cmd@", "jurplel/install-qt-action@", "windeployqt", "actions/upload-artifact@"):
        if marker not in text:
            return False, f"Authoritative CI missing: {marker}"
    return True, f"Validated {len(files)} workflow file(s)."
