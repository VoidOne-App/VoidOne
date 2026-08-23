<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne" width="100%" />

# 🌌 VoidOne

### The Open-Source Game Launcher Built Around Your Games — Not Around a Store

<p align="center">
  <b>🇬🇧 English</b> •
  <a href="README.fa.md">🇮🇷 پارسی</a>
</p>

<p align="center">
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/voidone-ci.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/voidone-ci.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&label=CI%2FCD&color=7C3AED" alt="CI/CD Status"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases">
    <img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?style=for-the-badge&logo=rocket&logoColor=white&color=FF2E63" alt="Latest Release"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/stargazers">
    <img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=for-the-badge&logo=github&color=FFD700" alt="GitHub Stars"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-FFD60A?style=for-the-badge" alt="MIT License"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++23"/>
  <img src="https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6.8"/>
  <img src="https://img.shields.io/badge/QML-QtQuick-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt QML"/>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-0078D6?style=for-the-badge" alt="Windows and Linux"/>
  <img src="https://img.shields.io/badge/SQLite-Local%20First-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite"/>
</p>

<br/>

<p align="center">

**One Library. Your Games. Your Hardware. Your Rules.**

</p>

<p align="center">
  <a href="#-what-is-voidone">About</a> •
  <a href="#-the-voidone-philosophy">Philosophy</a> •
  <a href="#-core-features">Features</a> •
  <a href="#-ghost-launch">Ghost Launch</a> •
  <a href="#-performance-first">Performance</a> •
  <a href="#-security--ci">Security</a> •
  <a href="#-roadmap">Roadmap</a> •
  <a href="#-build-from-source">Build</a>
</p>

</div>

<br/>

# 👁️ What is VoidOne?

**VoidOne** is an open-source PC game launcher and local game library manager built from the ground up with **modern C++23, Qt 6.8 and QML**.

The idea is simple:

> **Your games should be the center of your gaming PC — not the stores that distribute them.**

Modern PC gaming is fragmented across multiple launchers, accounts, background services, overlays, update systems and storefronts.

Steam.

Epic Games.

GOG.

EA.

Ubisoft.

Xbox.

Different launchers.  
Different interfaces.  
Different background services.  
Different update systems.

VoidOne is being built to bring your locally installed games into **one fast, lightweight, privacy-focused interface**.

Instead of making your gaming experience revolve around a storefront, VoidOne focuses on the thing that actually matters:

# 🎮 The Game.

---

# 🛡️ The VoidOne Philosophy

VoidOne wasn't born inside a corporate boardroom.

It started with a gamer asking a simple question:

> **Why should launching a game require an entire ecosystem running around it?**

We believe gaming software should respect the player.

Your hardware.

Your privacy.

Your storage.

Your bandwidth.

Your time.

And your freedom to use your own computer the way you want.

## ♾️ Free & Open Source

VoidOne is released under the **MIT License**.

No mandatory subscriptions.

No premium tier required for the core launcher.

No proprietary enterprise lock-in.

The source code is publicly available for inspection, contribution and improvement.

---

## 🔒 Privacy by Design

VoidOne follows a **local-first architecture**.

Your core library and configuration data are designed to remain on your own machine.

No advertising engine.

No unnecessary telemetry.

No hidden analytics system.

No requirement to make the core launcher dependent on cloud services.

---

## 📴 Offline-First

Offline operation is not an afterthought.

It is part of the architecture.

VoidOne is designed so that your locally installed games and local library remain useful even when an internet connection is unavailable.

Online services can enhance the experience with things such as artwork and metadata.

But:

> **The core launcher should not stop being useful just because the internet does.**

### Important distinction

VoidOne does **not** attempt to bypass DRM, authentication systems or platform security.

If a specific game legitimately requires an external service, that requirement remains a requirement.

The goal is to remove **unnecessary launcher overhead**, not to defeat security systems.

---

## ⚡ Performance Comes First

VoidOne is written in **C++23** and uses **Qt/QML** instead of a browser-based application runtime.

The engineering target is straightforward:

> **Keep VoidOne under 50 MB of RAM during normal idle operation.**

If we exceed that target, we don't simply call it acceptable.

We investigate it.

We profile it.

We optimize it.

And we try again.

### The 50 MB Rule

If VoidOne starts consuming RAM like a browser with 47 tabs open...

