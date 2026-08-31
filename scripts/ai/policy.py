from __future__ import annotations
from pathlib import Path
import fnmatch
try:
    import yaml
except ImportError:
    yaml = None

class Policy:
    def __init__(self, allowed: list[str], forbidden: list[str]):
        self.allowed, self.forbidden = allowed, forbidden
    @classmethod
    def load(cls, directory: Path):
        def read(name):
            if not yaml: return {}
            p = directory / name
            return yaml.safe_load(p.read_text(encoding="utf-8")) if p.exists() else {}
        a, f = read("allowed-paths.yml"), read("forbidden-files.yml")
        return cls(a.get("allowed", []), f.get("forbidden", []))
    def allowed_path(self, path: str) -> bool:
        path = path.replace("\\", "/").lstrip("./")
        if any(fnmatch.fnmatch(path, p) for p in self.forbidden): return False
        return any(fnmatch.fnmatch(path, p) for p in self.allowed)
