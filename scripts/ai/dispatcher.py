#!/usr/bin/env python3
"""Orchestrate diagnosis, repair, policy, validation and reporting."""
from __future__ import annotations
import argparse
from pathlib import Path
from diagnosis import diagnose
from repair import generate_patch
from policy import Policy
from reviewer import review
from validation.patch_validator import validate_patch
from validation.build_validator import validate_build
from validation.package_validator import validate_package
from validation.workflow_validator import validate_workflow
from reporting.repair_report import write_report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", default=".")
    parser.add_argument("--log-file", required=True)
    args = parser.parse_args()
    repo = Path(args.repo).resolve()
    log = Path(args.log_file).read_text(encoding="utf-8", errors="replace")
    policy = Policy.load(repo / ".ai" / "policies")
    diagnosis = diagnose(repo, log)
    patch = generate_patch(repo, log, diagnosis)
    report = {"diagnosis": diagnosis, "patch": {"accepted": False}}
    ok, reason = validate_patch(repo, patch, policy)
    report["patch"] = {"accepted": ok, "reason": reason}
    if not ok:
        write_report(repo, report)
        return 1
    review_ok, review_reason = review(repo, log, patch, diagnosis, policy)
    report["review"] = {"accepted": review_ok, "reason": review_reason}
    if not review_ok:
        write_report(repo, report)
        return 1
    build_ok, build_reason = validate_build(repo)
    workflow_ok, workflow_reason = validate_workflow(repo)
    package_ok, package_reason = validate_package(repo)
    report["validation"] = {"build": [build_ok, build_reason], "workflow": [workflow_ok, workflow_reason], "package": [package_ok, package_reason]}
    write_report(repo, report)
    return 0 if build_ok and workflow_ok and package_ok else 1

if __name__ == "__main__":
    raise SystemExit(main())
