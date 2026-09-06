# VoidOne Architecture Overview

VoidOne is structured as a native desktop platform with a deliberately small core and clear boundaries between UI, application behavior, persistence, and operating-system integration.

## Current architecture

```text
┌──────────────────────────────────────────────┐
│                 Qt / QML UI                  │
│              src/ui/qml/                     │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│              Application entry               │
│                 src/main.cpp                 │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                Native core                   │
│                 src/core/                    │
│                                              │
│ Database · GameModel · SteamScanner          │
│ TranslationManager · SaveBackupManager       │
└───────────────┬───────────────────┬──────────┘
                │                   │
                ▼                   ▼
        ┌──────────────┐    ┌──────────────┐
        │    SQLite    │    │   OS / Qt    │
        │ local state  │    │ integrations │
        └──────────────┘    └──────────────┘
```

## Repository boundaries

| Directory | Responsibility |
|---|---|
| `src/core/` | Native application and domain services |
| `src/ui/` | QML and presentation-layer resources |
| `tests/` | Automated validation |
| `cmake/` | Generated-header templates and build helpers |
| `assets/` | Source-controlled application assets |
| `packaging/windows/` | Windows distribution and installer definitions |
| `scripts/` | Developer and CI automation |
| `docs/` | Engineering and user-facing documentation |
| `.github/` | CI/CD, issue templates, and repository automation |
| `.ai/` | AI-assisted engineering infrastructure |

Build output is intentionally kept outside the source structure in `build/`, `package/`, and `dist/`. These paths are generated and ignored by Git.

## Dependency direction

The preferred dependency direction is:

```text
UI → application/core → persistence/platform services
```

Core services should not depend on QML implementation details. UI code should consume stable C++ interfaces rather than reaching directly into persistence internals.

## Versioning

Git tags are the release source of truth. CI converts a tag such as `v0.0.2-beta.1` into:

- human-readable application version: `0.0.2-beta.1`
- Windows numeric PE version: `0.0.2.0`

Development builds receive an ephemeral `0.0.0-dev.<commit>` version.

## Stability principle

Architecture changes should preserve build reproducibility and runtime behavior whenever possible. New boundaries should be introduced incrementally, with CI validation before old paths or compatibility shims are removed.
