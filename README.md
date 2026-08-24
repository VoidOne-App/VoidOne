<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

# 🌌 VoidOne

### The Open-Source Native PC Gaming Platform Built Around Your Games — Not Around a Store

<p>
  <b>🇬🇧 English</b> •
  <a href="README.fa.md">🇮🇷 پارسی</a>
</p>

<p>
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml">
    <img src="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml/badge.svg?branch=main" alt="CI/CD" />
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases/latest">
    <img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?style=for-the-badge&logo=github&logoColor=white&label=Latest%20Release" alt="Latest Release" />
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/stargazers">
    <img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=for-the-badge&logo=github&logoColor=white&label=Stars" alt="GitHub Stars" />
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/VoidOne-App/VoidOne?style=for-the-badge&label=License" alt="MIT License" />
  </a>
</p>

<p>
  <img src="https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++23" />
  <img src="https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6.8" />
  <img src="https://img.shields.io/badge/QML-QtQuick-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="QML / Qt Quick" />
  <img src="https://img.shields.io/badge/SQLite-Local%20Storage-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/CMake-Build%20System-064F8C?style=for-the-badge&logo=cmake&logoColor=white" alt="CMake" />
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows and Linux" />
  <img src="https://img.shields.io/badge/License-MIT-FFD60A?style=for-the-badge" alt="MIT License" />
</p>

<br />

**One Library. Your Games. Your Hardware. Your Rules.**

<br />

<p>
  <a href="#-about">About</a> •
  <a href="#-vision">Vision</a> •
  <a href="#-principles">Principles</a> •
  <a href="#-current-capabilities">Current</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-engineering">Engineering</a> •
  <a href="#-security">Security</a> •
  <a href="#-releases">Releases</a> •
  <a href="#-roadmap">Roadmap</a> •
  <a href="#-build-from-source">Build</a> •
  <a href="#-contributing">Contributing</a>
</p>

</div>

---

# 👁️ About

**VoidOne** is an open-source native PC gaming platform built around one simple idea:

> **Your games should be the center of your gaming experience — not the stores distributing them.**

Modern PC gaming is fragmented across storefronts, launchers, installation directories, manifests, configuration files, metadata providers, background processes, and individual game executables.

VoidOne is being engineered as a native layer between the player and that fragmented environment.

The project combines a native **C++23** core with **Qt 6.8**, **QML / Qt Quick**, **SQLite**, **CMake**, and **Ninja** to create a foundation for a unified gaming experience.

VoidOne is intentionally designed to distinguish between:

- **Implemented** — functionality currently present in the repository.
- **In Progress** — functionality partially implemented or actively being developed.
- **Planned** — future capabilities and architectural direction.

This distinction is fundamental to the project.

> **VoidOne does not sell the future as the present.**

---

# 🎯 Vision

VoidOne is not intended to become another storefront.

It is intended to become a native layer between:

```text
┌──────────────────────────┐
│          PLAYER          │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│         VOIDONE          │
│   Native Gaming Layer    │
└────────────┬─────────────┘
             │
      ┌──────┼──────┐
      │      │      │
      ▼      ▼      ▼
   LIBRARY EXECUTION DATA
      │      │      │
      └──────┼──────┘
             │
             ▼
┌──────────────────────────┐
│     OPERATING SYSTEM     │
└──────────────────────────┘
```

The long-term objective is to give players a unified, local-first and extensible control layer over the games they already own and install.

VoidOne is **not** intended to bypass DRM, licensing requirements, authentication requirements, or legitimate platform dependencies.

If a game requires another platform to operate legitimately, VoidOne respects that requirement.

---

# 🛡️ Gamer-to-Gamer Commitment

VoidOne is built **by a gamer, for gamers**.

That is not simply a marketing phrase.

It defines the direction of the project.

## ♾️ Free & Open Source

VoidOne is released under the **MIT License**.

The project is intended to remain freely available and open-source.

No mandatory subscription is planned for the core platform.

No closed ecosystem is being built around the player.

## 🚫 No Ads. No Telemetry.

VoidOne is not designed around advertising or behavioral tracking.

The core philosophy is simple:

> **You use VoidOne to manage your games. You should not become the product.**

## 🔒 Local-First Data

VoidOne uses local persistence for core application data.

