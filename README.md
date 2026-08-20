
<div align="center">

# 🌌 VoidOne

**Next-Generation, Open-Source PC Game Launcher & Library Manager**

<p align="center">
  <b>English</b> •
  <a href="README.fa.md">پارسی</a>
</p>

[![VoidOne CI/CD](https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/c-cpp.yml?branch=main&style=for-the-badge&logo=github&label=CI/CD)](https://github.com/VoidOne-App/VoidOne)
[![CodeQL Security](https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/codeql.yml?branch=main&style=for-the-badge&logo=github&label=CodeQL)](https://github.com/VoidOne-App/VoidOne)
[![C++23](https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus)](https://en.cppreference.com/w/cpp/23)
[![Qt 6.8](https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt)](https://www.qt.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <a href="#-about">About</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-tech-stack--architecture">Tech Stack</a> •
  <a href="#-building-from-source">Building</a> •
  <a href="#-autonomous-ai-repair-system">AI Engine</a> •
  <a href="#-engineering-roadmap">Roadmap</a> •
  <a href="#-license">License</a>
</p>

---

</div>

## 👁️ About VoidOne

**VoidOne** is a blazing-fast, lightweight, open-source PC game launcher engineered with modern **C++23** and **Qt 6 / QML**. Built as a unified ecosystem for PC gamers, VoidOne bridges the gap between fragmented game distribution platforms (Steam, Epic Games, GOG, Xbox) and local execution—delivering a cyberpunk-inspired, highly customizable dashboard without the telemetry bloat.

The application operates with near-zero idle resource utilization, prioritizing high frame rates and instant responsiveness over bloated background services. By decoupling the presentation layer from low-level execution logic, VoidOne guarantees seamless scaling across diverse hardware configurations while maintaining a completely privacy-respecting footprint.

> ⚠️ **Development Status:** VoidOne is under active early-stage development. Core architecture and APIs are evolving rapidly.

---

## ✨ Key Features

### 🎮 Unified Game Aggregator
* **Auto-Discovery Engine:** Systematically scans local storage drives, custom directory trees, and external platform manifests (Steam VDF, Epic AppData, GOG Galaxy SQLite) to automatically populate a master game registry.
* **Rich Metadata Enrichment:** Asynchronously fetches high-resolution cover artwork, panoramic hero images, metacritic ratings, release timelines, and publisher details via cached API connections.
* **Session Analytics & Telemetry-Free Metrics:** Localized tracking of per-game execution sessions, playtime accumulation, launch frequency, and personal usage trends stored entirely within an encrypted local database.

### 🎨 Cyberpunk QML Interface
* **Hardware-Accelerated Visuals:** High-performance QML/QtQuick presentation layer backed by direct GPU rendering, supporting fluid 60+ FPS animations, hardware shaders, and customizable particle effects.
* **Granular Customization:** Modular UI ecosystem featuring dynamic theme switching, layout restructuring, custom font scaling, and native dark mode integration.

### 🧩 Integrated Mod Engine
* **Profile Management:** Create isolated, per-game mod configurations with atomic, single-click toggle states.
* **Load Order Resolution:** Advanced dependency verification, load hierarchy prioritization, and non-destructive virtual filesystem linkage for active mod files.

### 🤖 Self-Healing CI/CD Pipeline
* **Automated AI Remediation:** Multi-agent LLM infrastructure (Gemini 2.5 Pro Lead Engine coupled with local Qwen2.5-Coder instances) that parses build logs, pinpoints C++/CMake compilation failures, generates code patches, and submits automated Pull Requests.

---

## ⚙️ Tech Stack & Architecture

| Component | Technology | Purpose & Implementation |
| :--- | :--- | :--- |
| **Core Engine** | C++23 | Low-overhead system calls, asynchronous process management, memory optimization |
| **GUI Framework** | Qt 6.8 / QML | Hardware-rendered, declarative user interface with dynamic component lifecycle |
| **Database Layer** | SQLite3 | Thread-safe, embedded relational database for game manifests and application state |
| **Build System** | CMake 3.25+ / Ninja | Modular, multi-config cross-platform compilation pipeline |
| **OS Integration** | WinAPI / Linux D-Bus | Direct process spawning, privilege elevation handling, system tray integrations |
| **Automation / CI** | GitHub Actions | Parallelized cross-platform matrix builds, static analysis, CodeQL security auditing |

---

## 🔨 Building from Source

### Toolchain Prerequisites
* **Compiler:** 
  * Windows: MSVC 2022 (v17.8+) with C++23 standard library support
  * Linux: GCC 13+ or Clang 17+ with libc++ / libstdc++ implementation
* **Framework:** Qt 6.8+ (Desktop Development Setup, QtQuick, and QML modules)
* **Build Suite:** CMake 3.25 or higher, Ninja Build System, Git 2.40+

### Step-by-Step Compilation

```bash
# 1. Clone the repository and submodules
git clone [https://github.com/VoidOne-App/VoidOne.git](https://github.com/VoidOne-App/VoidOne.git)
cd VoidOne

# 2. Configure project with C++23 flags and Ninja generator
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23

# 3. Build optimized binaries in parallel
cmake --build build --config Release --parallel

🤖 Autonomous AI Repair System
VoidOne features an automated self-healing CI pipeline designed to diagnose build regressions instantly:
+-------------------+      +-----------------------+      +-----------------------+
|  CI Build Fail    | ---> |  Gemini 2.5 Pro Lead  | ---> |  Local Qwen2.5 Coder  |
| (GitHub Workflow) |      | (Diagnosis & Patch)   |      | (Fallback Inspector)  |
+-------------------+      +-----------------------+      +-----------------------+
                                                                      |
                                                                      v
                                                          +-----------------------+
                                                          | Auto Draft Pull Req   |
                                                          +-----------------------+

🗺️ Engineering Roadmap
 * [x] Phase 1: Core Foundation — CMake C++23 build harness, Qt 6.8/QML scaffolding, automated cross-compilation CI pipelines.
 * [ ] Phase 2: Database & Scanning Engine — Thread-safe SQLite database schema, multi-threaded disk scanners, manifest parsing algorithms.
 * [ ] Phase 3: Storefront Connectors — Native API and filesystem hooks for Steam, Epic Games Launcher, GOG Galaxy, and manual executables.
 * [ ] Phase 4: Advanced Mod Engine — Dynamic plugin loader, mod dependency graph resolution, virtual filesystem overlay mechanics.
 * [ ] Phase 5: Ecosystem Expansion — Customizable QML theme development SDK, RGB hardware synchronization (OpenRGB), cloud configuration sync.
👨‍💻 Project Background
VoidOne originated as an ambitious initiative to build a modern, high-performance, bloat-free alternative to traditional PC game launchers. The project serves as a practical implementation platform for exploring modern low-level system design patterns in C++23 alongside declarative UI design via Qt 6 / QML. Artificial intelligence is utilized as a collaborative pair-programming tool during architecture drafting and automated testing, with all code subject to manual auditing, profiling, and iterative optimization.
🤝 Contributing
Contributions are fundamental to the growth of open-source software. Whether fixing bugs, refining UI components, or implementing store integration logic, your efforts are welcome.
 * Fork the Project Repository
 * Create your Feature Branch (git checkout -b feature/NewFeature)
 * Commit your Changes (git commit -m 'feat: implement new game scanner')
 * Push to your Branch (git push origin feature/NewFeature)
 * Submit a detailed Pull Request
📄 License
+--------------------------------------------------------------+
|                    [ V O I D O N E   E N G I N E ]           |
+--------------------------------------------------------------+
| Copyright (c) 2026 VoidOne-App Core Team                     |
| Repo: [https://github.com/VoidOne-App/VoidOne](https://github.com/VoidOne-App/VoidOne)                 |
| Tech: Modern C++23 & Qt 6 / QML                              |
+--------------------------------------------------------------+

VoidOne is released under the terms of the MIT License. For complete terms and permissions, consult the LICENSE file in the repository root.
<div align="center">
<sub>Engineered with precision and modern C++23 by the VoidOne-App Core Team.</sub>
</div>

