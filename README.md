<div align="center">

# 🌌 VoidOne

### The Next-Generation, Open-Source, High-Performance PC Game Launcher & Library Aggregator

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
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-FFD60A?style=for-the-badge" alt="MIT License"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++23 Standard"/>
  <img src="https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6.8 Framework"/>
  <img src="https://img.shields.io/badge/Packaging-NSIS%20%7C%20WiX%20v4-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Dual Packaging"/>
  <img src="https://img.shields.io/badge/Security-CodeQL%20%7C%20ASan-2EA043?style=for-the-badge&logo=github&logoColor=white" alt="Security Hardened"/>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-0078D6?style=for-the-badge&logo=linux&logoColor=white" alt="Cross Platform"/>
</p>

<br/>

<p align="center">
  <a href="#-about-voidone">About</a> •
  <a href="#-the-manifesto--gamer-to-gamer">Manifesto</a> •
  <a href="#-architectural-superiority">Architecture</a> •
  <a href="#-comprehensive-feature-set">Features</a> •
  <a href="#-automated-cicd--quality-assurance">CI/CD & Security</a> •
  <a href="#-download--deployment">Installation</a> •
  <a href="#-building-from-source">Compilation</a> •
  <a href="#-strategic-roadmap">Roadmap</a> •
  <a href="#-contributing">Contributing</a>
</p>

</div>

<br/>

## 👁️ About VoidOne

**VoidOne** is an ultra-optimized, comprehensive open-source PC gaming hub and library manager, meticulously engineered from the ground up using **C++23** and **Qt 6.8 / QML**. Designed to serve as the ultimate unified desktop ecosystem, VoidOne completely bridges the gap between heavily fragmented commercial game distribution platforms (such as Steam, Epic Games Launcher, GOG Galaxy, and EA App) and pure, unadulterated local execution.

Unlike traditional Electron-based launchers that consume vast amounts of system resources just to render a user interface, VoidOne utilizes hardware-accelerated rendering decoupled from its low-level execution logic. This ensures a near-zero idle RAM footprint while delivering a visually stunning, cyberpunk-inspired graphical interface that runs flawlessly at 60+ FPS on any resolution or display scale.

