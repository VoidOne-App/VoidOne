from __future__ import annotations

from pathlib import Path

from scripts.ai.policy import Policy, validate_patch as _validate


def validate_patch(repo: Path, patch: str, policy: Policy | None = None) -> tuple[bool, str]:
    return _validate(repo, patch, policy or Policy.load(repo / ".ai" / "policies"))
