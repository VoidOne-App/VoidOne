# Experiential Labs Repair Provider

VoidOne's AI repair engine uses the OpenAI-compatible Experiential Labs gateway as its zero-budget repair stack.

## Official gateway configuration

The gateway documents the following OpenAI-compatible endpoint and authentication model:

- Base URL: `https://api.experientiallabs.ai/v1`
- Secret: `EXPLABS_API_KEY`
- Authentication: `Authorization: Bearer <key>`
- Model IDs must be used exactly as returned by `GET /v1/models`.

VoidOne performs that model-list check before each model call so a missing or unavailable promotional route fails safely instead of silently switching to a paid model.

## Current model roles

The defaults are intentionally configurable through environment variables:

- `EXPLABS_DIAGNOSIS_MODEL=deepseek-v4-flash` — fast CI diagnosis.
- `EXPLABS_SECOND_OPINION_MODEL=qwen3.8-27b` — challenge the diagnosis.
- `EXPLABS_REPAIR_MODEL=claude-fable-5.1` — generate the unified diff.
- `EXPLABS_REVIEW_MODEL=gpt-5.6-luna` — independent review.

The Experiential model catalog currently marks the promotional routes used by this workflow as free. Promotional access is not treated as a permanent price guarantee; the workflow keeps model selection configurable and validates the models exposed to its API key at runtime.

## Request safety

Experiential's documentation recommends a minimal OpenAI Chat Completions request and notes that some Claude routes reject explicit sampling parameters. VoidOne therefore sends only `model` and `messages`; it does not force `temperature`, `top_p`, or other provider-specific sampling fields.

The provider receives only its own API credential. Generated patches are untrusted output and must pass deterministic policy, structural patch, workflow, package, build/configure, and independent-review gates before they become repair candidates.

The workflow has read-only GitHub permissions and never lets the model push code or create a pull request automatically.
