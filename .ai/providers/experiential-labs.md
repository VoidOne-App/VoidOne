# Experiential Labs Repair Provider

VoidOne's AI repair engine can use an OpenAI-compatible Experiential Labs endpoint as its patch generator.

## Configuration

Set these environment variables in trusted CI only:

- `AI_REPAIR_PROVIDER=experiential-labs`
- `EXPLABS_API_KEY` — required secret
- `EXPLABS_BASE_URL` — defaults to `https://api.experientiallabs.ai/v1`
- `EXPLABS_MODEL` — defaults to `claude-fable-5.1`

The independent reviewer remains separate and uses the configured Gemini reviewer. A repair is accepted only after deterministic policy/patch/workflow/package/build validation and independent review.

The provider must never receive repository secrets other than its own API credential. Generated patches are treated as untrusted output and are validated before they are accepted as repair candidates.
