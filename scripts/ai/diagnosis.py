from __future__ import annotations
from pathlib import Path
import re

CATEGORIES = ("workflow", "packaging", "installer", "deployment", "artifact", "qml", "cmake", "link", "compile", "test", "python", "unknown")
RULES = {
    "workflow": (r"\.github/workflows/", "workflow", "actions/", "runner", "github actions", "yaml"),
    "packaging": ("packaging", "package", "artifact", "zip", "msi", "nsis", "wix"),
    "installer": ("installer", "nsis", "makensis", "wix", "light.exe", "candle.exe", "msi"),
    "deployment": ("windeployqt", "qt deployment", "qt dll", "plugins", "qml modules"),
    "artifact": ("upload-artifact", "download-artifact", "artifact", "archive"),
    "qml": ("qml", "qqml", "qtquick"),
    "cmake": ("cmake error", "configure failed", "could not find"),
    "link": ("undefined reference", "unresolved external", "linker"),
    "compile": ("fatal error", "undeclared", "no member named", "compilation failed"),
    "test": ("ctest", "test failed", "assertion failed"),
    "python": ("traceback", "modulenotfounderror", "python exception"),
}

def diagnose(repo: Path, log: str) -> dict:
    text = log.lower()
    category = "unknown"
    for name in CATEGORIES:
        if name in RULES and any(k in text for k in RULES[name]):
            category = name
            break
    workflow_files = [str(p.relative_to(repo)) for p in (repo / ".github" / "workflows").glob("*.y*ml")] if (repo / ".github" / "workflows").is_dir() else []
    package_files = [str(p.relative_to(repo)) for p in repo.rglob("*") if p.is_file() and p.suffix.lower() in {".nsi", ".nsh", ".wxs", ".wxi"}]
    return {"category": category, "confidence": 75 if category != "unknown" else 20, "workflow_files": workflow_files, "package_files": package_files, "evidence": log[-8000:]}