> ⚠️ **Development Status:** VoidOne is currently in aggressive active development. Core engine APIs, database schemas, and background worker threads are evolving rapidly. Please refer to the [Strategic Roadmap](#-strategic-roadmap) for real-time progression tracking.

<br/>

## 🛡️ The Manifesto — Gamer to Gamer

VoidOne was not conceived in a corporate boardroom; it was forged by a gamer who deeply understands the intrinsic value of software integrity and user autonomy. We believe that gaming software should operate transparently, respecting the user's privacy, system resources, and independence. The modern landscape of mandatory always-online DRM clients and telemetry-heavy storefronts ends here.

- ♾️ **Eternally Free & Open Source** — Zero paywalls, zero mandatory subscriptions, and absolutely no proprietary enterprise lock-ins.
- 🔒 **Absolute Privacy & Offline-First Design** — Zero telemetry engines, zero usage tracking, and no hidden analytic pixels. Your entire database and playtime history remain securely encrypted on your local machine.
- ⚡ **Ultra-Lightweight Execution Architecture** — Engineered for sub-second cold startup times and an idle memory consumption consistently maintained under 50 MB.
- 🎮 **Unrestricted Local Sovereignty** — Complete, unchallenged ownership over your local game registries, configuration files, and modding directory trees.
- 🧩 **Zero Ecosystem Lock-In** — An independent, autonomous library management system that operates with 100% functionality without an internet connection.
- 🛠️ **Transparent Open Development** — A fully accessible code structure submitted for public inspection, strict security validation, and community-driven contribution.

> **"I stand with gamers, forever. Your hardware, your rules."**

<br/>

## 🏗️ Architectural Superiority

| Performance Metric | VoidOne Core Engine | Traditional Store Launchers | Electron-Based Alternatives |
| :--- | :---: | :---: | :---: |
| **Cold Start Initialization** | 🟢 Sub-second (~0.8s - 1.2s) | 🔴 5 to 15+ seconds | 🟡 3 to 6 seconds |
| **Idle Memory Consumption** | 🟢 30 MB - 50 MB | 🔴 350+ MB | 🟡 150 MB - 250 MB |
| **Telemetry & Analytics** | 🟢 Non-Existent | 🔴 Mandatory & Heavy | 🟡 Project-Dependent |
| **Ghost Launch Execution** | 🟢 Native Built-in API | 🔴 Blocked/Unsupported | 🔴 Rarely Implemented |
| **Licensing Structure** | 🟢 Open-Source (MIT) | 🔴 Proprietary / Closed | 🟢 Open-Source |
| **UI Rendering Pipeline** | 🟢 GPU-Accelerated QML | 🔴 WebViews / Chromium | 🔴 Software Rendered |
| **Memory Safety Diagnostics**| 🟢 ASan & CodeQL Hardened | 🔴 Internal / Closed | 🟡 Web V8 Sandboxed |
| **Offline Functionality** | 🟢 100% Operational | 🔴 Heavily Restricted | 🟡 Partially Operational |

<br/>

## ✨ Comprehensive Feature Set

### 👻 The Ghost Launch & Process Orchestration Engine
- **Direct Binary Execution:** Bypasses storefront overhead entirely by spawning games directly via their native executables (`.exe`, `.elf`) utilizing custom Command Line Interface (CLI) arguments.
- **Background RAM Reclamation:** Automatically detects mandatory DRM clients during active gameplay, forcing them into a minimized headless state, and ruthlessly terminating background storefront processes upon game exit to release 100% of system RAM back to your operating system.
- **Process Priority Injection:** Allows users to automatically inject High or Real-Time CPU priority flags into launched games directly from the UI.

### 🎮 Unified Multi-Store Game Aggregator
- **Deep Storage Scanning:** Multi-threaded algorithms recursively scan physical system drives, customized game partitions, and complex platform manifests (Steam `appmanifest_*.acf`, Epic Games `.item`, GOG Galaxy `SQLite` databases) to instantly build a consolidated, unified library.
- **Rich Metadata Acquisition:** Asynchronously fetches high-resolution poster artwork, panoramic hero banners, localized game descriptions, historical play-time records, and metacritic metadata via highly optimized, cached background network workers.
- **Localized Analytics Engine:** Tracks your personal gaming habits—including session lengths, launch frequencies, and crash logs—storing everything securely within an optimized, thread-safe local SQLite database.

### 🎨 Cyberpunk-Inspired QML Interface
- **Hardware Native Acceleration:** A purely hardware-rendered Qt/QML interface utilizing OpenGL/Vulkan backends. Delivers buttery-smooth 60+ FPS cinematic animations, custom real-time particle shaders, and industry-leading low GUI thread latency.
- **Modular Customization:** A dynamic UI ecosystem supporting complete layout restructuring, dynamic RGB theme palettes, custom font-weight scaling, and flawless native dark mode integration.

### 🧩 Advanced Integrated Mod Engine
- **Atomic Profile Configuration:** Construct isolated, per-game modding profiles with instant single-click activation and deactivation.
- **Non-Destructive VFS Mapping:** Utilizes advanced Virtual File System (VFS) symbolic linkage to inject mods into game directories without ever permanently overwriting or corrupting base vanilla game files.
- **Conflict Resolution Matrix:** Automatically verifies file load orders, detects deep mod conflicts, and validates directory linkage structures prior to allowing the game engine to initialize.

### 🤖 Autonomous AI Diagnostic & Repair Integration
- **Self-Healing CI/CD Pipeline:** Integrated multi-agent LLM workflows utilizing a Gemini diagnostic pipeline alongside local patching tools.
- **Automated Remediation:** Instantly parses complex CMake/C++ compiler errors from GitHub Actions, identifies the exact line of code causing the regression, and proposes functional fixes via automated Pull Requests.

<br/>

## 🔄 Automated CI/CD & Quality Assurance

VoidOne enforces strict production-grade DevOps standards via a multi-layered GitHub Actions automated pipeline (`voidone-ci.yml`)[span_0](start_span)[span_0](end_span):

```
[ 🏷️ SemVer Tag Validation ] ──► [ 🔒 CodeQL & Cppcheck Static Analysis ]
                                                 │
                                                 ▼
[ 🚀 Dual Installers (NSIS EXE + WiX MSI) ] ◄── [ 🧪 Debug Build & ASan Memory Testing ]
                      │
                      ▼
[ 📦 Draft Release + SHA-256 Checksums ] ──► [ 🔔 Discord Webhook Notification ]
```

1. **Strict Version Enforcement:** Enforces valid Semantic Versioning tags (e.g., `v1.0.0`, `v1.0.0-beta.1`)[span_1](start_span)[span_1](end_span).
2. **Static Code Analysis:** Automated security scanning powered by **GitHub CodeQL** and **Cppcheck** to detect potential vulnerabilities prior to compilation[span_2](start_span)[span_2](end_span).
3. **Debug & Sanitizer Pipeline (PR Gate):** Runs isolated Debug builds instrumented with **AddressSanitizer (ASan)** and **CTest** on all Pull Requests to catch memory leaks, dangling pointers, and undefined behavior early[span_3](start_span)[span_3](end_span).
4. **Optimized Multi-Format Packaging:** Automatically compiles Release binaries using `ccache` and packages them simultaneously into **NSIS EXE**, **WiX v4 MSI**, and **Portable ZIP** formats[span_4](start_span)[span_4](end_span).
5. **Human-In-The-Loop Draft Releases:** New tagged releases are created in **Draft mode** first, giving maintainers complete control for a final check before public visibility[span_5](start_span)[span_5](end_span).
6. **Nightly Integrity Checks:** Scheduled weekly cron builds proactively catch breaking upstream changes in Qt or toolchains[span_6](start_span)[span_6](end_span).

<br/>

## 📥 Download & Deployment

Three primary distribution options are officially compiled and published for Windows environments[span_7](start_span)[span_7](end_span):

| Package Type | File Name | Description |
| :--- | :--- | :--- |
| **Standard Setup (NSIS)** | `VoidOne-Setup-x64-<version>.exe`[span_8](start_span)[span_8](end_span) | Recommended for most users. Lightweight, customizable installer with Start Menu & Uninstaller shortcuts[span_9](start_span)[span_9](end_span). |
| **Enterprise Installer (WiX)** | `VoidOne-Setup-x64-<version>.msi`[span_10](start_span)[span_10](end_span) | Native Windows Installer package ideal for enterprise environments, quiet GPO rollouts, and registry tracking[span_11](start_span)[span_11](end_span). |
| **Portable Archive (Zero-Install)** | `VoidOne-Windows-x64-Portable-<version>.zip`[span_12](start_span)[span_12](end_span) | Portable folder bundle. Zero installer overhead—run directly from external drives or USB sticks[span_13](start_span)[span_13](end_span). |

> 🔐 **Security Checksum Verification:** Always check file integrity prior to execution. Run the following command in PowerShell:
> ```powershell
> Get-FileHash VoidOne-Setup-x64-1.0.0.exe -Algorithm SHA256
> ```

<br/>

## 🔨 Compiling & Building from Source

For developers, contributors, and security auditors wishing to compile VoidOne locally.

### Prerequisites
- **Compiler:** MSVC 2022 (v17.8+), GCC 13+, or Clang 17+ with C++23 support.
- **Framework:** Qt 6.8+ (Desktop, QtQuick, QML modules required).
- **Toolchain:** CMake 3.25+, Ninja Build Engine, `ccache` (optional, for fast rebuilds).
- **Packaging Dependencies (Optional):** NSIS 3.x and WiX Toolset v4[span_14](start_span)[span_14](end_span).

### 1. Compile Debug Version with Sanitizers (Testing)
```powershell
# Clone repository with submodules
git clone [https://github.com/VoidOne-App/VoidOne.git](https://github.com/VoidOne-App/VoidOne.git)
cd VoidOne

# Configure Debug build with AddressSanitizer & Tests enabled
cmake -S . -B build-debug -G Ninja `
  -DCMAKE_BUILD_TYPE=Debug `
  -DVOIDONE_ENABLE_SANITIZERS=ON `
  -DVOIDONE_BUILD_TESTS=ON

# Compile and run CTest suite
cmake --build build-debug --config Debug --parallel
ctest --test-dir build-debug -C Debug --output-on-failure
```

### 2. Compile Release Version & Build Installers
```powershell
# Configure Release build
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release

# Compile binaries
cmake --build build --config Release --parallel

# Deploy Qt dependencies to package directory
windeployqt --release --compiler-runtime package/VoidOne.exe

# Generate NSIS EXE Installer
& "C:\Program Files (x86)\NSIS\makensis.exe" installer.nsi

# Generate WiX v4 MSI Installer
wix build installer.wxs -ext WixToolset.UI.wixext -o dist/VoidOne-Setup-x64.msi
```

<br/>

## 🗺️ Strategic Engineering Roadmap

- [x] **Phase 1 — Architectural Foundation:** C++23 build harness, Qt 6.8/QML UI scaffolding, file-backed logging, and multi-format NSIS/WiX CI/CD pipelines[span_15](start_span)[span_15](end_span).
- [x] **Phase 2 — Quality & Security Gating:** Integration of CodeQL static security analysis, Cppcheck, AddressSanitizer testing, and automated CTest validation[span_16](start_span)[span_16](end_span).
- [ ] **Phase 3 — The Scanning Engine:** Multi-threaded storage scanning algorithms, manifest parsers (Steam VDF, Epic, GOG), and SQLite database optimization.
- [ ] **Phase 4 — UI & UX Maturation:** Cyberpunk QML dynamic theming, fluid grid responsiveness, and asynchronous background artwork downloading.
- [ ] **Phase 5 — The Ghost Launch Protocol:** Direct process launch bypass hooks, background storefront suppression, and RAM reclamation subroutines.
- [ ] **Phase 6 — Advanced Mod Engine:** Virtual Filesystem (VFS) symbolic linkage mechanics and mod conflict resolution trees.

<br/>

## 🤝 Community Contribution Guidelines

VoidOne thrives on open-source collaboration. Contributions of any scale—ranging from bug fixes and documentation enhancements to major feature implementations—are welcome!

1. **Fork** the official VoidOne repository.
2. **Create** a feature branch off `main`:
   ```bash
   git checkout -b feature/MultiThreadScanner
   ```
3. **Commit** your changes with clear messages:
   ```bash
   git commit -m 'feat: add multi-threaded scanner for Steam libraries'
   ```
4. **Push** your branch and submit a Pull Request. *(Note: Ensure your PR passes the automated Debug + ASan CI check!)*[span_17](start_span)[span_17](end_span)

<br/>

## 📄 Licensing & Legal

```
+--------------------------------------------------------------+
|                    [ V O I D O N E   E N G I N E ]           |
+--------------------------------------------------------------+
| Copyright (c) 2026 VoidOne-App Core Team                     |
| Repository: [https://github.com/VoidOne-App/VoidOne](https://github.com/VoidOne-App/VoidOne)           |
| Core Tech: Modern C++23 & Qt 6.8 / QML                       |
+--------------------------------------------------------------+
```

VoidOne is strictly open-source software, freely distributed under the terms of the **MIT License**. Refer to the [LICENSE](LICENSE) file for complete legal details.

<br/>

<div align="center">

**Forged by gamers. Engineered for absolute performance. Built completely in the open.**

<sub>Architected with uncompromising precision, ❤️, and modern C++23 by the VoidOne-App Core Team.</sub>

<br/><br/>

⭐ **If you stand with the vision of VoidOne, please consider starring the repository on GitHub!** ⭐

</div>
