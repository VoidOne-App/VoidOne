# VoidOne AI Code Repair

The AI repair workflow listens for failed `VoidOne CI` runs and generates a repair candidate without granting any model write access to the repository.

## Flow

```text
VoidOne CI failure
      |
      v
DeepSeek V4 Flash       -> fast root-cause analysis
      |
      v
Qwen3.8 27B             -> independent second opinion
      |
      v
Claude Fable 5.1        -> unified-diff repair generation
      |
      v
Deterministic validators -> policy / patch / workflow / package / build
      |
      v
GPT-5.6 Luna            -> independent release/security review
      |
   +--+--+
   |     |
 PASS   FAIL
   |     |
   v     v
candidate retry with validation feedback
```

All four model roles use the Experiential Labs OpenAI-compatible gateway. The model IDs are configurable and are checked against `GET /v1/models` at runtime.

## Experiential Labs configuration

- `EXPLABS_API_KEY` — required GitHub Actions secret.
- `EXPLABS_BASE_URL` — defaults to `https://api.experientiallabs.ai/v1`.
- `EXPLABS_DIAGNOSIS_MODEL` — defaults to `deepseek-v4-flash`.
- `EXPLABS_SECOND_OPINION_MODEL` — defaults to `qwen3.8-27b`.
- `EXPLABS_REPAIR_MODEL` — defaults to `claude-fable-5.1`.
- `EXPLABS_REVIEW_MODEL` — defaults to `gpt-5.6-luna`.

The Experiential catalog currently marks the promotional routes used by this pipeline as free. That promotion can change, so the implementation does not hard-code a claim of permanent zero pricing and keeps every model role configurable.

## API behavior

Experiential's documentation exposes an OpenAI-compatible `/v1` API and instructs clients to use the exact model slugs returned by `GET /v1/models`. VoidOne follows that contract.

The request body is intentionally minimal: `model` + `messages`. VoidOne does not force `temperature`, `top_p`, or other sampling parameters because the provider documents that some model routes reject unsupported sampling fields.

## Validation and security

1. A failed `VoidOne CI` run is selected by run ID.
2. Only failed-step logs are downloaded as model input.
3. The repair engine is checked out from trusted `main`; untrusted failed code is never executed with the API secret.
4. The models receive no repository credentials other than `EXPLABS_API_KEY`.
5. Generated patches must pass policy, structural patch, workflow, package, and build/configure validation.
6. A separate model role reviews the candidate before acceptance.
7. Accepted candidates and reports are uploaded as workflow artifacts.
8. GitHub permissions remain `actions: read` and `contents: read`.
9. The AI cannot push commits, create pull requests, or auto-merge changes.

No API key is stored in the repository or written into generated patches.
