<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

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
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Platform Support"/>
  <img src="https://img.shields.io/badge/SQLite-Local%20First-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite"/>
</p>

<br/>

**One Library. Your Games. Your Hardware. Your Rules.**

<br/>

<p align="center">
  <a href="#-what-is-voidone">About</a> •
  <a href="#-philosophy">Philosophy</a> •
  <a href="#-core-features">Features</a> •
  <a href="#-ghost-launch">Ghost Launch</a> •
  <a href="#-performance-first">Performance</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-roadmap">Roadmap</a> •
  <a href="#-build-from-source">Build</a>
</p>

</div>

---

## 👁️ What is VoidOne?

**VoidOne** is a high-performance, open-source PC game launcher and local library manager engineered from the ground up using **modern C++23, Qt 6.8, and QML**.

Modern PC gaming is fragmented across dozens of storefronts, background telemetry services, heavy embedded web browsers, and intrusive launchers (Steam, Epic Games, GOG, EA, Ubisoft, Xbox).

VoidOne decouples your games from storefront bloat, uniting your locally installed titles under one fast, privacy-respecting, native UI.

> **Your games should be the focal point of your system — not the stores distributing them.**

---

## 🛡️ Philosophy

VoidOne is built on strict engineering principles designed to respect the player's system:

* **♾️ Free & Open Source:** Licensed under MIT. No mandatory subscriptions, telemetry, or hidden paywalls.
* **🔒 Local-First & Private:** Your game library, play history, and settings stay on your machine in a local SQLite database.
* **📴 Offline-First Architecture:** Core functionality works without an active internet connection. Online services (artwork, metadata) enhance the experience but are never hard requirements.
* **⚡ Native Performance (The 50 MB RAM Rule):** Built as a compiled C++/Qt application—**not** an Electron or Chromium container. The goal is to keep idle memory consumption **under 50 MB RAM**.

> *Note:* VoidOne does **not** bypass DRM or platform authentication. If a game legally requires a third-party client or DRM service, VoidOne respects that dependency while minimizing unnecessary launcher overhead.

---

## 🏗️ System Vision

VoidOne acts as a **unified local management layer** above store platforms:

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
                    │ Local Launch Engine │
                    └──────────┬──────────┘
                               │
                               ▼
                          🎮 Your Game
```

---

## ✨ Core Features

### 🎮 Unified Local Library
Automatically detects installed games across various storefronts and directories:
* Steam VDF manifests & installation paths
* Epic Games Launcher manifest files
* GOG Galaxy registry entries
* Custom executable paths & manually configured directories

### 👻 Ghost Launch Architecture
Where permissible, VoidOne launches game binaries directly without spawning heavy storefront GUIs in the background.

```text
Traditional Flow:  User ──► Store Launcher ──► Background Services ──► Game
VoidOne Target:    User ──► VoidOne ──► Game Binary
```

* Process tracking & session life-cycle monitoring
* Custom environment variables & per-game launch arguments
* Automatic post-game process cleanup and launcher state restoration

### 🎨 Native QML User Interface
* Fully hardware-accelerated fluid UI powered by Qt Quick
* Dark-first, high-density dashboard UI designed for desktop users
* Keyboard and controller navigation support

### 🧩 Advanced Mod Architecture (Planned)
* Virtualized non-destructive mod deployment
* Per-game mod profiles (e.g., Vanilla, Visuals, Experimental)
* Conflict detection and load-order management

---

## ⚡ Performance Specifications

| Metric | Target | Technical Mechanism |
| :--- | :--- | :--- |
| **Idle RAM** | `< 50 MB` | Native C++ memory management, no Chromium runtime |
| **Startup Time** | `< 1.0s` | Lazy UI initialization & asynchronous C++ workers |
| **Database Read** | Sub-millisecond | SQLite with optimized local indexes |
| **Rendering** | 60+ FPS | Qt Quick scene graph hardware acceleration |

---

## 🏗️ Architecture

VoidOne enforces strict decoupling between the backend process engine, storage persistence layer, and the visual QML layer:

```text
┌─────────────────────────────────────────────┐
│              QML / Qt Quick UI              │
├─────────────────────────────────────────────┤
│         C++ Application / ViewModels        │
├─────────────────────────────────────────────┤
│       Game Discovery & Ghost Engine         │
├─────────────────────────────────────────────┤
│      Platform Scanners (Steam, GOG, Epic)   │
├─────────────────────────────────────────────┤
│            SQLite Persistence Layer         │
├─────────────────────────────────────────────┤
│          C++23 OS Abstraction Layer         │
├─────────────────────────────────────────────┤
│            Windows / Linux Kernel           │
└─────────────────────────────────────────────┘
```

---

## 🧰 Tech Stack

* **Language:** C++23 (MSVC 2022 / GCC 13+ / Clang 17+)
* **UI Framework:** Qt 6.8 (QML / Qt Quick)
* **Database:** SQLite 3
* **Build System:** CMake 3.25+ & Ninja
* **Quality Assurance:** AddressSanitizer, Cppcheck, GitHub CodeQL, Trivy
* **CI/CD:** GitHub Actions (Windows/Linux automated builds)

---

## 🗺️ Roadmap

- [x] **Phase 1: Foundation**
  - [x] C++23 CMake project scaffolding
  - [x] Qt 6.8 QML engine integration
  - [x] Automated multi-platform CI/CD pipeline
  - [x] CodeQL & static analysis integration

- [ ] **Phase 2: Discovery & Persistence** 🟡 *(Active)*
  - [x] SQLite local database integration
  - [ ] Steam VDF parser implementation
  - [ ] Epic & GOG installation detection
  - [ ] Custom executable scanner

- [ ] **Phase 3: Library & UX** ⚪
  - [ ] Hardware-accelerated grid/list views
  - [ ] Metadata & grid artwork caching
  - [ ] Filtering, tags, and category support

- [ ] **Phase 4: Ghost Launch Engine** ⚪
  - [ ] Direct execution engine & process tracking
  - [ ] Environment variable & arguments editor
  - [ ] Playtime tracking & local statistics

---

## 🔨 Build From Source

### Prerequisites

* **C++23 Compatible Compiler:** MSVC v19.38+, GCC 13+, or Clang 17+
* **Qt Framework:** Qt 6.8+ (Components: `QtQuick`, `QtQml`, `QtSql`)
* **Build Tools:** CMake 3.25+ and Ninja

### Build Steps

```bash
# 1. Clone the repository
git clone [https://github.com/VoidOne-App/VoidOne.git](https://github.com/VoidOne-App/VoidOne.git)
cd VoidOne

# 2. Configure project (Specify Qt path if not in standard environment)
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="C:/Qt/6.8.0/msvc2022_64"  # Adjust Qt path accordingly

# 3. Compile binaries
cmake --build build --config Release --parallel

# 4. Run tests
ctest --test-dir build --output-on-failure
```

---

## 🤝 Contributing

Contributions are welcomed! Whether it is C++ core optimizations, QML UI improvements, scanner logic, or documentation.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

<div align="center">

**VoidOne** — *Built for performance. Built in the open.*

</div>