**we have failed the mission. 😂**

The objective isn't merely to make a small executable.

The objective is to make a launcher that spends system resources where they actually matter:

# 🎮 Your Game.

---

# 🎮 Gamer to Gamer

VoidOne is being built from the perspective of someone who actually plays games.

That means questioning things that have become "normal":

- Why does a launcher need hundreds of MB of RAM?
- Why does a simple game launch require multiple background services?
- Why should a local game library depend entirely on an online interface?
- Why should privacy be considered a premium feature?
- Why should users need six different applications just to manage their games?

VoidOne is our attempt to build a different answer.

> **"I stand with gamers, forever."**

---

# 🏗️ What VoidOne Is Building

VoidOne is not intended to become another storefront.

It is intended to become a **unified local gaming layer**.

A place where games from different platforms can coexist inside one interface.

```text
                    ┌─────────────────────┐
                    │       VoidOne       │
                    │   Unified Library   │
                    └──────────┬──────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
          ▼                    ▼                    ▼
     Steam Games         Epic Games           GOG Games
          │                    │                    │
          └────────────────────┼────────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │  Local Game Engine  │
                    └──────────┬──────────┘
                               │
                               ▼
                         🎮 Your Game
```

The long-term vision is to make the launcher **platform-aware without making it platform-dependent**.

---

# ✨ Core Features

## 🎮 Unified Game Library

Bring your games into one place.

VoidOne is being designed to discover locally installed games through:

- Steam installation data
- Epic Games metadata
- GOG installations
- Custom game directories
- Manually added executables
- Local manifests
- Platform-specific installation metadata

The goal:

> **One library instead of five launchers.**

---

# 👻 Ghost Launch

## The Long-Term Vision

One of VoidOne's most ambitious features is **Ghost Launch**.

The philosophy is simple:

> **If a game can legitimately run without unnecessary storefront overhead, don't make the player launch an entire storefront just to play it.**

The target architecture looks like this:

### Traditional

```text
Game
  ▲
  │
Store Launcher
  ▲
  │
Background Services
  ▲
  │
User
```

### VoidOne Vision

```text
User
  │
  ▼
VoidOne
  │
  ▼
Game
```

For games that can legitimately be launched directly, VoidOne aims to provide a clean direct-launch experience.

For games that genuinely require an external client, authentication or DRM service, VoidOne will respect those requirements.

### Ghost Launch Goals

- Direct executable launching
- Custom launch arguments
- Per-game launch profiles
- Working-directory configuration
- Environment variables
- Process monitoring
- Game-session detection
- Optional launcher minimization
- Resource-aware process management
- Cleanup of processes started by VoidOne

### What Ghost Launch is NOT

Ghost Launch is **not** intended to bypass:

- DRM
- Authentication
- Ownership verification
- Platform security
- Anti-cheat protections
- Paid licensing requirements

VoidOne is an open-source launcher, not a DRM circumvention tool.

Compatibility will always depend on the individual game and platform.

---

# 🧠 Intelligent Game Detection

VoidOne is being designed with a dedicated discovery engine capable of scanning local storage and known game installation structures.

The system will be able to identify:

- Installed games
- Executable paths
- Installation directories
- Platform information
- Launch configurations
- Game metadata
- Custom user-defined locations

Instead of manually adding hundreds of games:

> **Let VoidOne find them.**

---

# 🗂️ Local Game Database

VoidOne uses **SQLite** as the foundation for local game data.

The database can store information such as:

- Game paths
- Installation locations
- Launch settings
- User preferences
- Categories
- Play sessions
- Mod profiles
- Cached metadata

The database is local-first and designed for fast access.

No cloud database is required for the core library.

---

# 🎨 Modern QML Interface

VoidOne uses **Qt 6.8 / QML** to create a native desktop experience without relying on a browser-based application shell.

The interface is designed around:

- Hardware acceleration
- Smooth animations
- Responsive layouts
- Dark-first visual design
- Cyberpunk-inspired aesthetics
- Custom themes
- Keyboard navigation
- Game-focused information hierarchy

The goal isn't to create another website that happens to launch games.

The goal is to build a **native gaming application**.

---

# 🧩 Game Profiles

Every game should be configurable independently.

Future game profiles will support options such as:

- Launch arguments
- Working directory
- Environment variables
- Process priority
- Compatibility settings
- Custom artwork
- Custom categories
- Mod profiles
- Launcher behavior