The project favors keeping player-owned information under local control whenever technically practical.

This includes areas such as:

- Game library data
- Application settings
- Game configuration
- Local profiles
- Backup data
- Local statistics

## ⚡ Lightweight by Design

Performance is a first-class engineering concern.

One long-term target is:

> **Idle memory usage below 50 MB.**

This is an **engineering target**, not a guaranteed specification of every current release.

The goal is to avoid unnecessary:

- Background services
- Persistent processes
- Heavy runtimes
- Resource-hungry components
- Hidden workloads

## 🎮 Built Around the Player

VoidOne is designed around:

- Hardware ownership
- Privacy
- Local control
- Open-source development
- Game ownership
- Extensibility
- Transparent engineering

> **The platform should work for the player — not the other way around.**

---

# 🧭 Principles

## 🧱 Native First

Prefer native technologies and operating-system capabilities when they provide meaningful advantages in:

- Performance
- Integration
- Maintainability
- System control

## 🔒 Privacy by Design

Avoid unnecessary collection, tracking, or transmission of player information.

## 💾 Local First

Core functionality should remain usable without requiring an unnecessary remote backend.

## ⚡ Lightweight by Design

Every dependency, process, service and runtime component should justify its resource cost.

## 🌐 Open by Design

The project should remain:

- Transparent
- Inspectable
- Modifiable
- Contributor-friendly

## 📐 Evidence Over Marketing

Technical claims should be supported by:

- Implementation
- Testing
- Benchmarks
- Reproducible measurements
- Repository evidence

## 🎮 User Ownership

Players should retain control over their:

- Games
- Data
- Configuration
- Profiles
- Experience

---

# ✅ Current Capabilities

This section describes functionality that is actually represented in the current repository.

Future concepts are intentionally excluded from this section.

---

## 🖥️ Native C++ / Qt Application

VoidOne currently uses:

- **C++23**
- **Qt 6.8**
- **Qt Quick / QML**
- **SQLite**
- **CMake**
- **Ninja**

The application is structured around a native C++ core with a QML presentation layer.

---

## 🎨 Qt Quick / QML Interface

The graphical layer is built using Qt Quick and QML.

The repository contains QML views for areas including:

- Main application UI
- Library views
- Game details
- Settings
- Theme configuration
- About information
- Backup management
- Search and filtering interfaces

The QML layer communicates with native C++ application components through Qt's integration mechanisms.

---

## 🎮 Steam Library Discovery

VoidOne currently contains a Steam library scanner.

The scanner is designed to inspect local Steam installation data and discover installed games.

The implementation works with Steam library metadata and app manifests to identify installed titles.

This provides the foundation for future provider-aware library aggregation.

### Current status

**Implemented foundation.**

This should not be interpreted as a complete multi-store integration system.

---

## 💾 SQLite Persistence

VoidOne uses SQLite for local application persistence.

The repository contains a database layer and game model for managing locally stored application/game information.

SQLite provides a lightweight embedded storage layer without requiring a mandatory database server.

---

## 🔎 Game Search & Filtering Foundation

The application contains library-oriented search/filtering functionality in its current UI architecture.

The long-term goal is to expand this into richer library intelligence and metadata normalization.

---

## 💾 Local Backup & Recovery Foundation

VoidOne includes a local save-backup system.

The current implementation supports backup-related functionality including:

- Save backup operations
- Backup restoration
- Backup management
- Automatic save-backup configuration
- Configurable backup intervals
- Backup location handling
- Backup retention controls

The backup system is **local**.

It should not be confused with cloud synchronization.

> **VoidOne currently provides a local backup foundation, not a cloud-save service.**

---

## ⚙️ Application Settings

VoidOne contains a native settings system covering application configuration.

The current architecture provides configuration areas for functionality such as:

- Application behavior
- Library configuration
- Backup behavior
- Theme configuration
- Logging
- General preferences

---

## 🎨 Theme Infrastructure

The project contains theme-related infrastructure in the application and QML layers.

The current system provides the foundation for customizable application appearance.

The larger dynamic theme ecosystem remains future work.

---

## 🔍 Logging & Diagnostics

VoidOne contains a logging system designed for development and troubleshooting.

The application supports persistent logging and log-management behavior including log rotation.

This provides a practical foundation for:

