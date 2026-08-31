from __future__ import annotations
from pathlib import Path
import json, os, time

def write_report(repo: Path, report: dict) -> Path:
    target = Path(os.getenv("AI_REPAIR_REPORT_DIR", str(repo / ".voidone")))
    target.mkdir(parents=True, exist_ok=True)
    report = {"schema_version": "1.0", "generated_at": time.time(), **report}
    path = target / "ai-repair-report.json"
    path.write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    return path