This allows advanced users to configure individual games without changing global launcher settings.

---

# 🧩 Advanced Mod Architecture

Mod management is part of the long-term VoidOne vision.

Planned capabilities include:

### Mod Profiles

Create isolated configurations for different mod setups.

```text
Cyberpunk 2077

├── Vanilla
├── Visual Overhaul
├── Performance
└── Experimental
```

### Conflict Detection

Identify potential conflicts between installed modifications.

### Non-Destructive Deployment

Where technically appropriate, VoidOne can use virtualized or linked file structures rather than permanently overwriting original game files.

### Load Order

Manage mod priority and deployment order.

The objective:

> **Experiment with your games without destroying your original installation.**

---

# 📊 Local Gaming Analytics

VoidOne can provide optional local statistics around your own gaming activity.

Potential statistics include:

- Session duration
- Number of launches
- Last played
- Total playtime
- Game frequency
- Crash information

These statistics are intended to remain **local to the user's machine**.

Your gaming history should belong to you.

---

# 🌐 Optional Online Features

Offline-first does not mean online features are forbidden.

The internet can be used when it provides value.

For example:

- Game artwork
- Metadata
- Descriptions
- Screenshots
- Community information
- Optional integrations

VoidOne's philosophy is:

```text
Internet available?
        │
        ├── Yes ──► Enhance the experience
        │
        └── No ───► Keep the core experience working
```

Online services should enhance the launcher.

They should not define whether the launcher is usable.

---

# ⚡ Performance First

Performance is an engineering requirement.

Not a marketing slogan.

VoidOne is designed around several principles:

| Principle | Engineering Goal |
| :--- | :--- |
| Native C++ core | Minimize runtime overhead |
| Qt/QML interface | Modern native desktop rendering |
| SQLite | Fast local persistence |
| Async workers | Keep UI responsive |
| Lazy loading | Avoid unnecessary work |
| Caching | Reduce repeated operations |
| Minimal background work | Reduce idle resource usage |
| Target <50 MB idle RAM | Keep the launcher lightweight |

### Performance Targets

| Metric | VoidOne Target |
| :--- | :---: |
| Idle RAM | **< 50 MB** |
| Cold startup | **Sub-second target** |
| Background services | **Minimal** |
| Core library | **Local-first** |
| UI | **Hardware accelerated** |

> ⚠️ Performance figures are engineering targets and should be validated through reproducible benchmarks on real hardware before being treated as official benchmarks.

---

# 🔐 Privacy & Security

Privacy and security are built into the development process.

VoidOne's engineering stack includes:

- GitHub CodeQL
- Cppcheck
- AddressSanitizer
- Automated testing
- Dependency scanning
- Build verification
- SHA-256 checksums
- SBOM generation
- Build provenance

The goal is not to claim that software can ever be perfectly secure.

The goal is to make security **visible, testable and continuously reviewed**.

---

# 🔄 Automated CI/CD

VoidOne uses GitHub Actions as part of its development and release infrastructure.

The pipeline is designed around automated validation:

```text
                    ┌─────────────────────┐
                    │     Source Push     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Version Validation  │
                    └──────────┬──────────┘
                               │
              ┌────────────────┴────────────────┐
              ▼                                 ▼
     ┌─────────────────┐               ┌─────────────────┐
     │ Static Analysis │               │ Dependency Scan │
     │ CodeQL/Cppcheck │               │     Trivy       │
     └────────┬────────┘               └────────┬────────┘
              │                                 │
              └────────────────┬────────────────┘
                               ▼
                    ┌─────────────────────┐
                    │ Build & Test        │
                    │ C++ / Qt / CTest    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Package & Verify    │
                    │ ZIP / Installers    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Release & Artifacts │
                    └─────────────────────┘
```

### Current CI/CD Areas

- Semantic Version validation
- Windows build automation
- Qt deployment
- C++ compilation
- CTest
- Static analysis
- CodeQL
- Cppcheck
- Dependency scanning
- Build caching
- Installer generation
- Portable packaging
- SHA-256 checksums
- SBOM generation
- Build provenance
- Release automation

---

# 🤖 AI-Assisted CI Diagnostics

VoidOne also experiments with **AI-assisted development infrastructure**.

The long-term objective is to make CI failures easier to diagnose.

