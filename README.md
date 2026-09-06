<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

# 🌌 VoidOne

### The Open-Source Native PC Gaming Platform Built Around Your Games — Not Around a Store

<p>
  <b>🇬🇧 English</b> •
  <a href="README.fa.md">🇮🇷 پارسی</a>
</p>

<p>
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml"><img src="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml/badge.svg" alt="CI/CD" /></a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases/latest"><img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?include_prereleases&label=latest%20release" alt="Latest Release" /></a>
  <a href="https://github.com/VoidOne-App/VoidOne/stargazers"><img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=flat" alt="GitHub Stars" /></a>
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE"><img src="https://img.shields.io/github/license/VoidOne-App/VoidOne" alt="MIT License" /></a>
</p>

<p>
  <b>C++23</b> • <b>Qt 6.11.2</b> • <b>QML / Qt Quick</b> • <b>SQLite</b> • <b>CMake</b> • <b>Ninja</b>
</p>

<p><b>Windows x64 — Primary Release Platform</b> • <b>MIT License</b></p>

### **Your Games. Your Hardware. Your AI. Your Rules.**

**Built by a gamer. Engineered like a platform. Built in the open.**

</div>

---

## 🌌 What Is VoidOne?

**VoidOne** is an open-source native PC gaming platform designed around a simple principle:

> **Your games should be the center of your gaming experience — not the stores distributing them.**

VoidOne is being built as a native platform layer between the player, the operating system, and the gaming ecosystem. It is **not a storefront** and does not aim to replace the services that distribute the games you already own.

Long-term platform areas include:

- 🎮 Game libraries and discovery
- 🚀 Game execution and process management
- 🌐 Multi-provider integrations
- 🧰 Mod management
- 📊 Local analytics and diagnostics
- 🎨 Personalization
- 🧠 Optional user-controlled AI
- 🌍 Translation
- 🔌 Extensions and developer tooling

## 🧭 Core Principles

- **Native first** — prefer native technologies and OS capabilities when they improve performance, integration, reliability, or maintainability.
- **Privacy by design** — avoid unnecessary collection and transmission of player data.
- **Local first** — keep important player state locally controlled whenever practical.
- **Lightweight by design** — dependencies and background work must justify their resource cost.
- **Player ownership** — users control their games, configuration, data, integrations, and optional intelligence systems.
- **Open by design** — the platform should remain inspectable, modifiable, and extensible.
- **Evidence over marketing** — technical claims should be backed by implementation, tests, benchmarks, or reproducible evidence.

## 📦 Project Status

VoidOne is in **active experimental development**. The repository and CI configuration are the source of truth for implemented behavior.

| Status | Meaning |
|---|---|
| 🟢 Implemented | Present in the current repository |
| 🧪 Experimental | Implemented but under active validation |
| 🛠️ Development | Actively being developed |
| 🔭 Planned | Future direction |
| 🚀 Stable | Reserved for proven production-ready milestones |

> A roadmap item is not evidence that a feature already exists.

## 🏗️ Technical Foundation

| Technology | Role |
|---|---|
| C++23 | Native application and systems development |
| Qt 6.11.2 | Application framework |
| QML / Qt Quick | User interface |
| SQLite | Local persistence |
| CMake 3.25+ | Build system |
| Ninja | Build execution |
| CTest | Automated testing |
| GitHub Actions | CI/CD |
| MSVC x64 | Primary Windows toolchain |
| NSIS | Windows installer |

## 🧩 Architecture

```text
┌──────────────────────────────────────────────┐
│                  Qt / QML UI                 │
└──────────────────────┬───────────────────────┘
                       ▼
┌──────────────────────────────────────────────┐
│              Application entry               │
│                 src/main.cpp                 │
└──────────────────────┬───────────────────────┘
                       ▼
┌──────────────────────────────────────────────┐
│                Native C++ core               │
│                 src/core/                    │
└───────────────┬───────────────────┬──────────┘
                ▼                   ▼
        ┌──────────────┐    ┌──────────────┐
        │    SQLite    │    │   OS / Qt    │
        │ local state  │    │ integrations │
        └──────────────┘    └──────────────┘
```