- Debugging
- Runtime diagnosis
- Crash investigation
- Development troubleshooting

---

## 🔐 Single-Instance Protection

The application contains a single-instance mechanism.

This prevents multiple normal VoidOne application instances from running simultaneously when the application is configured to enforce single-instance behavior.

---

## 🖥️ Command-Line Options

The application includes command-line handling for application-level execution behavior.

This provides a foundation for future automation and integration scenarios.

---

# 🏗️ Architecture

VoidOne is structured as a layered native application.

## Current Architecture

```text
┌──────────────────────────────────────────┐
│              Qt / QML UI                 │
│                                          │
│  Views • Settings • Library • Themes     │
└────────────────────┬─────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────┐
│          C++ Application Layer           │
│                                          │
│ Application Services • Models • State    │
└────────────────────┬─────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────┐
│             VoidOne Core                 │
│                                          │
│ Database • Scanner • Backup • Utilities  │
└─────────────┬────────────────┬───────────┘
              │                │
              ▼                ▼
       ┌─────────────┐  ┌───────────────┐
       │   SQLite    │  │ Windows / OS  │
       │   Storage   │  │    APIs       │
       └─────────────┘  └───────────────┘
```

The project also separates reusable native functionality into a dedicated core target where appropriate.

---

# 🧩 Core Components

The repository currently contains native components for areas including:

```text
src/
├── core/
│   ├── database/
│   ├── models/
│   ├── scanner/
│   └── backup/
│
├── ui/
│   └── QML / Qt Quick interface
│
└── main.cpp
```

The exact source layout may evolve as the project grows.

The repository itself remains the authoritative source for the current structure.

---

# 🧠 Engineering Architecture

The architectural direction follows several rules:

### Separation of Concerns

UI code should not unnecessarily contain core business logic.

### Native Core

Core functionality should remain in C++ where system-level control and performance matter.

### Declarative UI

QML is used where declarative UI provides clear advantages.

### Local Persistence

Application data is persisted locally through SQLite and local filesystem storage where appropriate.

### Extensible Foundation

Components are structured to allow future provider integrations and platform services.

---

# 🧰 Technology Stack

| Technology | Role |
| :--- | :--- |
| **C++23** | Native application and systems development |
| **Qt 6.8** | Application framework |
| **QML / Qt Quick** | User interface |
| **SQLite** | Local persistence |
| **CMake** | Build configuration |
| **Ninja** | Build execution |
| **CTest** | Test infrastructure where configured |
| **GitHub Actions** | CI/CD |
| **CodeQL** | Security analysis |
| **Cppcheck** | Static analysis |
| **AddressSanitizer** | Runtime memory diagnostics |
| **MSVC** | Windows compiler/toolchain |
| **NSIS** | Windows installer packaging |
| **WiX Toolset** | MSI packaging |
| **Ollama** | Local AI engineering infrastructure |
| **Gemini** | AI-assisted engineering |
| **Qwen2.5-Coder** | AI-assisted code repair |

---

# 🤖 AI-Assisted Engineering

VoidOne contains an **AI Repair** engineering workflow.

This is a developer-facing automation system.

It is **not a player-facing AI feature**.

The goal is to reduce the amount of repetitive work required to diagnose CI failures and prepare candidate fixes.

The infrastructure can integrate with:

- GitHub Actions
- Build logs
- C++ tooling
- Qt tooling
- Gemini
- Qwen2.5-Coder
- Ollama
- Automated validation

Conceptually:

```text
                ┌─────────────────┐
                │    CI Failure   │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ Failure Analysis│
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │  AI-Assisted    │
                │     Repair      │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ Candidate Patch │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ Build / Checks  │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │ Automated Tests │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │  Human Review   │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────────┐
                │     Merge       │
                └─────────────────┘
```

AI-generated changes are not automatically trusted.

They must remain subject to:

- Build validation
- Tests
- Static analysis
- Security checks
- Human review
- Repository policy

> **AI accelerates engineering. It does not replace engineering ownership.**

---

# 🔄 CI/CD & Engineering Infrastructure

VoidOne maintains an automated GitHub Actions engineering pipeline.

The CI infrastructure covers multiple stages of the development lifecycle.

Depending on the workflow path, this includes:

