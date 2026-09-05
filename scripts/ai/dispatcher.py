from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from scripts.ai.diagnosis import collect_context, diagnose
from scripts.ai.policy import Policy, validate_patch
from scripts.ai.repair import generate_patch
from scripts.ai.reviewer import review
from scripts.reporting.repair_report import write_report
from scripts.validation.build_validator import validate_build
from scripts.validation.package_validator import validate_package
from scripts.validation.patch_validator import validate_patch as structural_patch_validate
from scripts.validation.workflow_validator import validate_workflow


def run(repo: Path, *args: str, input_text: str | None = None, timeout: int = 120) -> tuple[int, str]:
    p = subprocess.run([*args], cwd=repo, input=input_text, text=True, capture_output=True, timeout=timeout, check=False)
    return p.returncode, (p.stdout + "\n" + p.stderr)[-12000:]


def clean_generated_state(repo: Path) -> None:
    run(repo, "git", "reset", "--hard", "HEAD")
    run(repo, "git", "clean", "-fd", "-e", ".git/")


def main() -> int:
    parser = argparse.ArgumentParser(description="VoidOne AI CI/package repair platform")
    parser.add_argument("--repo", default=".")
    parser.add_argument("--log-file", required=True)
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    log_path = Path(args.log_file).resolve()
    if not repo.is_dir() or not log_path.is_file():
        print("Invalid repository or log path", file=sys.stderr)
        return 2
    status, status_text = run(repo, "git", "status", "--porcelain", "--untracked-files=all")
    if status != 0 or status_text.strip():
        print("Repository must be clean before AI repair", file=sys.stderr)
        return 2

    log = log_path.read_text(encoding="utf-8", errors="replace")[-60000:]
    policy = Policy.load(repo / ".ai" / "policies")
    diagnosis = diagnose(repo, log)
    context = collect_context(repo, diagnosis)
    report: dict = {"diagnosis": diagnosis, "attempts": [], "status": "FAILED"}
    previous = ""
    output_root = Path(os.getenv("AI_REPAIR_TEMP_DIR", repo / ".voidone-ai"))
    output_root.mkdir(parents=True, exist_ok=True)

    for attempt in range(1, int(os.getenv("AI_REPAIR_MAX_ATTEMPTS", "2")) + 1):
        item: dict = {"attempt": attempt}
        try:
            result = generate_patch(repo, log, diagnosis, context, previous)
            item["ai"] = {k: result.get(k) for k in ("status", "diagnosis", "confidence", "provider", "model")}
            if result.get("status") != "PATCH":
                raise RuntimeError("AI returned NO_FIX")
            confidence = float(result.get("confidence", 0))
            if confidence < 65:
                raise RuntimeError(f"AI confidence below threshold: {confidence:.0f}")
            patch = str(result.get("patch", ""))

            ok, reason = validate_patch(repo, patch, policy)
            item["policy"] = {"ok": ok, "reason": reason}
            if not ok:
                raise RuntimeError(reason)
            ok, reason = structural_patch_validate(repo, patch, policy)
            item["patch_validation"] = {"ok": ok, "reason": reason}
            if not ok:
                raise RuntimeError(reason)

            ok, apply_out = run(repo, "git", "apply", "--check", "--whitespace=error-all", input_text=patch)
            if ok != 0:
                raise RuntimeError("git apply --check failed: " + apply_out)
            ok, apply_out = run(repo, "git", "apply", "--whitespace=error-all", input_text=patch)
            if ok != 0:
                raise RuntimeError("git apply failed: " + apply_out)

            diff_code, diff = run(repo, "git", "diff", "--check")
            if diff_code != 0:
                raise RuntimeError("git diff --check failed: " + diff)

            workflow_ok, workflow_reason = validate_workflow(repo)
            package_ok, package_reason = validate_package(repo)
            build_ok, build_reason = validate_build(repo)
            item["validation"] = {
                "workflow": [workflow_ok, workflow_reason],
                "package": [package_ok, package_reason],
                "build_configure": [build_ok, build_reason],
            }
            if not (workflow_ok and package_ok and build_ok):
                raise RuntimeError("Deterministic validation failed")

            review_ok, review_reason = review(repo, log, patch, diagnosis, policy)
            item["review"] = {"ok": review_ok, "reason": review_reason}
            if not review_ok:
                raise RuntimeError(review_reason)

            patch_path = output_root / "repair-candidate.patch"
            patch_path.write_text(patch, encoding="utf-8")
            report["attempts"].append(item)
            report["status"] = "SUCCESS"
            report["final"] = {
                "patch_files": len(patch.split("+++ b/")) - 1,
                "review": review_reason,
                "candidate_patch": str(patch_path),
            }
            write_report(repo, report)
            print(json.dumps(report, indent=2, ensure_ascii=False))
            return 0
        except Exception as exc:
            item["error"] = str(exc)
            report["attempts"].append(item)
            previous = str(exc)
            clean_generated_state(repo)

    report["final_error"] = previous or "No repair candidate accepted"
    write_report(repo, report)
    print(json.dumps(report, indent=2, ensure_ascii=False))
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
