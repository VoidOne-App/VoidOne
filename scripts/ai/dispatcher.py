from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
if str(REPO) not in sys.path:
    sys.path.insert(0, str(REPO))

from scripts.ai.diagnosis import diagnose
from scripts.ai.repair import generate_patch
from scripts.ai.policy import Policy
from scripts.ai.reviewer import review
from scripts.validation.patch_validator import validate_patch
from scripts.validation.package_validator import validate_package
from scripts.validation.workflow_validator import validate_workflow
from scripts.reporting.repair_report import write_report


def git(repo: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(["git", *args], cwd=repo, text=True, capture_output=True, check=False)


def apply_patch(repo: Path, patch: str) -> None:
    check = subprocess.run(["git", "apply", "--check", "--whitespace=error-all"], input=patch, text=True, cwd=repo, capture_output=True, check=False)
    if check.returncode:
        raise RuntimeError("git apply --check failed: " + check.stderr[-4000:])
    result = subprocess.run(["git", "apply", "--whitespace=error-all"], input=patch, text=True, cwd=repo, capture_output=True, check=False)
    if result.returncode:
        raise RuntimeError("git apply failed: " + result.stderr[-4000:])


def rollback(repo: Path) -> None:
    git(repo, "reset", "--hard", "HEAD")
    git(repo, "clean", "-fd", "--exclude=.git/")


def main() -> int:
    parser = argparse.ArgumentParser(description="VoidOne modular AI CI repair engine")
    parser.add_argument("--repo", default=".")
    parser.add_argument("--log-file", required=True)
    args = parser.parse_args()
    repo = Path(args.repo).resolve()
    log_path = Path(args.log_file).resolve()
    if not repo.is_dir() or not log_path.is_file():
        return 2
    if git(repo, "status", "--porcelain", "--untracked-files=all").stdout.strip():
        raise SystemExit("Repository must be clean before repair")

    log = log_path.read_text(encoding="utf-8", errors="replace")[-60000:]
    policy = Policy.load(repo / ".ai" / "policies")
    diagnosis = diagnose(repo, log)
    report = {"engine_version": "3.0", "diagnosis": diagnosis}
    try:
        patch = generate_patch(repo, log, diagnosis)
        ok, reason = validate_patch(repo, patch, policy)
        report["patch"] = {"accepted": ok, "reason": reason}
        if not ok:
            raise RuntimeError(reason)
        reviewed, review_reason = review(repo, log, patch, diagnosis, policy)
        report["review"] = {"accepted": reviewed, "reason": review_reason}
        if not reviewed:
            raise RuntimeError(review_reason)
        apply_patch(repo, patch)

        workflow_ok, workflow_reason = validate_workflow(repo)
        package_ok, package_reason = validate_package(repo)
        report["validation"] = {
            "workflow": [workflow_ok, workflow_reason],
            "package": [package_ok, package_reason],
            "build": "authoritative Windows CI required",
        }
        if not (workflow_ok and package_ok):
            raise RuntimeError("Workflow/package validation failed")
        write_report(repo, report)
        return 0
    except Exception as exc:
        report["error"] = str(exc)
        try:
            rollback(repo)
        finally:
            write_report(repo, report)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
