#!/usr/bin/env python3
"""VoidOne AI repair orchestrator. Applies only policy-approved patches and fails closed."""
from __future__ import annotations
import argparse, subprocess, sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
if str(REPO) not in sys.path:
    sys.path.insert(0, str(REPO))

from scripts.ai.diagnosis import diagnose
from scripts.ai.repair import generate_patch
from scripts.ai.policy import Policy
from scripts.ai.reviewer import review
from scripts.validation.patch_validator import validate_patch
from scripts.validation.build_validator import validate_build
from scripts.validation.package_validator import validate_package
from scripts.validation.workflow_validator import validate_workflow
from scripts.reporting.repair_report import write_report


def git_apply(repo: Path, patch: str) -> None:
    check = subprocess.run(["git", "apply", "--check", "--whitespace=error-all"], input=patch, text=True, cwd=repo, capture_output=True)
    if check.returncode:
        raise RuntimeError("git apply --check failed: " + check.stderr[-4000:])
    applied = subprocess.run(["git", "apply", "--whitespace=error-all"], input=patch, text=True, cwd=repo, capture_output=True)
    if applied.returncode:
        raise RuntimeError("git apply failed: " + applied.stderr[-4000:])


def rollback(repo: Path) -> None:
    subprocess.run(["git", "reset", "--hard", "HEAD"], cwd=repo, check=True, capture_output=True, text=True)
    subprocess.run(["git", "clean", "-fd", "--exclude=.git/"], cwd=repo, check=True, capture_output=True, text=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="VoidOne modular AI CI repair engine")
    parser.add_argument("--repo", default=".")
    parser.add_argument("--log-file", required=True)
    args = parser.parse_args()
    repo = Path(args.repo).resolve()
    log = Path(args.log_file).read_text(encoding="utf-8", errors="replace")
    if subprocess.run(["git", "status", "--porcelain", "--untracked-files=all"], cwd=repo, capture_output=True, text=True).stdout.strip():
        raise SystemExit("Repository must be clean before repair")
    policy = Policy.load(repo / ".ai" / "policies")
    diagnosis = diagnose(repo, log)
    report = {"diagnosis": diagnosis}
    try:
        patch = generate_patch(repo, log, diagnosis)
        ok, reason = validate_patch(repo, patch, policy)
        report["patch"] = {"accepted": ok, "reason": reason}
        if not ok: raise RuntimeError(reason)
        review_ok, review_reason = review(repo, log, patch, diagnosis, policy)
        report["review"] = {"accepted": review_ok, "reason": review_reason}
        if not review_ok: raise RuntimeError(review_reason)
        git_apply(repo, patch)
        build_ok, build_reason = validate_build(repo)
        workflow_ok, workflow_reason = validate_workflow(repo)
        package_ok, package_reason = validate_package(repo)
        report["validation"] = {"build": [build_ok, build_reason], "workflow": [workflow_ok, workflow_reason], "package": [package_ok, package_reason]}
        if not (build_ok and workflow_ok and package_ok):
            raise RuntimeError("Deterministic validation failed")
        write_report(repo, report)
        return 0
    except Exception as exc:
        report["error"] = str(exc)
        write_report(repo, report)
        try: rollback(repo)
        except Exception as rollback_error: report["rollback_error"] = str(rollback_error); write_report(repo, report)
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
