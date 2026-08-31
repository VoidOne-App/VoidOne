from __future__ import annotations

from pathlib import Path
import zipfile
import xml.etree.ElementTree as ET

PACKAGE_ROOTS = ("package", "dist", "build", "packages")
ARTIFACT_EXTENSIONS = {".exe", ".msi", ".zip"}


def _artifacts(repo: Path):
    for name in PACKAGE_ROOTS:
        root = repo / name
        if root.is_dir():
            yield from (p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in ARTIFACT_EXTENSIONS)


def validate_package(repo: Path) -> tuple[bool, str]:
    wix = repo / "installer.wxs"
    if wix.is_file():
        try:
            root = ET.parse(wix).getroot()
        except ET.ParseError as exc:
            return False, f"Invalid WiX XML: {exc}"
        if not root.tag.endswith("Wix"):
            return False, "installer.wxs has an invalid root element."

    artifacts = list(_artifacts(repo))
    if not artifacts:
        return True, "No local package artifacts; authoritative Windows CI is required."

    for item in artifacts:
        if item.stat().st_size == 0:
            return False, f"Empty package: {item}"
        if item.suffix.lower() == ".zip":
            try:
                with zipfile.ZipFile(item) as archive:
                    names = archive.namelist()
                    if not names:
                        return False, f"Empty ZIP: {item}"
                    if any(name.startswith(("/", "\\")) or ".." in Path(name).parts for name in names):
                        return False, f"Unsafe ZIP entry in {item}"
            except zipfile.BadZipFile:
                return False, f"Invalid ZIP: {item}"

    return True, f"Validated {len(artifacts)} package artifact(s)."