See [`docs/architecture/overview.md`](docs/architecture/overview.md) for repository boundaries and architectural rules.

## 🗺️ Roadmap

### Phase I — Native Foundation

- C++23 foundation
- Qt / QML application foundation
- CMake build system
- SQLite persistence
- Native application architecture
- CI/CD and Windows packaging
- Automated testing and diagnostics

### Phase II — Library Intelligence

- Game discovery
- Installation detection
- Library persistence and indexing
- Game identity and metadata normalization
- Provider abstraction

### Phase III — Gaming Experience

- Advanced library UI
- Search and filtering
- Categorization
- Artwork and metadata
- Personalization

### Phase IV — 👻 Ghost Launcher

A planned execution layer for launch arguments, per-game profiles, process lifecycle tracking, runtime state, and background-process policies.

VoidOne does not intend to bypass DRM, licensing requirements, or required platform authentication.

### Phase V — 🧠 VoidOne Intelligence

A planned optional intelligence layer supporting user-selected local and cloud models for assistance, diagnostics, configuration, translation, and hardware-aware workflows.

AI is intended to remain optional and replaceable rather than becoming a mandatory core dependency.

## 🤖 Engineering AI

VoidOne also contains experimental AI-assisted development infrastructure for CI diagnosis and repair candidates. This is separate from player-facing VoidOne Intelligence.

AI-generated changes are treated as untrusted output and must pass deterministic validation and human review.

See [`docs/engineering/ai-repair.md`](docs/engineering/ai-repair.md).

## 🪟 Windows Release Pipeline

Windows is currently the primary release platform. The CI pipeline performs:

1. Source checkout and toolchain setup
2. Git-tag/dev version resolution
3. CMake configuration and Release build
4. Automated tests
5. Qt runtime deployment
6. Installer input validation
7. NSIS installer generation
8. Optional Authenticode signing
9. Portable ZIP generation
10. Artifact upload
11. GitHub Release publication for tags
12. CI notifications

Release artifacts:

- `VoidOne-Setup-x64.exe`
- `VoidOne-Portable-x64.zip`

See [`docs/release/windows.md`](docs/release/windows.md) for the release checklist.

## 🔨 Build From Source

The supported path is CMake presets.

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

For a local optimized build:

```bash
cmake --preset release
cmake --build --preset release
ctest --preset release
```

For the strict Windows CI configuration:

```bash
cmake --preset ci-windows
cmake --build --preset ci-windows
ctest --preset ci-windows
```

See [`docs/build.md`](docs/build.md) for requirements, Qt setup, packaging, and troubleshooting.

## 📚 Documentation

- [Build Guide](docs/build.md)
- [Architecture Overview](docs/architecture/overview.md)
- [Windows Release Engineering](docs/release/windows.md)
- [AI-Assisted Code Repair](docs/engineering/ai-repair.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Contributing](CONTRIBUTING.md)
- [Security](SECURITY.md)

## 🤝 Contributing

Contributions are welcome across C++, Qt/QML, UI/UX, testing, documentation, performance, build systems, CI/CD, security, developer tooling, and platform support.

Keep changes focused and reviewable. For substantial changes, document what changed, why it changed, how it was tested, and any compatibility, performance, or security considerations.

## 🔐 Security

Security is an engineering concern throughout the project. Report security issues according to [`SECURITY.md`](SECURITY.md) rather than publishing sensitive details in a public issue.

## 📜 License

VoidOne is distributed under the **MIT License**. See [`LICENSE`](LICENSE).

---

<div align="center">

### **Your Games. Your Hardware. Your AI. Your Rules.**

**Built by a gamer. Engineered like a platform. Built in the open.**

♾️ Free & Open Source · 🚫 No Ads · 🔒 Privacy First · 🧠 Optional AI

[⭐ Star VoidOne](https://github.com/VoidOne-App/VoidOne) · [📦 Releases](https://github.com/VoidOne-App/VoidOne/releases) · [🐛 Issues](https://github.com/VoidOne-App/VoidOne/issues) · [🤝 Contributing](https://github.com/VoidOne-App/VoidOne/blob/main/CONTRIBUTING.md)

</div>
