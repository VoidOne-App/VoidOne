from __future__ import annotations
from pathlib import Path
import subprocess

def run(cmd, cwd, timeout=900):
    p = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True, timeout=timeout)
    return p.returncode, (p.stdout + "\n" + p.stderr)[-8000:]

def validate_build(repo: Path) -> tuple[bool, str]:
    build = repo / "build"
    if build.exists():
        import shutil; shutil.rmtree(build)
    try:
        code, out = run(["cmake", "-S", ".", "-B", "build", "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release", "-DBUILD_TESTING=ON"], repo)
        if code: return False, "CMake configure failed: " + out
        code, out = run(["cmake", "--build", "build", "--parallel"], repo)
        if code: return False, "Build failed: " + out
        code, out = run(["ctest", "--test-dir", "build", "--output-on-failure", "--timeout", "120"], repo, 600)
        return (code == 0, "Build and tests passed." if code == 0 else "CTest failed: " + out)
    except Exception as exc:
        return False, f"Build validator error: {exc}"
