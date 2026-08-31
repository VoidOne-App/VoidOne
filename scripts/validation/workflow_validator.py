from __future__ import annotations
from pathlib import Path
import re

DANGEROUS = (r"curl\s+.*\|\s*(sh|bash)", r"wget\s+.*\|\s*(sh|bash)", r"git\s+push\s+--force", r"chmod\s+777")

def validate_workflow(repo: Path) -> tuple[bool, str]:
    root = repo / ".github" / "workflows"
    if not root.is_dir(): return True, "No workflow directory found."
    files = list(root.glob("*.yml")) + list(root.glob("*.yaml"))
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        if "permissions:" not in text: return False, f"Workflow lacks explicit permissions: {path.relative_to(repo)}"
        for pattern in DANGEROUS:
            if re.search(pattern, text, re.I): return False, f"Suspicious workflow command in {path.relative_to(repo)}"
    return True, f"Validated {len(files)} workflow file(s)."
