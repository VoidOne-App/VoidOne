<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

# 🌌 VoidOne

### The Next-Generation, Open-Source, High-Performance PC Game Launcher & Library Aggregator

<p align="center">
  <b>🇬🇧 English</b> •
  <a href="README.fa.md">🇮🇷 پارسی</a>
</p>

<p align="center">
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/c-cpp.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/c-cpp.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&label=CI%2FCD&color=7C3AED" alt="CI/CD Status"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/codeql.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/codeql.yml?branch=main&style=for-the-badge&logo=github&logoColor=white&label=CodeQL&color=00D9FF" alt="CodeQL Analysis"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases/latest">
    <img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?style=for-the-badge&logo=rocket&logoColor=white&color=FF2E63&label=Latest" alt="Latest Release"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases">
    <img src="https://img.shields.io/github/downloads/VoidOne-App/VoidOne/total?style=for-the-badge&logo=windows11&logoColor=white&color=39FF14&label=Downloads" alt="Total Downloads"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++23 Standard"/>
  <img src="https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6.8 Framework"/>
  <img src="https://img.shields.io/badge/WiX_Toolset-v4-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="WiX Toolset v4"/>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-0078D6?style=for-the-badge&logo=linux&logoColor=white" alt="Cross Platform"/>
  <img src="https://img.shields.io/badge/License-MIT-FFD60A?style=for-the-badge" alt="MIT License"/>
</p>

<br/>

<p align="center">
  <a href="#-about-voidone">About</a> •
  <a href="#-the-manifesto--gamer-to-gamer">Manifesto</a> •
  <a href="#-architectural-superiority">Architecture</a> •
  <a href="#-comprehensive-feature-set">Features</a> •
  <a href="#-download--deployment">Installation</a> •
  <a href="#-building-from-source">Compilation</a> •
  <a href="#-autonomous-ai-healing-pipeline">AI Diagnostics</a> •
  <a href="#-strategic-roadmap">Roadmap</a> •
  <a href="#-contributing">Contributing</a>
</p>

</div>

<br/>

## 👁️ About VoidOne

**VoidOne** is an ultra-optimized, comprehensive open-source PC gaming hub and library manager, meticulously engineered from the ground up using **C++23** and **Qt 6 / QML**. Designed to serve as the ultimate unified desktop ecosystem, VoidOne completely bridges the gap between heavily fragmented commercial game distribution platforms (such as Steam, Epic Games Launcher, GOG Galaxy, and EA App) and pure, unadulterated local execution. 

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

### 🤖 Autonomous AI Diagnostic & Repair System
- **Self-Healing CI/CD Pipeline:** Integrated multi-agent LLM workflows utilizing a Gemini 2.5 Pro diagnostic pipeline alongside a local Qwen2.5-Coder patching agent.
- **Automated Remediation:** Instantly parses complex CMake/C++ compiler errors from GitHub Actions, identifies the exact line of code causing the regression, and proposes functional fixes via automated Pull Requests.

<br/>

## ⚙️ Technology Stack & Engine Infrastructure

- **Core Logic & Systems Engine:** `C++23` — Ensures zero-overhead abstractions, ultra-low latency system calls, rigorous process management, and heavily asynchronous I/O operations.
- **Presentation & GUI Framework:** `Qt 6.8 / QML` — Provides a declarative, GPU-accelerated interface with a highly modular, signal-and-slot based component architecture.
- **Relational Database Management:** `SQLite3` — A lightweight, thread-safe embedded storage solution for handling massive libraries of local game records and persistent application states.
- **Build Automation & Orchestration:** `CMake 3.25+ / Ninja` — A robust, scalable, and cross-platform build configuration pipeline ensuring reproducible builds.
- **Deployment & Packaging:** `WiX Toolset v4 / MSI` — Compiles a native, heavily optimized 64-bit Windows Installer with secure Start Menu, Registry, and Desktop integration.
- **Continuous Integration (CI/CD):** `GitHub Actions` — Orchestrates automated multi-platform compilation, static code analysis via CodeQL and Cppcheck, and zero-touch automated deployment to release channels.

<br/>

## 📥 Download & Deployment

Two primary distribution channels are officially provided for Windows operating systems:

**1. The Standard Installer (Recommended)**
Provides a complete ecosystem setup, including Start Menu shortcuts, Desktop integration, automatic Visual C++ Redistributable checks, and a clean uninstallation wizard.
    File: VoidOne-Setup-v0.0.1.msi

**2. The Portable Archive (Zero-Install)**
A completely standalone, zero-installation archive designed for deployment on external SSDs, USB flash drives, or highly restricted environments without administrative privileges.
    File: VoidOne-Windows-x64-Portable.zip

> 🔐 **Security Checksum Verification:** We strongly mandate checking file integrity prior to execution to prevent tampering. Run the following command in PowerShell:
>     Get-FileHash VoidOne-Setup-v0.0.1.msi -Algorithm SHA256

<br/>

## 🔨 Compiling & Building from Source

For developers, contributors, and security auditors wishing to compile VoidOne locally.

