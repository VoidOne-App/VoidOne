# AI Repair Providers

VoidOne's CI repair pipeline uses the OpenAI-compatible Experiential Labs gateway as its default provider.

The repair stack is role-based rather than tied to one model:

- `deepseek-v4-flash` — fast failure diagnosis.
- `qwen3.8-27b` — second opinion.
- `claude-fable-5.1` — repair generation.
- `gpt-5.6-luna` — independent review.

All roles are configurable through `EXPLABS_*_MODEL` environment variables. The gateway model list is checked at runtime so the exact slugs exposed to the API key are used.

The pipeline keeps deterministic validation and an independent review between model output and acceptance. It never grants the model repository write access or auto-merges generated code.
