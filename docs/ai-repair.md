# VoidOne AI Code Repair

The AI repair workflow listens for failed `VoidOne CI` runs and generates a repair candidate without granting the model write access to the repository.

## Flow

1. A `VoidOne CI` run fails.
2. The repair workflow downloads the failed-step logs.
3. The trusted repair engine on `main` diagnoses the failure.
4. Experiential Labs generates a unified-diff candidate using the OpenAI-compatible API.
5. VoidOne policy, structural patch, workflow, package and build validators check the candidate.
6. The independent reviewer evaluates the candidate.
7. A report and accepted candidate patch are uploaded as workflow artifacts.

The workflow deliberately has `contents: read` and does not automatically push commits or open pull requests. This keeps generated code reviewable and prevents model output from receiving repository write privileges.

## Required secrets

- `EXPLABS_API_KEY` — Experiential Labs API credential.
- `GEMINI_API_KEY` — independent reviewer credential.

No API credentials are stored in the repository or embedded in generated patches.
