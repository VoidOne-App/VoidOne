from __future__ import annotations

from pathlib import Path
import re

DANGEROUS = (
    r"curl\s+[^\n]*\|\s*(?:sh|bash)",
    r"wget\s+[^\n]*\|\s*(?:sh|bash)",
    r"git\s+push\s+--force",
    r"git\s+reset\s+--hard\s+HEAD",
    r"chmod\s+777",
)


def validate_workflow(repo: Path) -> tuple[bool, str]:
    root = repo / ".github" / "workflows"
    if not root.is_dir():
        return False, "Missing .github/workflows directory."
    files = sorted(root.glob("*.yml")) + sorted(root.glob("*.yaml"))
    if not files:
        return False, "No workflow files found."
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        if not re.search(r"^(?:'on'|on):", text, re.M):
            return False, f"Workflow has no trigger: {path.relative_to(repo)}"
        for pattern in DANGEROUS:
            if re.search(pattern, text, re.I):
                return False, f"Suspicious workflow command in {path.relative_to(repo)}"
        if "permissions:" in text and re.search(r"contents:\s+write", text):
            # Write access is permitted only in the dedicated AI repair workflow,
            # whose purpose is to publish a candidate branch/PR.
            if path.name != "ai-repair.yml":
                return False, f"Unexpected contents: write permission in {path.relative_to(repo)}"
    ci = next((p for p in files if re.search(r"^name:\s*VoidOne CI/CD\s*$", p.read_text(encoding="utf-8", errors="replace"), re.M)), None)
    if ci is None:
        return False, "Authoritative VoidOne CI/CD workflow not found."
    text = ci.read_text(encoding="utf-8", errors="replace")
    required = ("actions/checkout@", "ilammy/msvc-dev-cmd@", "jurplel/install-qt-action@", "windeployqt", "actions/upload-artifact@v4")
    missing = [marker for marker in required if marker not in text]
    if missing:
        return False, "Authoritative CI missing: " + ", ".join(missing)
    if "runs-on: windows-2025" not in text:
        return False, "Authoritative Windows CI must use windows-2025."
    if "id-token: write" in text and "attestations: write" not in text:
        return False, "OIDC build attestation permission is incomplete."
    return True, f"Validated {len(files)} workflow file(s)."
