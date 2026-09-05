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
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE"><img src="https://img.shields.io/github/license/VoidOne-App/VoidOne" alt="License" /></a>
</p>

<p>
  <img src="https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++23" />
  <img src="https://img.shields.io/badge/Qt-6.11.2-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6.11.2" />
  <img src="https://img.shields.io/badge/QML-Qt%20Quick-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="QML / Qt Quick" />
  <img src="https://img.shields.io/badge/SQLite-Local%20Storage-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
</p>

<p>
  <img src="https://img.shields.io/badge/Primary%20Platform-Windows%20x64-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows x64" />
  <img src="https://img.shields.io/badge/License-MIT-FD606A?style=for-the-badge" alt="MIT License" />
</p>

### **Your Games. Your Hardware. Your AI. Your Rules.**

**Built by a gamer. Engineered like a platform. Built in the open.**

</div>

---

# 🌌 What Is VoidOne?

**VoidOne** is an open-source native PC gaming platform being engineered around a simple principle:

> **Your games should be the center of your gaming experience — not the stores distributing them.**

VoidOne is designed as a native platform layer between the player, the operating system, and the gaming ecosystem.

The long-term platform is intended to progressively bring together:

- 🎮 Game libraries
- 🚀 Game execution
- 👻 Process management
- 🌐 Multiple game providers
- 🧰 Mod management
- 📊 Local analytics
- 🩺 Diagnostics
- 🎨 Personalization
- 🧠 User-selected AI
- 🌍 Translation
- 🔌 Extensions and developer tooling

VoidOne is **not a storefront**. It aims to provide an open, native, modular layer for managing and interacting with gaming environments the player already owns.

---

# 🎯 Vision

VoidOne's long-term goal is to give players more control over their games, hardware, data, workflows, and optional intelligence systems.

```text
PLAYER
  │
  ▼
VOIDONE
  │
  ├── Game Libraries
  ├── Execution Layer
  ├── Diagnostics
  ├── Local Data
  └── Optional Intelligence
          │
          ├── Local AI
          └── Cloud AI
  │
  ▼
OPERATING SYSTEM
```

The objective is not to own the player's ecosystem. The objective is to **give the player a better interface to the ecosystem they already own.**

---

# 🧭 Core Philosophy

## 🧱 Native First

Prefer native technologies and operating-system capabilities when they provide meaningful advantages in performance, integration, reliability, maintainability, and resource efficiency.

## 🔒 Privacy by Design

Player information should not be collected, transmitted, or monetized without a legitimate technical reason.

## 💾 Local First

Whenever technically practical, important player data should remain locally controlled.

## ⚡ Lightweight by Design

Dependencies, background processes, runtime components, and services should justify their resource cost.

## 🎮 Player Ownership

Players should remain in control of their games, configurations, profiles, data, integrations, and optional AI systems.

## 🌐 Open by Design

VoidOne should remain inspectable, modifiable, extensible, and accessible to contributors.

## 🧠 User-Controlled Intelligence

VoidOne does not intend to force a proprietary AI model onto users. AI should remain optional, replaceable, and controlled by the user.

## 📐 Evidence Over Marketing

Technical claims should be supported by implementation, testing, benchmarks, documentation, or reproducible evidence.

---

# 📦 Current Project Status

VoidOne is in **active experimental development**. Current releases represent the evolving implementation, not the complete long-term vision.

| Status | Meaning |
|---|---|
| 🟢 Implemented | Present in the current repository |
| 🧪 Experimental | Implemented but still under active validation |
| 🛠️ Development | Actively being developed |
| 🔭 Planned | Future platform direction |
| 🚀 Stable | Reserved for proven production-ready milestones |

> **A roadmap item is not evidence that a feature already exists.**

The repository and CI configuration remain the primary sources of truth for current implementation and build behavior.

---

# 🏗️ Current Technical Foundation

