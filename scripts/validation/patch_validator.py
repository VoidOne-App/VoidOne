from __future__ import annotations
from pathlib import Path
import re
from scripts.ai.policy import Policy

FORBIDDEN = (r"\bgit\s+(push|reset|clean)\b", r"\brm\s+-rf\b", r"curl\s+.*\|\s*(sh|bash)", r"wget\s+.*\|\s*(sh|bash)")

def validate_patch(repo: Path, patch: str, policy: Policy) -> tuple[bool, str]:
    if not patch.strip() or len(patch) > 120_000: return False, "Invalid or oversized patch."
    if "--- a/" not in patch or "+++ b/" not in patch: return False, "Not a unified diff."
    files = re.findall(r"^\+\+\+ b/(.+)$", patch, re.M)
    if not files or len(files) > 25: return False, "Invalid file count."
    if any(".." in Path(f).parts or not policy.allowed_path(f) for f in files): return False, "Policy rejected modified path."
    added = "\n".join(x[1:] for x in patch.splitlines() if x.startswith("+") and not x.startswith("+++"))
    if any(re.search(p, added, re.I) for p in FORBIDDEN): return False, "Dangerous command detected."
    if re.search(r"(?i)(AIza[0-9A-Za-z_-]{20,}|ghp_[A-Za-z0-9]{30,}|BEGIN .* PRIVATE KEY|api[_-]?key\s*[:=])", added): return False, "Potential secret detected."
    return True, "Patch accepted by policy and static checks."
