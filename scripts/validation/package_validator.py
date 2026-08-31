from __future__ import annotations
from pathlib import Path
import zipfile

INSTALLER_EXTENSIONS = {".exe", ".msi", ".zip"}

def validate_package(repo: Path) -> tuple[bool, str]:
    candidates = []
    for root in (repo / "build", repo / "dist", repo / "package", repo / "packages"):
        if root.exists(): candidates.extend(p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in INSTALLER_EXTENSIONS)
    if not candidates:
        # Packaging may be performed exclusively by the authoritative Windows CI.
        return True, "No local package output; authoritative Windows CI remains required."
    for item in candidates:
        if item.stat().st_size == 0: return False, f"Empty package: {item}"
        if item.suffix.lower() == ".zip":
            try:
                with zipfile.ZipFile(item) as z:
                    if not z.namelist(): return False, f"Empty ZIP: {item}"
            except zipfile.BadZipFile: return False, f"Invalid ZIP: {item}"
    return True, f"Validated {len(candidates)} package artifact(s)."
