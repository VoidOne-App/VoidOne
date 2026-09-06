# VoidOne AI-Assisted Code Repair

VoidOne contains experimental AI-assisted development infrastructure for diagnosing CI failures and generating repair candidates.

> **AI output is untrusted. Deterministic validation and human review remain authoritative.**

## Pipeline

```text
Failed CI run
     │
     ▼
Failure analysis
     │
     ▼
Independent second opinion
     │
     ▼
Candidate patch generation
     │
     ▼
Policy + patch + workflow + package + build validation
     │
     ▼
Independent review
     │
     ├── PASS → candidate artifact
     └── FAIL → retry with validation feedback
```

Model roles are configurable and are resolved through the configured OpenAI-compatible gateway. Runtime model availability is checked against the provider's model catalog rather than assumed.

## Configuration

The repair workflow expects these GitHub Actions secrets/variables when AI repair is enabled:

- `EXPLABS_API_KEY` — API credential; never commit it to the repository.
- `EXPLABS_BASE_URL` — OpenAI-compatible API base URL.
- `EXPLABS_DIAGNOSIS_MODEL` — fast failure-analysis model.
- `EXPLABS_SECOND_OPINION_MODEL` — independent analysis model.
- `EXPLABS_REPAIR_MODEL` — candidate patch generation model.
- `EXPLABS_REVIEW_MODEL` — independent review model.

Model identifiers should be treated as configuration, not permanent project assumptions.

## Security model

1. A failed CI run is selected by run ID.
2. Only relevant failed-step logs are supplied to the repair process.
3. The repair engine runs from trusted repository code; failed/untrusted build output is not executed with the API secret.
4. AI tooling receives only the credentials required to call its configured provider.
5. Generated patches pass deterministic repository policy, structural, workflow, package, and build validation.
6. Review remains independent from patch generation.
7. Reports and accepted candidates are retained as workflow artifacts when configured.
8. The AI repair workflow should use read-only GitHub permissions unless a narrowly scoped action explicitly requires more.
9. The repair system does not automatically merge generated changes.

## Engineering rules

- Never store API keys, certificates, passwords, or signing material in source control.
- Never treat model output as trusted code.
- Keep repair candidates reviewable as ordinary Git diffs.
- Prefer deterministic validators over model self-assessment.
- Keep AI infrastructure separate from player-facing VoidOne Intelligence.
- Record enough context in artifacts to reproduce and audit a repair attempt.

## Scope

This system is **developer tooling**, not a runtime dependency of VoidOne. A user installation must remain functional without the AI repair infrastructure or its provider credentials.