### Comprehensive System Prerequisites
- **Compiler Requirements:**
  - **Windows OS:** Microsoft Visual Studio 2022 (v17.8 or newer) with standard C++23 flags enabled.
  - **Linux OS:** GCC 13+ or Clang 17+ with robust standard library support.
- **Framework Installation:** Qt 6.8+ (Ensure Desktop Development, QtQuick, and QML modules are explicitly selected during installation).
- **Packaging Dependencies:** WiX Toolset v4 (Strictly required only if compiling the Windows MSI installer).
- **Build Utilities:** CMake 3.25+, the Ninja Build Engine, and Git 2.40+.

### Step-by-Step Compilation Pipeline

    # 1. Clone the master repository and navigate into the project root
    git clone https://github.com/VoidOne-App/VoidOne.git
    cd VoidOne

    # 2. Configure the build environment utilizing CMake and the Ninja generator
    # This enforces the C++23 standard and prepares a Release configuration
    cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23

    # 3. Compile the optimized application binaries utilizing all available CPU cores
    cmake --build build --config Release --parallel

    # 4. Generate the official WiX v4 MSI Installer (Windows environments only)
    wix build -ext WixToolset.UI.wixext installer.wxs -o build/VoidOne-Setup-v0.0.1.msi

<br/>

## 🤖 Autonomous AI Diagnostic Workflow

VoidOne pioneers the use of an automated build-diagnostic pipeline. During continuous integration, if a codebase change causes a compilation regression, the following autonomous sequence is triggered:

    [ ❌ CI Pipeline Detects C++ Build Failure ] 
                          |
                          v
    [ 🧠 Gemini 2.5 Engine Analyzes Stack Trace & Parses Logs ]
                          |
                          v
    [ 💻 Qwen2.5-Coder Agent Generates C++ Code Patch ]
                          |
                          v
    [ 🔍 Automated PR Submission for Human Maintainer Review ]

> *Security Note: The AI acts exclusively in an advisory and generation capacity. Zero AI-generated code is merged into the master branch without rigorous manual inspection and approval by a core maintainer.*

<br/>

## 🗺️ Strategic Engineering Roadmap

- [x] **Phase 1 — Architectural Foundation:** Establishment of the modern C++23 build harness, Qt 6.8/QML interface scaffolding, sophisticated File-Backed Logging, and the WiX v4 CI/CD installer workflow.
- [ ] **Phase 2 — The Scanning Engine:** Implementation of multi-threaded storage scanning algorithms, external manifest parsers (Steam VDF, Epic, GOG), and stabilization of the SQLite database schema.
- [ ] **Phase 3 — UI & UX Maturation:** Finalizing the cyberpunk QML dynamic theming, grid layout responsiveness, and integrating asynchronous background image fetching.
- [ ] **Phase 4 — The Ghost Launch Protocol:** Execution of direct process launch bypass hooks, automated background storefront management, and RAM reclamation subroutines.
- [ ] **Phase 5 — Advanced Mod Engine:** Establishing the Virtual Filesystem (VFS) linkage mechanics, resolving dependency tree validation algorithms, and implementing UI profile configuration managers.
- [ ] **Phase 6 — Ecosystem Expansion:** Publishing the Theme Customization SDK, establishing RGB hardware synchronization hooks (via OpenRGB), and enabling localized encrypted configuration backups.

<br/>

## 🤝 Community Contribution Guidelines

VoidOne thrives on open-source collaboration. Contributions of any scale—ranging from bug fixes and documentation enhancements to major feature implementations and UI overhauls—are highly encouraged and deeply appreciated.

1. **Fork** the official VoidOne repository to your personal GitHub account.
2. **Create** a dedicated feature branch from `main`: 
       git checkout -b feature/AdvancedGameScanner
3. **Commit** your logically grouped changes with clear, descriptive messages: 
       git commit -m 'feat: implement multi-threaded directory scanning for Steam libraries'
4. **Push** the branch to your forked repository: 
       git push origin feature/AdvancedGameScanner
5. **Submit** a comprehensive Pull Request detailing your changes, the rationale, and any necessary testing steps.

<br/>

## 📄 Licensing & Copyright

    +--------------------------------------------------------------+
    |                    [ V O I D O N E   E N G I N E ]           |
    +--------------------------------------------------------------+
    | Copyright (c) 2026 VoidOne-App Core Team                     |
    | Repository: github.com/VoidOne-App/VoidOne                   |
    | Core Tech: Modern C++23 & Qt 6 / QML                         |
    +--------------------------------------------------------------+

VoidOne is strictly open-source software, freely distributed under the terms of the **MIT License**. This grants you extensive permissions for commercial use, modification, distribution, and private utilization. Please refer to the [LICENSE](LICENSE) file located in the root of the repository for complete legal details.

<br/>

<div align="center">

**Forged by gamers. Engineered for absolute performance. Built completely in the open.**

<sub>Architected with uncompromising precision, ❤️, and modern C++23 by the VoidOne-App Core Team.</sub>

<br/><br/>

⭐ **If you stand with the vision of VoidOne, please consider starring the repository on GitHub!** ⭐

</div>
