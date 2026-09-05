# AI Repair Providers

Repair generation is provider-selectable through `AI_REPAIR_PROVIDER`.

The current providers are:

- `gemini` — existing Google Gemini generator.
- `experiential-labs` — OpenAI-compatible Experiential Labs endpoint.

The repair pipeline keeps deterministic validation and an independent reviewer between model output and acceptance.
