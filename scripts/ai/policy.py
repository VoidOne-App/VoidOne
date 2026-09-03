from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
from typing import Iterable


@dataclass(frozen=True)
class Policy:
    protected: tuple[str, ...]
    allowed_suffixes: tuple[str, ...]
    max_files: int = 20
    max_added: int = 800
    max_removed: int = 800
    max_chars: int = 100000

    @classmethod
    def load(cls, root: Path) -> "Policy":
        protected = [".git/", ".ai/", "scripts/ai/", "scripts/validation/", "scripts/reporting/"]
        path = root / "forbidden-files.yml"
        if path.is_file():
            for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
                m = re.match(r"\s*-\s*[\"']?([^\"']+)[\"']?\s*$", line)
                if m:
                    protected.append(m.group(1).replace("\\", "/"))
        suffixes = (".cpp", ".cc", ".cxx", ".c", ".h", ".hpp", ".qml", ".cmake", ".py", ".ps1", ".sh", ".yml", ".yaml", ".nsi", ".nsh", ".wxs", ".wxi", ".json", ".xml", ".ini", ".toml", ".md", ".txt")
        return cls(tuple(dict.fromkeys(protected)), suffixes)

    def is_protected(self, path: str) -> bool:
        p = path.replace("\\", "/").lstrip("./")
        return any(p == x.rstrip("/") or p.startswith(x.rstrip("/") + "/") for x in self.protected)


def _paths(patch: str) -> list[str]:
    paths: set[str] = set()
    for line in patch.splitlines():
        if line.startswith(("+++ b/", "--- a/")):
            p = line[6:] if line.startswith("+++ b/") else line[6:]
            if p != "/dev/null":
                paths.add(p.replace("\\", "/"))
    return sorted(paths)


def validate_patch(repo: Path, patch: str, policy: Policy) -> tuple[bool, str]:
    del repo
    if not patch.strip():
        return False, "Empty patch."
    if len(patch) > policy.max_chars:
        return False, "Patch exceeds size policy."
    if "\x00" in patch or "--- a/" not in patch or "+++ b/" not in patch:
        return False, "Patch is not a valid unified diff."
    paths = _paths(patch)
    if not paths:
        return False, "No changed files detected."
    if len(paths) > policy.max_files:
        return False, "Patch changes too many files."
    added = [x[1:] for x in patch.splitlines() if x.startswith("+") and not x.startswith("+++")]
    removed = [x[1:] for x in patch.splitlines() if x.startswith("-") and not x.startswith("---")]
    if len(added) > policy.max_added or len(removed) > policy.max_removed:
        return False, "Patch exceeds line-change policy."
    dangerous = (r"\bgit\s+push\b", r"\bgit\s+reset\b", r"\bgit\s+clean\b", r"\brm\s+-rf\b", r"\bmkfs\b", r"\bdd\s+if=", r"curl\s+.*\|\s*(sh|bash)", r"wget\s+.*\|\s*(sh|bash)")
    added_text = "\n".join(added)
    for path in paths:
        if path.startswith("/") or ".." in Path(path).parts or policy.is_protected(path):
            return False, f"Protected or unsafe path: {path}"
        if Path(path).suffix.lower() not in policy.allowed_suffixes and Path(path).name not in {"CMakeLists.txt", "Dockerfile", "Makefile"}:
            return False, f"Unexpected file type: {path}"
    for pattern in dangerous:
        if re.search(pattern, added_text, re.I):
            return False, f"Suspicious command in patch: {pattern}"
    secrets = (r"AIza[0-9A-Za-z_-]{20,}", r"ghp_[A-Za-z0-9]{30,}", r"github_pat_[A-Za-z0-9_]{20,}", r"-----BEGIN .* PRIVATE KEY-----", r"(?i)password\s*[:=]\s*['\"][^'\"]{8,}")
    if any(re.search(p, added_text) for p in secrets):
        return False, "Potential credential material detected."
    return True, f"Patch policy passed for {len(paths)} file(s)."