The workflow can be conceptually represented as:

```text
CI Failure
    │
    ▼
Log Collection
    │
    ▼
Error Classification
    │
    ▼
AI-Assisted Diagnosis
    │
    ▼
Potential Patch
    │
    ▼
Validation
    │
    ▼
Pull Request
    │
    ▼
Human Review
```

AI is treated as an engineering assistant.

Not as an authority.

No automated suggestion should be considered trusted simply because an AI model produced it.

---

# 📦 Windows Distribution

VoidOne is designed to support several Windows distribution formats.

| Package | Purpose |
| :--- | :--- |
| **NSIS EXE** | Standard user installation |
| **WiX MSI** | Native Windows Installer distribution |
| **Portable ZIP** | Zero-install portable usage |

### Portable Edition

The portable build is intended for users who want to:

- Run VoidOne without installation
- Keep it on another drive
- Use external storage
- Maintain a self-contained launcher directory

---

# 🔐 Release Integrity

Release artifacts can be accompanied by cryptographic integrity information such as:

- SHA-256 checksums
- SBOM
- Build provenance
- Artifact signatures where configured

Example:

```powershell
Get-FileHash VoidOne-Setup-x64-1.0.0.exe -Algorithm SHA256
```

Always verify release artifacts using information published alongside the official release.

---

# 🏗️ Architecture

VoidOne follows a layered architecture designed to keep the UI separate from the underlying game-management engine.

```text
┌─────────────────────────────────────────────┐
│                  QML / UI                   │
├─────────────────────────────────────────────┤
│             Application Layer               │
├─────────────────────────────────────────────┤
│        Game Library / Launch Engine         │
├─────────────────────────────────────────────┤
│       Platform Detection / Scanners         │
├─────────────────────────────────────────────┤
│        SQLite / Local Persistence           │
├─────────────────────────────────────────────┤
│        C++23 / OS Integration Layer         │
├─────────────────────────────────────────────┤
│       Windows / Linux Operating System      │
└─────────────────────────────────────────────┘
```

The separation allows the UI to evolve without forcing the core engine to depend on presentation logic.

---

# 🧰 Technology Stack

| Component | Technology |
| :--- | :--- |
| Core Language | C++23 |
| UI Framework | Qt 6.8 |
| UI Technology | QML / Qt Quick |
| Database | SQLite |
| Build System | CMake |
| Build Generator | Ninja |
| Testing | CTest |
| Memory Diagnostics | AddressSanitizer |
| Static Analysis | Cppcheck |
| Security Analysis | GitHub CodeQL |
| Dependency Scanning | Trivy |
| Windows Packaging | NSIS / WiX |
| CI/CD | GitHub Actions |

---

# 🗺️ Roadmap

VoidOne is still early.

That's intentional.

We're building the foundation before attempting to build the complete ecosystem.

## Phase 1 — Foundation

- [x] C++23 project foundation
- [x] Qt/QML architecture
- [x] CMake build system
- [x] Automated CI/CD
- [x] Static analysis
- [x] Security analysis
- [x] Testing infrastructure
- [x] Windows packaging infrastructure

## Phase 2 — Game Discovery

- [ ] Local game scanner
- [ ] Steam manifest parser
- [ ] Epic metadata detection
- [ ] GOG detection
- [ ] Custom directory scanning
- [ ] SQLite library database
- [ ] Automatic game discovery

## Phase 3 — Library Experience

- [ ] Full game library
- [ ] Game detail pages
- [ ] Search
- [ ] Filtering
- [ ] Categories
- [ ] Favorites
- [ ] Artwork management
- [ ] Metadata cache

## Phase 4 — Ghost Launch

- [ ] Direct game launching
- [ ] Launch profiles
- [ ] Process monitoring
- [ ] Launcher compatibility modes
- [ ] Resource management
- [ ] Game-session lifecycle management

## Phase 5 — Mod Engine

- [ ] Mod profiles
- [ ] Load-order management
- [ ] Conflict detection
- [ ] Non-destructive deployment
- [ ] Virtual filesystem architecture where appropriate

## Phase 6 — Ecosystem

- [ ] Plugin architecture
- [ ] Community themes
- [ ] Developer SDK
- [ ] Additional platform integrations
- [ ] Optional cloud features
- [ ] Cross-platform improvements

---

# 🧪 Development Status

VoidOne is currently under **active development**.

