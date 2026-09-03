from __future__ import annotations

import json
import time
from pathlib import Path
from typing import Any


def write_report(repo: Path, report: dict[str, Any]) -> Path:
    root = Path(__import__("os").environ.get("AI_REPAIR_TEMP_DIR", repo / ".voidone-ai"))
    root.mkdir(parents=True, exist_ok=True)
    report = {**report, "generated_at": time.time(), "engine": "VoidOne AI Repair Platform", "engine_version": "4.0.0"}
    path = root / "repair-report.json"
    path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    return path
