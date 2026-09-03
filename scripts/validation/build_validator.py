from __future__ import annotations

import subprocess
from pathlib import Path


def _run(repo: Path, args: list[str], timeout: int = 60) -> tuple[int, str]:
    p = subprocess.run(args, cwd=repo, text=True, capture_output=True, timeout=timeout, check=False)
    return p.returncode, (p.stdout + "\n" + p.stderr)[-8000:]


def validate_build(repo: Path) -> tuple[bool, str]:
    if not (repo / "CMakeLists.txt").is_file():
        return False, "CMakeLists.txt is missing."
    code, out = _run(repo, ["cmake", "-S", ".", "-B", "build-ai", "-G", "Ninja", "-DBUILD_TESTING=ON"], 180)
    if code != 0:
        return False, "CMake configure failed:\n" + out
    return True, "CMake configure passed; authoritative Windows build remains required for MSVC/Qt/package validation."
