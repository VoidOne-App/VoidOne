from __future__ import annotations

from pathlib import Path
import zipfile
import xml.etree.ElementTree as ET


def validate_package(repo: Path) -> tuple[bool, str]:
    installer_sources = list(repo.rglob("*.nsi")) + list(repo.rglob("*.nsh")) + list(repo.rglob("*.wxs")) + list(repo.rglob("*.wxi")) + list(repo.rglob("*.wixproj"))
    for p in installer_sources:
        text = p.read_text(encoding="utf-8", errors="replace")
        if p.suffix.lower() in {".wxs", ".wxi"}:
            try:
                ET.parse(p)
            except ET.ParseError as exc:
                return False, f"Invalid WiX XML: {p.relative_to(repo)}: {exc}"
        if "package\\*" in text.lower() and not (repo / ".github" / "workflows" / "c.cpp.yml").is_file():
            return False, f"Installer expects CI staging but authoritative workflow is missing: {p.relative_to(repo)}"
    artifacts = []
    for root_name in ("package", "dist", "packages", "artifacts"):
        root = repo / root_name
        if root.is_dir():
            artifacts.extend(p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in {".exe", ".msi", ".zip"})
    for p in artifacts:
        if p.stat().st_size <= 0:
            return False, f"Empty package artifact: {p.relative_to(repo)}"
        if p.suffix.lower() == ".zip":
            try:
                with zipfile.ZipFile(p) as z:
                    names = z.namelist()
                    if not names:
                        return False, f"Empty ZIP: {p.relative_to(repo)}"
                    if any(n.startswith(("/", "\\")) or ".." in Path(n).parts for n in names):
                        return False, f"Unsafe ZIP entry in {p.relative_to(repo)}"
            except zipfile.BadZipFile:
                return False, f"Invalid ZIP: {p.relative_to(repo)}"
    workflow = repo / ".github" / "workflows" / "c.cpp.yml"
    if workflow.is_file():
        text = workflow.read_text(encoding="utf-8", errors="replace")
        for marker in ("windeployqt", "actions/upload-artifact@v4"):
            if marker not in text:
                return False, f"Packaging contract missing: {marker}"
    return True, f"Package contract passed: {len(installer_sources)} installer source(s), {len(artifacts)} local artifact(s)."