Some features described above are currently implemented.

Others are active development targets.

The project intentionally distinguishes between:

**Implemented**

**In Development**

**Planned**

This distinction matters.

We would rather build a smaller number of reliable features than fill the README with features that don't actually exist.

---

# 🔨 Build From Source

## Requirements

### Windows

- Windows 10 / 11
- MSVC 2022
- C++23 support
- Qt 6.8+
- CMake 3.25+
- Ninja
- Git

### Linux

- GCC 13+ or Clang 17+
- Qt 6.8+
- CMake 3.25+
- Ninja
- Git

---

## Clone the Repository

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
```

---

## Configure

```bash
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release
```

---

## Build

```bash
cmake --build build --parallel
```

---

## Run Tests

```bash
ctest --test-dir build --output-on-failure
```

---

# 🤝 Contributing

VoidOne is open source because the project should belong to its community.

Contributions are welcome in:

- C++
- Qt / QML
- UI/UX
- Game detection
- Platform integration
- Testing
- Security
- Documentation
- Performance optimization
- Localization

## Development Workflow

Create a feature branch:

```bash
git checkout -b feature/my-feature
```

Make your changes and test them.

Then:

```bash
git add .
git commit -m "feat: implement my feature"
git push origin feature/my-feature
```

Open a Pull Request.

CI will validate the changes automatically where applicable.

---

# 🧑‍💻 For Developers

VoidOne is also intended to be a practical engineering project.

It combines:

- Modern C++23
- Qt/QML
- Native process management
- SQLite
- CMake
- Cross-platform architecture
- Automated testing
- Static analysis
- Security tooling
- Windows packaging
- CI/CD automation

The project is intentionally built in the open so developers can inspect the architecture, learn from it and contribute to it.

---

# 🌍 Localization

VoidOne is intended to become accessible to gamers around the world.

Current documentation includes:

- 🇬🇧 English
- 🇮🇷 Persian

Additional translations can be contributed by the community.

---

# 📜 License

VoidOne is released under the **MIT License**.

```text
+--------------------------------------------------------------+
|                    [ V O I D O N E ]                         |
+--------------------------------------------------------------+
| Open Source • MIT License                                   |
| Modern C++23 • Qt 6.8 / QML                                 |
| Built for gamers. Built in the open.                       |
+--------------------------------------------------------------+
```

See [`LICENSE`](LICENSE) for the complete license text.

---

# ❓ Why VoidOne?

Because launching a game shouldn't feel like launching an operating system.

Because a launcher shouldn't need hundreds of megabytes of memory just to display a library.

Because your games shouldn't be scattered across six different applications.

Because privacy shouldn't be a premium feature.

Because offline capability shouldn't be treated as a luxury.

Because open-source software should be able to compete on:

**Performance.**

**Privacy.**

**Design.**

**Freedom.**

And because sometimes...

> **We just want to click PLAY and play the damn game. 🎮**

---

# 🌌 The Vision

VoidOne isn't trying to become another Steam.

It isn't trying to become another Epic Games Launcher.

It isn't trying to replace every platform.

The vision is different.

### Build the layer that sits above them.

A lightweight, open-source, local-first gaming environment where your games can live together regardless of where they came from.

```text
                ┌──────────────────────┐
                │       GAMER          │
                └──────────┬───────────┘
                           │
                           ▼
                ┌──────────────────────┐
                │       VOIDONE        │
                │                      │
                │  Library • Launch    │
                │  Profiles • Mods     │
                │  Local Data          │
                └──────────┬───────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
        Steam            Epic              GOG
          │                │                │
          └────────────────┼────────────────┘
                           │
                           ▼
                     🎮 YOUR GAMES
```

---

<div align="center">

# 🌌 VoidOne

### Your Games. Your Hardware. Your Rules.

**Open Source. Offline-First. Performance-Driven.**

<br/>

**Forged by a gamer. Built for gamers.**

<br/>

<a href="https://github.com/VoidOne-App/VoidOne">
  <img src="https://img.shields.io/badge/⭐_Star_VoidOne_on_GitHub-FFD700?style=for-the-badge&logo=github&logoColor=black" alt="Star VoidOne on GitHub"/>
</a>

<br/><br/>

<sub>
Built with ❤️, C++23, Qt/QML and a ridiculous obsession with performance.
</sub>

</div>