| Technology | Role |
|---|---|
| **C++23** | Native application and systems development |
| **Qt 6.11.2** | Application framework |
| **QML / Qt Quick** | User interface |
| **SQLite** | Local persistence |
| **CMake 3.25+** | Build configuration |
| **Ninja** | Build execution |
| **CTest** | Automated testing |
| **GitHub Actions** | CI/CD automation |
| **MSVC x64** | Primary Windows toolchain |
| **NSIS** | Windows installer generation |

The current Windows CI pipeline is based on Qt 6.11.2, MSVC x64, Ninja, automated tests, Qt deployment, NSIS packaging, and portable ZIP generation.

---

# 🧩 Architecture

## Current Foundation

```text
┌──────────────────────┐
│      Qt / QML UI     │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  C++ Application     │
│       Layer          │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│    Native C++ Core   │
└───────┬────────┬─────┘
        │        │
        ▼        ▼
   ┌────────┐  ┌──────────────┐
   │ SQLite │  │ OS APIs      │
   └────────┘  └──────────────┘
```

The architecture is intentionally designed so the local application can remain useful without requiring a heavy backend.

---

# 🗺️ Platform Roadmap

## Phase I — Native Foundation

- C++23 foundation
- Qt / QML application foundation
- CMake build system
- SQLite persistence
- Native application architecture
- GitHub Actions CI/CD
- Windows build and packaging pipeline
- Automated testing and diagnostics

## Phase II — Library Intelligence

Planned areas:

- Game discovery
- Installation detection
- Library persistence
- Game identity
- Library indexing
- Metadata normalization
- Provider abstraction

## Phase III — Gaming Experience

Planned areas:

- Advanced game library
- Search and filtering
- Categorization
- Artwork and metadata
- Personalization
- Dynamic UI improvements

## Phase IV — 👻 Ghost Launcher

A planned controlled execution layer between VoidOne and game processes.

Potential capabilities include launch arguments, environment configuration, per-game profiles, process lifecycle tracking, runtime state, and background-process policies.

VoidOne does not intend to bypass DRM, licensing requirements, or required platform authentication.

## Phase V — 🧠 VoidOne Intelligence

The long-term AI integration architecture is intended to support user-selected local and cloud intelligence.

Potential areas include:

- Game library assistance
- Diagnostics
- Configuration assistance
- Translation
- Hardware-aware recommendations
- Context-aware assistance

AI remains optional and should never become a mandatory dependency of the core launcher.

## Future Phases

Long-term planning also covers:

- 🌐 Multi-provider / multi-store library support
- 🧰 Mod platform
- 🩺 Diagnostics and local analytics
- 🎨 Personalization
- 💾 Backup and recovery
- 🔌 Developer and extension ecosystem

These remain subject to architecture, implementation, and validation.

---

# 🤖 Engineering AI

VoidOne also contains experimental AI-assisted **development infrastructure**. This is separate from the player-facing VoidOne Intelligence architecture.

The engineering pipeline is intended to assist with CI failure diagnosis and candidate repair while keeping deterministic validation and human review in control.

```text
CI Failure
    │
    ▼
Failure Analysis
    │
    ▼
AI-Assisted Diagnosis
    │
    ▼
Candidate Repair
    │
    ▼
Build / Tests / Validation
    │
    ▼
Human Review
```

AI-generated changes are treated as untrusted output. They must pass repository policies and validation before they can be considered.

The repair infrastructure does **not** automatically merge changes into the project.

---

# 🪟 Platform Status

## Windows — Primary Platform

Windows is currently the primary development, build, test, and packaging environment.

The release pipeline targets **Windows x64**.

Current release packaging includes:

- `VoidOne-Setup-x64.exe` — NSIS installer
- `VoidOne-Portable-x64.zip` — portable package

## 🐧 Linux — Cross-Platform Direction

Linux is part of VoidOne's broader cross-platform architecture and development direction. The current release pipeline is not the primary Linux packaging path.

## 🍎 macOS

macOS is not currently part of the primary build and packaging pipeline.

---