- C++ compilation
- Debug builds
- Release builds
- Static analysis
- CodeQL analysis
- Cppcheck
- Sanitizer validation
- Testing
- Qt deployment
- Windows packaging
- Portable ZIP generation
- Installer generation
- SHA-256 checksum generation
- Release artifact publishing
- Automated release-related operations

The workflow is also designed to support scheduled and manually triggered validation.

The workflow files inside:

```text
.github/workflows/
```

remain the authoritative source for exact CI behavior.

---

# 🛡️ Security Engineering

Security is treated as part of the development lifecycle.

Current engineering infrastructure includes security-oriented validation such as:

- **GitHub CodeQL**
- **Cppcheck**
- Compiler/linker hardening
- Sanitizer validation
- Automated build validation
- Artifact checksum generation

The Windows release configuration includes hardening options such as:

```text
/NXCOMPAT
/DYNAMICBASE
/GUARD:CF
/HIGHENTROPYVA
```

These mechanisms are intended to improve the security posture of produced binaries.

VoidOne does **not** claim absolute security or security certification.

Security remains an ongoing engineering process.

---

# 📦 Packaging

The Windows release infrastructure supports packaging through technologies including:

- **NSIS**
- **WiX Toolset**
- Qt deployment tooling
- Portable ZIP packaging

Release automation can also generate SHA-256 checksums for published artifacts.

This provides users with a mechanism to verify downloaded release files.

---

# 🪟 Platform Support

## Windows

Windows is currently the primary development and packaging platform.

The CI infrastructure is centered around Windows x64 builds using MSVC and Qt.

Supported development environments are expected to include:

- Windows 10 / 11
- Visual Studio / MSVC
- Qt 6.8
- CMake
- Ninja
- Git

## Linux

Linux is part of the project's cross-platform direction.

However, Linux should not currently be interpreted as having the same release and packaging maturity as Windows.

Linux development support may evolve as the project progresses.

## macOS

macOS is not currently part of the primary build and packaging pipeline.

---

# 🔭 Future Platform Direction

The following features represent **planned, long-term, or incomplete functionality**.

They are intentionally not presented as current capabilities.

---

## 👻 Ghost Launch

A future execution architecture intended to provide greater control over game launching.

Potential capabilities include:

- Direct executable execution where appropriate
- Custom launch arguments
- Environment configuration
- Per-game launch profiles
- Process lifecycle management
- Runtime state tracking
- Background-process policies
- Orphan-process detection

Concept:

```text
Player
  │
  ▼
VoidOne
  │
  ▼
Execution Layer
  │
  ▼
Game Process
```

Ghost Launch is not intended to bypass:

- DRM
- Licensing
- Authentication
- Legitimate platform requirements

---

# ⚙️ Intelligent Process Orchestration

Future process-management capabilities may include:

- Child-process awareness
- Process lifecycle tracking
- CPU priority profiles
- Background workload policies
- Orphan-process detection
- Resource-aware launch profiles
- Per-game execution policies

The goal is to manage the runtime environment rather than simply launching a process.

---

# 🧩 Multi-Store Aggregation

A unified multi-provider game library is part of the long-term direction.

Potential providers include:

- Steam
- Epic Games
- GOG
- EA App
- Local installations
- Additional providers

Potential capabilities:

- Installation discovery
- Manifest parsing
- Provider-aware launching
- Duplicate detection
- Game identity normalization
- Metadata normalization

The objective is:

> **One library without creating another storefront.**

---

# 🖼️ Rich Metadata Engine

Future versions may provide a richer metadata system for:

- Cover artwork
- Hero banners
- Backgrounds
- Descriptions
- Genres
- Release dates
- Developer information
- Publisher information
- Ratings
- Platform information

The architecture is intended to favor:

- Local caching
- Asynchronous processing
- Non-blocking UI
- Failure-tolerant network operations

Metadata should enhance the experience without becoming mandatory for basic local functionality.

---

# 📊 Local Gaming Analytics

Future versions may introduce privacy-oriented local analytics.

Potential metrics include:

- Launch history
- Session duration
- Playtime
- Per-game statistics
- Local crash information
- Performance history
- Local trends

The guiding principle remains:

> **Useful analytics without turning the player into the product.**

---

# 🧰 Advanced Mod Platform

A future mod-management system may include:

