from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Any

CATEGORIES = (
    "workflow", "packaging", "installer", "deployment", "artifact",
    "cmake", "qml", "link", "compile", "test", "python", "dependency", "unknown",
)
RULES: dict[str, tuple[str, ...]] = {
    "workflow": (".github/workflows/", "github actions", "workflow", "runner", "actions/", "yaml", "yml"),
    "packaging": ("cpack", "package", "packaging", "artifact", "archive"),
    "installer": ("nsis", "makensis", "wix", "light.exe", "candle.exe", "msi", "installer"),
    "deployment": ("windeployqt", "qt deployment", "qt dll", "plugins", "qml modules"),
    "artifact": ("upload-artifact", "download-artifact", "artifact", "zip"),
    "cmake": ("cmake error", "configure failed", "configuration failed", "could not find"),
    "qml": ("qml", "qqml", "qtquick"),
    "link": ("undefined reference", "unresolved external", "linker", "ld returned"),
    "compile": ("fatal error", "undeclared", "no member named", "compilation failed"),
    "test": ("ctest", "test failed", "assertion failed"),
    "python": ("traceback", "modulenotfounderror", "python exception"),
    "dependency": ("package not found", "missing library", "could not find package", "dependency"),
}


def _files(repo: Path, suffixes: tuple[str, ...]) -> list[str]:
    result: list[str] = []
    for p in repo.rglob("*"):
        if not p.is_file() or ".git" in p.parts:
            continue
        if p.suffix.lower() in suffixes:
            result.append(str(p.relative_to(repo)).replace("\\", "/"))
    return sorted(result)


def diagnose(repo: Path, log: str) -> dict[str, Any]:
    text = log.lower()
    scores = {name: sum(text.count(k) for k in keys) for name, keys in RULES.items()}
    category = max(scores, key=scores.get)
    if scores[category] == 0:
        category = "unknown"
    confidence = min(98, 35 + scores[category] * 12) if category != "unknown" else 15
    return {
        "category": category,
        "confidence": confidence,
        "scores": scores,
        "workflow_files": _files(repo, (".yml", ".yaml")),
        "package_files": _files(repo, (".nsi", ".nsh", ".wxs", ".wxi", ".wixproj")),
        "cmake_files": _files(repo, (".cmake",)),
        "evidence": log[-12000:],
    }


def collect_context(repo: Path, diagnosis: dict[str, Any], limit: int = 70000) -> str:
    candidates = [
        "CMakeLists.txt", "CPackConfig.cmake", "CMakePresets.json",
        *diagnosis.get("workflow_files", []),
        *diagnosis.get("package_files", []),
        *diagnosis.get("cmake_files", []),
    ]
    seen: set[str] = set()
    chunks: list[str] = []
    for rel in candidates:
        rel = rel.replace("\\", "/")
        if rel in seen or rel.startswith(".git/"):
            continue
        seen.add(rel)
        p = repo / rel
        if not p.is_file():
            continue
        try:
            data = p.read_text(encoding="utf-8", errors="replace")[:14000]
        except OSError:
            continue
        chunks.append(f"=== {rel} ===\n{data}")
        if sum(map(len, chunks)) >= limit:
            break
    return "\n\n".join(chunks)[:limit]