# 📦 Windows Release Pipeline

The current CI pipeline performs:

1. Qt 6.11.2 setup
2. MSVC x64 configuration
3. C++23 Release build
4. Database and lifecycle tests
5. Full CTest validation
6. Qt runtime deployment
7. NSIS installer generation
8. Optional Authenticode signing when configured
9. Portable ZIP generation
10. Artifact upload

The exact workflow is authoritative and may evolve independently of this README.

---

# 🔨 Build From Source

## Requirements

For the primary Windows build:

- Windows 10/11
- Visual Studio 2022 / MSVC x64
- Qt **6.11.x**
- CMake 3.25+
- Ninja
- Git

Clone the repository:

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
```

Configure with CMake:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23
```

If CMake cannot locate Qt, provide your Qt installation path:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23 -DCMAKE_PREFIX_PATH="C:\Qt\6.11.2\msvc2022_64"
```

Build:

```bash
cmake --build build --parallel
```

Run tests when test targets are configured:

```bash
ctest --test-dir build --output-on-failure
```

For the exact CI configuration, see `.github/workflows/c.cpp.yml`.

---

# 🧪 Testing & Validation

The repository currently includes automated validation for areas such as:

- Database behavior
- Database lifecycle
- Save backup management
- CTest execution
- Qt deployment required by tests
- Windows packaging
- Artifact presence

Additional validation infrastructure exists for AI-generated repair candidates, including build, package, patch, and workflow validation.

---

# 🔐 Security

Security is treated as an engineering concern throughout the project.

Current infrastructure includes compiler hardening options, sanitizer support where configured, repository policies for AI tooling, and controlled CI permissions.

A CodeQL configuration is present in the repository, but the active CI workflow is the authoritative source for which security checks currently execute.

VoidOne does not claim security certifications or absolute security guarantees unless explicitly documented.

---

# 🤝 Contributing

Contributions are welcome across:

- C++
- Qt / QML
- UI/UX
- Testing
- Documentation
- Performance
- Build systems
- CI/CD
- Security
- Developer tooling
- Platform support

For substantial changes, explain what changed, why it changed, how it was tested, and any compatibility, performance, or security considerations.

Keep changes focused, reviewable, and maintainable.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for project contribution guidance.

---

# 📚 Documentation

Additional documentation covers areas such as:

- Build and development
- Architecture
- CI/CD
- Release engineering
- AI-assisted repair infrastructure
- Security
- Translation
- Performance

The repository remains the source of truth for current implementation, supported tooling, CI behavior, and release configuration.

---

# 🏁 Stable Release Criteria

Stable is an engineering milestone, not simply a version label.

Before Stable, VoidOne aims to establish:

- Reliable core functionality
- Reliable installation and upgrades
- Runtime stability
- Expanded automated testing
- Performance benchmarks
- Security validation
- Complete release documentation
- Release candidate cycles

> **Stable is a milestone earned through engineering — not a label assigned by schedule.**

---

# 📜 License

VoidOne is distributed under the **MIT License**.

See [`LICENSE`](LICENSE) for the complete license text.

---

<div align="center">

### **Your Games. Your Hardware. Your AI. Your Rules.**

**Built by a gamer. Engineered like a platform. Built in the open.**

### ♾️ Free & Open Source
### 🚫 No Ads. No Telemetry.
### 🔒 Your Data. Your Control.
### 🧠 Your AI. Your Choice.
### 🎮 Built by a Gamer. For Gamers.
### 🧪 Experimental Today. Stable When It's Ready.

**Open Source · Native · Modular · Player-Focused**

[⭐ Star VoidOne](https://github.com/VoidOne-App/VoidOne) ·
[📦 Releases](https://github.com/VoidOne-App/VoidOne/releases) ·
[🐛 Issues](https://github.com/VoidOne-App/VoidOne/issues) ·
[🤝 Contributing](https://github.com/VoidOne-App/VoidOne/blob/main/CONTRIBUTING.md)

</div>