- Mod profiles
- Virtual file mapping
- Non-destructive deployment
- Dependency management
- Conflict detection
- Load-order management
- Compatibility checks

Example:

```text
Game
├── Vanilla
├── Competitive
├── Graphics Overhaul
├── Experimental
└── Custom Profile
```

The goal is to allow multiple configurations without unnecessarily modifying the original game installation.

---

# 🎨 Next-Generation Interface

The future UI direction may include:

- Advanced QML interfaces
- Dynamic themes
- Artwork-driven libraries
- Responsive layouts
- Accessibility improvements
- Display scaling
- Optional animations
- Personalization
- RGB customization

Visual effects should justify their performance cost.

> **A premium interface is only useful when it remains responsive.**

---

# 🩺 Performance Diagnostics

Future diagnostic tooling may provide:

- Startup analysis
- Runtime measurements
- Memory diagnostics
- Process analysis
- Library scan profiling
- CPU utilization
- Performance history
- Per-game performance profiles
- Benchmarking

The objective is to make performance measurable rather than subjective.

---

# 💾 Advanced Backup & Recovery

The current project already contains a local backup foundation.

Future development may extend it with:

- Configuration backup
- Profile export/import
- Recovery snapshots
- Game-profile restoration
- Mod-profile backup
- Safer recovery workflows

Cloud synchronization is not presented as a current feature.

---

# 🔌 Extension Ecosystem

Long-term extensibility may include:

- Extension APIs
- Provider APIs
- Theme SDK
- Community extensions
- Custom integrations
- Developer tooling

Any extension architecture must consider:

- Security
- Stability
- Compatibility
- Performance
- Maintainability

---

# ⚡ Performance Goals

Performance is a core engineering objective.

The following are **targets**, not current guaranteed specifications:

| Metric | Long-Term Target |
| :--- | :--- |
| **Idle Memory** | `< 50 MB` |
| **Cold Startup** | `< 1.0s` |
| **Database Operations** | Sub-millisecond target |
| **UI Rendering** | 60+ FPS target |
| **Library Scanning** | Minimal UI blocking |

These values should only become official measured specifications after reproducible benchmarking.

A proper benchmark should document:

- Hardware
- CPU
- GPU
- RAM
- Storage
- Operating system
- Compiler
- Qt version
- VoidOne version
- Build configuration
- Background applications
- Test methodology

> **The goal is not to promise performance. The goal is to prove it.**

---

# 🗺️ Roadmap

VoidOne is being developed incrementally.

Roadmap items represent engineering direction rather than guaranteed delivery dates.

## Phase I — Native Foundation

- [x] C++23 application foundation
- [x] Qt / QML foundation
- [x] CMake build system
- [x] Native core architecture
- [x] SQLite persistence
- [x] Steam library scanning foundation
- [x] Local backup foundation
- [x] Application settings
- [x] Logging infrastructure
- [x] Single-instance protection
- [x] GitHub Actions CI/CD
- [x] CodeQL integration
- [x] Cppcheck integration
- [x] Sanitizer-oriented validation
- [x] Windows packaging pipeline
- [x] Release checksum generation
- [x] AI-assisted repair infrastructure

## Phase II — Library Intelligence

- [ ] Richer game discovery
- [ ] Improved installation detection
- [ ] Provider abstraction
- [ ] Game identity normalization
- [ ] Metadata normalization
- [ ] Library indexing improvements

## Phase III — Player Experience

- [ ] Advanced library UI
- [ ] Rich artwork
- [ ] Filtering and categorization
- [ ] Search improvements
- [ ] Personalization
- [ ] Accessibility improvements
- [ ] Advanced theme system

## Phase IV — Execution

- [ ] Ghost Launch
- [ ] Process lifecycle management
- [ ] Launch profiles
- [ ] Runtime configuration
- [ ] Process policies
- [ ] Local playtime tracking

## Phase V — Multi-Provider Platform

- [ ] Epic Games integration
- [ ] GOG integration
- [ ] EA App integration
- [ ] Additional providers
- [ ] Unified provider management

## Phase VI — Mod Platform

- [ ] Mod profiles
- [ ] Virtual file mapping
- [ ] Dependency management
- [ ] Conflict detection
- [ ] Load-order management
- [ ] Compatibility management

## Phase VII — Intelligence & Diagnostics

- [ ] Local gaming analytics
- [ ] Performance diagnostics
- [ ] Advanced benchmark tooling
- [ ] Automated failure diagnosis
- [ ] Advanced engineering automation

## Phase VIII — Ecosystem

- [ ] Extension APIs
- [ ] Theme SDK
- [ ] Provider APIs
- [ ] Community extensions
- [ ] Developer ecosystem

> **The roadmap describes direction — not promises.**

---

# 📈 Development Philosophy

VoidOne follows a simple development rule:

> **Build the foundation before selling the vision.**

That means:

1. Implement the core.
2. Validate it.
3. Test it.
4. Measure it.
5. Document it.
6. Then advertise it.

This is especially important for performance, security and platform-support claims.

---

# 🔨 Build From Source

VoidOne is primarily developed and packaged for Windows.

Linux remains part of the broader cross-platform direction.

Build requirements may change as the project evolves.

---

## 📋 Requirements

### Windows

Recommended:

- Windows 10 or Windows 11
- Visual Studio 2022 / MSVC
- Qt 6.8
- CMake
- Ninja
- Git

### Linux

Potential development environment:

- Recent Linux distribution
- GCC or Clang
- Qt 6
- CMake
- Ninja
- Git
- Required Qt/system development packages

---

# 📥 Clone

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
```

---

# ⚙️ Configure

## Windows

If Qt is discoverable by CMake:

```powershell
cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23
```

If Qt is not automatically discoverable:

```powershell
cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23 `
  -DCMAKE_PREFIX_PATH="C:\Qt\6.8.0\msvc2022_64"
```

Adjust the Qt path to match your installation.

## Linux

```bash
cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23
```

If Qt is installed in a custom location:

```bash
cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_PREFIX_PATH="$HOME/Qt/6.x.x/gcc_64"
```

---

# 🔨 Build

```bash
cmake --build build --parallel
```

---

# 🧪 Test

If CTest targets are configured in the current build:

```bash
ctest \
  --test-dir build \
  --output-on-failure
```

The repository's CI configuration remains the authoritative source for the exact automated test matrix.

---

# 🔍 Static Analysis

When `clang-tidy` is available:

```bash
cmake \
  -S . \
  -B build-analysis \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_CXX_CLANG_TIDY=clang-tidy
```

Then:

```bash
cmake --build build-analysis --parallel
```

---

# 🧪 Sanitizer Validation

For development environments that support AddressSanitizer, use the repository's configured sanitizer build where available.

Sanitizer validation is intended to detect memory-related problems during development and CI.

The CI workflow remains the authoritative source for the exact sanitizer configuration.

---

# 📦 Windows Packaging

The release pipeline currently supports Windows packaging through configured:

- NSIS definitions
- WiX definitions
- Qt deployment
- Portable ZIP packaging

The release lifecycle can include:

```text
Source
  │
  ▼
Configure
  │
  ▼
Compile
  │
  ▼
Validate
  │
  ▼
Qt Deployment
  │
  ▼
Package
  │
  ├───────────────┐
  ▼               ▼
Portable ZIP    Installer
  │               │
  └───────┬───────┘
          ▼
      SHA-256
          │
          ▼
     Release Asset
```

---

# 🔐 Verify Release Integrity

When a release provides a SHA-256 checksum, verify the downloaded artifact.

### PowerShell

```powershell
Get-FileHash .\VoidOne-Windows-x64-Portable-<version>.zip -Algorithm SHA256
```

Compare the generated hash with the checksum published for the exact same release artifact.

---

# 🚀 Releases

## Latest Release

<a href="https://github.com/VoidOne-App/VoidOne/releases/latest">
  <img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?style=for-the-badge&logo=github&logoColor=white&label=Latest%20Release" alt="Latest Release" />
</a>

### Latest Release

https://github.com/VoidOne-App/VoidOne/releases/latest

### All Releases

https://github.com/VoidOne-App/VoidOne/releases

Depending on the release configuration, published assets may include:

- Windows installer
- MSI package
- Portable ZIP
- SHA-256 checksum files

The repository's release workflow determines exactly which artifacts are generated for each release.

---

# 🧪 Testing & Validation

VoidOne treats validation as part of engineering rather than an afterthought.

Depending on repository configuration, validation can include:

- CMake configuration
- C++ compilation
- Debug builds
- Release builds
- CTest
- AddressSanitizer
- Cppcheck
- CodeQL
- QML validation
- Packaging validation
- Artifact validation
- Checksum generation

Contributors should validate changes relevant to the area they modify.

---

# 🐛 Reporting Bugs

When opening a bug report, include as much reproducible information as possible.

Useful information includes:

- Operating system
- OS version
- CPU
- GPU
- RAM
- Compiler
- Compiler version
- Qt version
- CMake version
- Build configuration
- VoidOne version
- Relevant logs
- Error messages
- Steps to reproduce

For runtime failures, attach relevant diagnostic output when possible.

> **A reproducible bug is dramatically easier to fix than a mysterious one.**

---

# 🤝 Contributing

Contributions are welcome.

You can contribute through:

- C++
- Qt / QML
- UI/UX
- Testing
- Documentation
- Bug reports
- Feature proposals
- Performance engineering
- Security improvements
- CI/CD
- Build tooling
- Cross-platform development

---

# 🌱 Contribution Workflow

Create a feature branch:

```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature
```

Make your changes.

Validate them locally.

Then:

```bash
git add .
git commit -m "Add your feature"
git push origin feature/your-feature
```

Open a Pull Request.

For substantial changes, explain:

- What changed
- Why it changed
- How it was tested
- Compatibility considerations
- Performance implications
- Security implications where applicable

Keep changes focused, reviewable and maintainable.

---

# 📐 Engineering Standards

## Evidence Over Marketing

Do not present unmeasured targets as measured results.

## Small Reviewable Changes

Prefer focused pull requests that are easy to understand and validate.

## Native First

Use native technologies when they provide meaningful advantages.

## Security by Default

Consider security during architecture and implementation.

## Human-Controlled Automation

AI and automation should assist developers while humans retain responsibility for final changes.

## Long-Term Maintainability

Code should remain understandable as the project grows.

## Respect the Player

Every feature should answer:

> **Does this give the player more value and control without unnecessarily taking something away?**

---

# 📚 Documentation

The repository is the primary source of truth for current implementation.

This includes:

- Source code
- CMake configuration
- GitHub Actions workflows
- Packaging definitions
- Release configuration
- Build requirements
- Current architecture

Roadmap items should not be interpreted as implemented functionality.

If documentation and implementation disagree, the implementation and CI configuration should be investigated first.

---

# 🗂️ Repository Structure

The project is organized around native application code, reusable core functionality, QML UI, automation and packaging.

A simplified representation:

```text
VoidOne/
├── .github/
│   ├── workflows/
│   └── ...
│
├── src/
│   ├── core/
│   │   ├── database/
│   │   ├── models/
│   │   ├── scanner/
│   │   └── backup/
│   │
│   ├── ui/
│   │   └── QML
│   │
│   └── main.cpp
│
├── tests/
├── CMakeLists.txt
├── LICENSE
├── README.md
└── README.fa.md
```

The structure is intentionally simplified.

For the exact current repository layout, inspect the repository tree.

---

# 📜 License

VoidOne is released under the **MIT License**.

See [`LICENSE`](LICENSE) for the complete license text.

---

# 🌌 Why VoidOne?

Because PC gaming should not require players to think about:

> Which launcher owns this game?

> Which storefront installed it?

> Where is the manifest?

> Where are my settings?

> Which background process is running?

> Where are my backups?

> Why does a game launcher need to consume so many resources?

The long-term answer is a unified native layer.

Not another store.

Not another locked ecosystem.

A platform built around the games.

---

<div align="center">

# 🌌 VoidOne

### Your Games. Your Hardware. Your Rules.

**Built by a gamer. Engineered like a platform. Built in the open.**

<br />

### ♾️ Free & Open Source

### 🚫 No Ads. No Telemetry.

### 🔒 Local-First & Player-Focused

### 🎮 Built by a Gamer. For Gamers.

<br />

<a href="https://github.com/VoidOne-App/VoidOne">
  <img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=for-the-badge&logo=github&logoColor=white&label=Star%20VoidOne" alt="Star VoidOne" />
</a>

<br />
<br />

**Open Source · Native · Modular · Local-First · Player-Focused**

<br />

> **The game is yours. The hardware is yours.  
> Your platform should feel like yours too.**

</div>
