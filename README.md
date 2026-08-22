<div align="center">

# 🌌 VoidOne

### The Next-Generation, Open-Source, High-Performance PC Game Launcher & Library Aggregator

<p align="center">
  <b>🇬🇧 English</b> •
  <a href="README.fa.md">🇮🇷 پارسی</a>
</p>

<p align="center">
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/c.cpp.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&label=CI%2FCD&color=7C3AED" alt="CI/CD Status"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases">
    <img src="https://img.shields.io/badge/Release-v0.0.1--alpha-FF2E63?style=for-the-badge&logo=rocket&logoColor=white" alt="Latest Release"/>
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
File: `VoidOne-Setup-v0.0.1.msi`

**2. The Portable Archive (Zero-Install)**
A completely standalone, zero-installation archive designed for deployment on external SSDs, USB flash drives, or highly restricted environments without administrative privileges.
File: `VoidOne-Windows-x64-Portable.zip`

> 🔐 **Security Checksum Verification:** We strongly mandate checking file integrity prior to execution to prevent tampering. Run the following command in PowerShell:
> ```powershell
> Get-FileHash VoidOne-Setup-v0.0.1.msi -Algorithm SHA256
> ```

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

```bash
# 1. Clone the master repository and navigate into the project root
git clone [https://github.com/VoidOne-App/VoidOne.git](https://github.com/VoidOne-App/VoidOne.git)
cd VoidOne

# 2. Configure the build environment utilizing CMake and the Ninja generator
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23

# 3. Compile the optimized application binaries utilizing all available CPU cores
cmake --build build --config Release --parallel

# 4. Generate the official WiX v4 MSI Installer (Windows environments only)
wix build -ext WixToolset.UI.wixext installer.wxs -o build/VoidOne-Setup-v0.0.1.msi

🤖 Autonomous AI Diagnostic Workflow
VoidOne pioneers the use of an automated build-diagnostic pipeline. During continuous integration, if a codebase change causes a compilation regression, the following autonomous sequence is triggered:
[ ❌ CI Pipeline Detects C++ Build Failure ] 
                      |
                      v
[ 🧠 Gemini Engine Analyzes Stack Trace & Parses Logs ]
                      |
                      v
[ 💻 Qwen Coder Agent Generates C++ Code Patch ]
                      |
                      v
[ 🔍 Automated PR Submission for Human Maintainer Review ]

> Security Note: The AI acts exclusively in an advisory and generation capacity. Zero AI-generated code is merged into the master branch without rigorous manual inspection and approval by a core maintainer.
> 
🗺️ Strategic Engineering Roadmap
 * [x] Phase 1 — Architectural Foundation: Establishment of the modern C++23 build harness, Qt 6.8/QML interface scaffolding, sophisticated File-Backed Logging, and the WiX v4 CI/CD installer workflow.
 * [ ] Phase 2 — The Scanning Engine: Implementation of multi-threaded storage scanning algorithms, external manifest parsers (Steam VDF, Epic, GOG), and stabilization of the SQLite database schema.
 * [ ] Phase 3 — UI & UX Maturation: Finalizing the cyberpunk QML dynamic theming, grid layout responsiveness, and integrating asynchronous background image fetching.
 * [ ] Phase 4 — The Ghost Launch Protocol: Execution of direct process launch bypass hooks, automated background storefront management, and RAM reclamation subroutines.
 * [ ] Phase 5 — Advanced Mod Engine: Establishing the Virtual Filesystem (VFS) linkage mechanics, resolving dependency tree validation algorithms, and implementing UI profile configuration managers.
 * [ ] Phase 6 — Ecosystem Expansion: Publishing the Theme Customization SDK, establishing RGB hardware synchronization hooks (via OpenRGB), and enabling localized encrypted configuration backups.
🤝 Community Contribution Guidelines
VoidOne thrives on open-source collaboration. Contributions of any scale—ranging from bug fixes and documentation enhancements to major feature implementations and UI overhauls—are highly encouraged and deeply appreciated.
 * Fork the official VoidOne repository to your personal GitHub account.
 * Create a dedicated feature branch from main:
   git checkout -b feature/AdvancedGameScanner

 * Commit your logically grouped changes with clear, descriptive messages:
   git commit -m 'feat: implement multi-threaded directory scanning for Steam libraries'

 * Push the branch to your forked repository:
   git push origin feature/AdvancedGameScanner

 * Submit a comprehensive Pull Request detailing your changes, the rationale, and any necessary testing steps.
📄 Licensing & Copyright
+--------------------------------------------------------------+
|                    [ V O I D O N E   E N G I N E ]           |
+--------------------------------------------------------------+
| Copyright (c) 2026 VoidOne-App Core Team                     |
| Repository: [github.com/VoidOne-App/VoidOne](https://github.com/VoidOne-App/VoidOne)                   |
| Core Tech: Modern C++23 & Qt 6 / QML                         |
+--------------------------------------------------------------+

VoidOne is strictly open-source software, freely distributed under the terms of the MIT License. This grants you extensive permissions for commercial use, modification, distribution, and private utilization. Please refer to the LICENSE file located in the root of the repository for complete legal details.
<div align="center">
Forged by gamers. Engineered for absolute performance. Built completely in the open.
<sub>Architected with uncompromising precision, ❤️, and modern C++23 by the VoidOne-App Core Team.</sub>
⭐ If you stand with the vision of VoidOne, please consider starring the repository on GitHub! ⭐
</div>

> VoidOne is not being built to become another storefront.

It is being built to become the layer between the player, the operating system, and the gaming ecosystem.




---

About

VoidOne is an open-source, native PC gaming platform built around a modern C++23 + Qt 6.8/QML architecture.

The current repository establishes a native foundation for:

Local game-library management

Steam library discovery

Native executable launching

SQLite-backed persistence

QML-based presentation

Save-data backup infrastructure

English / Persian localization foundations

Structured file-backed logging

Single-instance protection

Windows release engineering

Automated CI/CD

Security analysis

AI-assisted engineering workflows


VoidOne is intentionally being designed as more than a conventional launcher.

A traditional launcher primarily answers one question:

> "How do I start this game?"



VoidOne is designed around a larger question:

> "How should a player's games, operating system, files, metadata, execution environment, and future tooling work together?"



The long-term architecture is therefore aimed at creating a native orchestration layer between the player and the fragmented PC gaming ecosystem.

<div align="center">Native by Architecture

C++23 · Qt 6.8 · QML · SQLite · CMake

</div>
---

Vision

PC gaming is powerful — but fragmented.

Games can be distributed across different storefronts, launchers, installation directories, manifest formats, configuration systems, executable structures, mod directories, and independent tools.

VoidOne aims to provide a consistent native layer around that fragmented environment.

PLAYER
                           │
                           ▼
                  ┌─────────────────┐
                  │     VoidOne     │
                  │    Platform     │
                  └────────┬────────┘
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
       GAMES            STORES         LOCAL FILES
          │                │                │
          └────────────────┼────────────────┘
                           ▼
                  OPERATING SYSTEM

The objective is not to replace every existing ecosystem.

The objective is to provide a consistent native control layer above the infrastructure that already exists.

> VoidOne is not being built to become another storefront. It is being built to become the layer between the player, the operating system, and the gaming ecosystem.




---

Manifesto

Gamer to Gamer

VoidOne is built around a simple principle:

> Gaming software should belong to the player — not the other way around.



Open by Design

VoidOne is open source and developed in public.

Architecture, implementation, engineering decisions, build infrastructure, and future direction should remain inspectable whenever practical.

Privacy-Oriented

The current foundation is centered around local storage and native execution rather than requiring a centralized account service for basic library management.

Future analytics should remain useful without turning the player into the product.

Native First

Core functionality should remain native where practical.

C++ and Qt are not cosmetic technology choices. They form the systems-level foundation of the platform.

Performance Is an Engineering Property

Performance should be:

Measured

Reproducible

Environment-specific

Benchmarkable


VoidOne does not treat arbitrary RAM or startup-time numbers as marketing slogans.

User Ownership

VoidOne is designed around the player's installed games, files, hardware, and operating system.

Modular Engineering

The native core is separated from the QML presentation layer, creating room for future services, tooling, testing, integrations, and interfaces.

Transparent Engineering

Automation — including AI-assisted development — remains bounded by repository controls, validation, and human review.


---

Current Capabilities

> The capabilities below reflect functionality that can be reasonably verified from the current repository.



<div align="center">Foundation	Status

Native C++23 Core	✅
Qt 6.8 / QML	✅
SQLite Persistence	✅
Steam Discovery	✅
Native Executable Launching	✅
Qt Game Model	✅
File-backed Logging	✅
Single-instance Protection	✅
Save Backup Engine	🧪
Windows CI/CD	✅
CodeQL	✅
cppcheck	✅
WiX MSI Packaging	✅
AI Repair Infrastructure	🧪


</div>Native C++23 Core

VoidOne builds a dedicated native core library:

voidone_core

Current core responsibilities include:

Database
SteamScanner
GameModel
TranslationManager
SaveBackupManager

The application executable connects this native foundation to the QML presentation layer.


---

Qt 6.8 + QML

The interface is implemented using Qt Quick / QML with Qt components including:

Qt6::Core

Qt6::Gui

Qt6::Quick

Qt6::Sql


The current UI foundation includes:

Library presentation

Game cards

Sidebar navigation

Settings surface

Save-backup UI

Marketplace placeholder

English / Persian language switching



---

SQLite Persistence

VoidOne initializes a local SQLite database through Qt SQL.

The current game records include fields such as:

Identifier

Name

Executable path

Icon path

Platform


The native database layer supports insertion, retrieval, and removal operations.


---

Steam Library Discovery

VoidOne currently includes native Steam discovery.

The scanner reads Steam application manifests such as:

appmanifest_*.acf

The repository includes platform-specific Steam discovery paths, including Windows and Linux locations.

Steam manifest information is converted into native library entries.

Scanning is performed away from the main UI path through the repository's worker-based implementation.


---

Native Game Launching

Game entries can currently be launched through Qt's native process facilities.

The existing implementation provides a direct executable launch path using the stored executable location.

This is the foundation for the more advanced execution architecture planned for future versions.


---

Native Game Model

The game library is exposed to QML through a Qt QAbstractListModel.

Current QML-facing roles include:

id
name
exePath
iconPath
platform

This allows the presentation layer to consume native game data without moving the underlying game-management logic into QML.


---

File-backed Logging

VoidOne installs a Qt message handler and maintains persistent application logs.

The current logger provides:

Timestamped messages

Log-level separation

Console output

Persistent log files

Previous-log rotation

Diagnostic information suitable for bug reports



---

Single-instance Protection

The application uses QLockFile to prevent multiple VoidOne instances from operating simultaneously.

This is particularly useful for a locally persisted application where concurrent application instances could create undesirable state interactions.


---

Save Backup Infrastructure

The native SaveBackupManager provides the foundation for:

Recursive directory copying

Manual backup creation

Backup restoration

Configurable automatic backup intervals

Timer-driven backup execution


The native engine exists, while complete product-level UI integration remains under development.


---

Bilingual Foundation

The repository includes a native translation manager supporting:

English  → en
Persian  → fa

The localization architecture is currently a foundation rather than a complete translation framework.


---

In Progress

VoidOne is an actively evolving platform. Several systems already exist in the repository but are not yet complete enough to be treated as finished product capabilities.

Save Backup UX

The native backup subsystem exists, while the complete user workflow for configuring destinations, selecting save locations, and restoring selected backups continues to evolve.

Marketplace Surface

A marketplace navigation surface exists in the QML interface, but it is currently a placeholder.

No external storefront marketplace should be considered integrated through this surface.

UI Refinement

The current QML layer establishes the visual direction through:

Dark interface styling

Cyan accent treatment

Sidebar navigation

Interactive game cards

Scaling / hover behavior

Library-grid presentation


The interface remains an active engineering surface.

Automated Testing

CMake and CTest infrastructure exist, including development/CI configuration.

However, the repository currently does not contain a mature committed test suite.

Testing infrastructure exists ahead of test coverage.

AI Repair Pipeline

The repository contains a real AI-assisted engineering workflow using:

Gemini

Ollama

Qwen2.5-Coder

CI failure logs

Patch generation

git apply

CMake validation

Draft pull-request creation


The workflow remains under refinement and should not be considered a fully autonomous production repair system.

Release Packaging

Windows packaging is substantially implemented through WiX and CI automation.

The packaging layer remains subject to ongoing release-engineering refinement.


---

Future Platform

> The following capabilities represent planned engineering directions for future VoidOne releases. They are not generally available functionality in the current release.



VoidOne's long-term direction extends beyond the current library-and-launch foundation.


---

👻 Ghost Launch

A controlled execution layer between the player and the game.

Future versions may explore:

Direct executable profiles

Custom launch arguments

Environment configuration

Launch presets

Process lifecycle management

Background-process policies

Orphan-process detection

Process prioritization


The goal is not simply to execute an executable.

The goal is to create a predictable, inspectable execution context around it.


---

⚡ Performance Engine

The future performance layer is envisioned as a policy and diagnostics system rather than a collection of arbitrary system tweaks.

Potential capabilities include:

Startup diagnostics

Memory diagnostics

Per-game process policies

Background workload awareness

Runtime diagnostics

Game-specific performance profiles

Benchmarking

Historical performance analysis


Official performance claims will require reproducible measurements.

> Native architecture should provide a strong foundation for measurable performance — not an excuse for unsupported marketing numbers.



VoidOne does not currently guarantee a specific:

RAM ceiling

Startup time

Frame rate

Hardware performance



---

🎮 Multi-Store Aggregation

Long-term development may expand the library beyond the current Steam integration.

Potential providers include:

Steam

Epic Games

GOG

EA App

Local installations

Additional future providers


A future provider layer may normalize:

Game Identity
      │
      ├── Provider
      ├── Installation
      ├── Manifest
      ├── Metadata
      └── Execution

Steam remains the current verified discovery integration.

Other storefronts are roadmap items unless independently implemented.


---

🖼️ Metadata Engine

Future versions may introduce a richer metadata layer capable of organizing:

Cover artwork

Hero banners

Backgrounds

Descriptions

Genres

Release information

Developers

Publishers

Ratings

Platform information


The intended architecture emphasizes:

Asynchronous processing

Local caching

Non-blocking UI

Graceful degradation


---

📊 Local Gaming Analytics

Future releases may introduce optional local analytics such as:

Launch history

Session tracking

Play duration

Per-game statistics

Crash records

Performance history


The guiding principle:

> Useful analytics without turning the player into the product.




---

🧩 Mod Platform

Long-term development may introduce isolated game-modification profiles with non-destructive file management.

Conceptual future model

Game
├── Vanilla
├── Competitive
├── Graphics Overhaul
├── Experimental
└── Custom Profile

Potential capabilities include:

Mod profiles

Virtual file mapping

Non-destructive deployment

Dependency management

Load ordering

Conflict detection

Compatibility validation


This is a future platform direction, not a claim that a complete mod engine currently exists.


---

🎨 Experience Layer

The current QML foundation is intended to evolve into a broader visual system.

Future capabilities may include:

Dynamic themes

Adaptive layouts

Richer game artwork

Enhanced animations

Personalization

Responsive scaling

Accessibility improvements

Optional RGB customization

Richer library presentation


Visual effects should justify their performance cost.

> A native application should never become resource-heavy merely to look sophisticated.




---

🧱 Extension Ecosystem

Long-term development may introduce:

Extension APIs

Provider adapters

Theme SDKs

Developer tooling

Community integrations

Platform interfaces


The objective is to make VoidOne extensible without turning the core into an unmaintainable collection of tightly coupled integrations.


---

Architecture

VoidOne deliberately separates the presentation layer from native application logic.

Current Architecture

flowchart TB
    APP["Application Entry Point"]
    UI["Qt Quick / QML"]
    MODEL["GameModel"]
    STEAM["SteamScanner"]
    BACKUP["SaveBackupManager"]
    TR["TranslationManager"]
    DB[("SQLite")]
    PROC["Native Process Launch"]
    OS["Operating System / File System"]

    APP --> UI
    APP --> MODEL
    APP --> STEAM
    APP --> BACKUP
    APP --> TR

    UI --> MODEL
    UI --> STEAM
    UI --> BACKUP
    UI --> TR

    MODEL --> DB
    STEAM --> DB
    BACKUP --> OS
    MODEL --> PROC
    PROC --> OS

Native Core

The repository builds a dedicated:

voidone_core

static library.

Current native responsibilities are organized around:

src/core/
├── Database
├── SteamScanner
├── GameModel
├── TranslationManager
└── SaveBackupManager

QML Boundary

The application exposes native functionality to QML through context properties including:

gameModel
saveBackupManager
steamScanner
trManager

This keeps system-level logic in C++ while allowing QML to remain focused on presentation.


---

Long-Term Platform Architecture

The following represents the intended platform direction rather than current implementation:

flowchart TB
    PLAYER["Player"]
    UI["VoidOne Experience Layer"]
    ORCH["Platform Orchestration"]

    LIB["Library & Identity"]
    EXEC["Execution Services"]
    META["Metadata Services"]
    MODS["Mod Platform"]
    DIAG["Diagnostics & Intelligence"]
    STORE["Provider Adapters"]

    LOCAL[("Local State")]
    OS["Operating System"]

    PLAYER --> UI
    UI --> ORCH

    ORCH --> LIB
    ORCH --> EXEC
    ORCH --> META
    ORCH --> MODS
    ORCH --> DIAG
    ORCH --> STORE

    LIB --> LOCAL
    META --> LOCAL
    MODS --> LOCAL
    DIAG --> LOCAL

    EXEC --> OS
    STORE --> OS

The architecture is intentionally designed so future platform capabilities can evolve without forcing every subsystem into a single monolithic application layer.


---

AI Engineering

VoidOne contains an AI-assisted engineering workflow designed to reduce the time required to diagnose and validate CI failures.

Current Infrastructure

The repository contains:

.github/workflows/ai-repair.yml
scripts/ai_repair.py
scripts/requirements-ai-repair.txt

The current infrastructure can:

1. Identify a failed CI run


2. Check out the affected commit


3. Prepare a Linux C++ / Qt environment


4. Collect CI failure logs


5. Send diagnostic context to Gemini


6. Fall back to a local Ollama model


7. Request a candidate unified diff


8. Protect designated repository paths


9. Validate the patch with git apply


10. Rebuild through CMake


11. Revert invalid changes


12. Create a draft repair branch and pull request when validation succeeds



Engineering Loop

flowchart LR
    CI["CI Failure"]
    LOG["Failure Logs"]
    AI["AI Diagnosis"]
    PATCH["Candidate Patch"]
    APPLY["Patch Validation"]
    BUILD["Local Build"]
    PR["Draft Pull Request"]
    HUMAN["Human Review"]

    CI --> LOG
    LOG --> AI
    AI --> PATCH
    PATCH --> APPLY
    APPLY --> BUILD
    BUILD --> PR
    PR --> HUMAN

Current Model Infrastructure

The repository currently references:

Gemini 2.5 Pro

Ollama

Qwen2.5-Coder


The exact workflow configuration remains the source of truth for model selection.

> AI accelerates engineering. It does not replace engineering ownership.



Future iterations may expand into:

Root-cause analysis

Regression detection

Static-analysis remediation

Test-failure analysis

Engineering risk assessment

Validation pipelines

Engineering summaries

Draft PR generation


Automated remediation should remain bounded, reviewable, and reversible.


---

Security

Security is treated as an engineering discipline rather than a marketing claim.

Current Controls

CodeQL

The repository includes CodeQL analysis for C/C++ with security-focused query suites.

Static Analysis

The CI pipeline runs cppcheck against the source tree.

Compiler Hardening

The CMake configuration includes platform-specific compiler hardening.

For MSVC, the project enables options including:

/W4
/permissive-
/sdl

The Windows CI build additionally uses linker hardening options including:

/NXCOMPAT
/DYNAMICBASE
/GUARD:CF
/HIGHENTROPYVA

Dependency Automation

The repository includes Dependabot configuration and automated dependency-management support.

Protected AI Paths

The AI repair implementation protects sensitive repository paths including:

.github/
.git/
scripts/ai_repair.py
scripts/requirements-ai-repair.txt

from AI-generated modifications.

Security Reporting

Security vulnerabilities should not be disclosed through public GitHub Issues.

See the repository's security policy:

SECURITY.md

> VoidOne does not claim a security certification or guarantee.




---

Technology Stack

Technology	Role

C++23	Native application and platform core
Qt 6.8	Desktop framework and application runtime
QML / Qt Quick	Declarative presentation layer
SQLite / Qt SQL	Local persistent game-library storage
CMake	Build configuration and project orchestration
Ninja	Primary build generator
CTest	Test execution integration
GitHub Actions	CI/CD, packaging and release automation
CodeQL	Security-oriented static analysis
cppcheck	Additional C/C++ static analysis
WiX Toolset	Windows MSI packaging
Python	AI engineering orchestration
Gemini	CI failure analysis
Ollama	Local AI model runtime
Qwen2.5-Coder	Local code repair model



---

CI/CD

VoidOne's primary engineering pipeline is centered around Windows release engineering.

The verified pipeline includes:

Semantic Version Validation
          │
          ▼
   Static Analysis
      ├── CodeQL
      └── cppcheck
          │
          ▼
     Windows Build
          │
          ▼
     Qt Deployment
          │
          ▼
   Package Validation
          │
          ▼
 Windows Distribution
     Artifacts
          │
          ▼
 GitHub Release

The Windows pipeline uses components including:

MSVC x64

Qt 6.8

CMake

Ninja

ccache

windeployqt

WiX packaging


The workflow also generates SHA-256 checksums for produced distribution artifacts.

Release publication is tied to semantic-versioned v* tags.

Exact workflow configuration remains authoritative.


---

Download

Official builds are distributed through GitHub Releases.

<div align="center">Get VoidOne



View all releases →

</div>The Windows release pipeline is configured to produce:

Windows x64 portable ZIP packages

WiX MSI installers

SHA-256 checksum files


NSIS tooling is present in the CI environment, but because a corresponding installer.nsi script is not currently present in the repository, NSIS is not treated as a verified release format.

> Always use the actual GitHub Release page for current versions and exact artifact names.



Latest Release →


---

SHA-256 Verification

For a downloaded portable archive:

Get-FileHash .\VoidOne-Windows-x64-Portable-<version>.zip -Algorithm SHA256

For an MSI package:

Get-FileHash .\VoidOne-Setup-x64-<version>.msi -Algorithm SHA256

Compare the generated hash with the corresponding .sha256 file published alongside the release.

Replace <version> with the actual filename shown on the release page.


---

Build

VoidOne is primarily developed around Windows + MSVC + Qt 6.8.

The source tree also contains platform-specific Linux logic, including Linux Steam discovery paths.

Linux is not currently the primary published release target in the repository's main packaging workflow.

Prerequisites

Windows

Windows 10 or later

Visual Studio 2022 or Visual Studio Build Tools 2022

MSVC x64 toolchain

Qt 6.8.x

CMake 3.25+

Ninja

Git


The Qt installation must provide the appropriate desktop MSVC x64 kit.

Linux

The source tree contains Linux-specific implementation paths.

A development environment requires, as applicable:

A current Linux distribution

GCC or Clang with C++23 support

Qt 6.8+

CMake 3.25+

Ninja

Git

Required Qt/system development packages



---

Clone

git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne


---

Release Build

The repository provides a release preset:

cmake --preset release
cmake --build --preset release

Equivalent direct configuration:

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23
cmake --build build --config Release --parallel


---

Development Build

The repository provides a development preset configured for development-oriented builds, including testing and sanitizer support where applicable:

cmake --preset dev
cmake --build --preset dev


---

Custom Qt Path

If CMake cannot locate Qt automatically, provide the Qt installation explicitly.

Windows

cmake -S . -B build -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23 `
  -DCMAKE_PREFIX_PATH="C:\Qt\6.8.x\msvc2022_64"

Linux

cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_PREFIX_PATH="$HOME/Qt/6.8.x/gcc_64"


---

Build Options

The CMake project exposes engineering switches for development and release configuration.

Option	Default	Purpose

VOIDONE_BUILD_TESTS	OFF	Enable test integration
VOIDONE_ENABLE_CONSOLE	ON	Keep the Windows console enabled
VOIDONE_WARNINGS_AS_ERRORS	OFF	Treat compiler warnings as errors
VOIDONE_ENABLE_LTO	ON	Enable Release LTO when supported
VOIDONE_ENABLE_SANITIZERS	OFF	Enable ASan/UBSan for supported Debug GCC/Clang builds
VOIDONE_ENABLE_CLANG_TIDY	OFF	Enable clang-tidy during compilation
VOIDONE_ENABLE_UNITY_BUILD	OFF	Enable CMake unity builds
VOIDONE_REPRODUCIBLE_BUILD	OFF	Enable best-effort reproducibility controls
VOIDONE_BUILD_DOCS	OFF	Generate Doxygen documentation when available



---

Packaging

WiX MSI

The repository contains:

installer.wxs

The Windows CI workflow invokes WiX to produce an MSI installer.

The installer configuration includes:

Per-machine installation

Add/Remove Programs integration

Start Menu shortcut

Desktop shortcut

Application icon

Embedded package files


Package versioning and final artifact naming are resolved by the release workflow.

Portable Windows Distribution

The CI pipeline deploys the Qt runtime through:

windeployqt

and creates a compressed Windows x64 portable package.

The portable distribution is intended to contain the executable and the Qt/runtime files required to launch the application.


---

Testing

VoidOne is prepared for CTest-based testing through its CMake configuration.

Development configuration:

cmake --preset dev
cmake --build --preset dev

CTest:

ctest --test-dir build/dev --output-on-failure

The repository currently does not contain a mature committed tests/ implementation.

That distinction is intentional:

> Testing infrastructure exists ahead of test coverage.



Expanding the automated test suite remains an active engineering priority.


---

Performance Policy

VoidOne is designed around a native, resource-conscious architecture.

However, performance claims must be reproducible.

Official benchmarks should identify the environment in which they were measured.

Recommended benchmark dimensions

Dimension	Required Context

Hardware	CPU / GPU / RAM
Operating System	Windows version / Linux distribution
Compiler	MSVC / GCC / Clang
Qt	Exact Qt build
Build Type	Debug / Release
Library Size	Number of indexed games
Cold Start	Process start → usable UI
Warm Start	Subsequent launch
Idle Memory	Steady-state working set
Peak Memory	Peak during scanning/loading
Scan Duration	Discovery completion time
Frame Time	UI responsiveness under representative workloads


VoidOne does not currently guarantee:

A fixed RAM ceiling

A fixed startup time

A fixed frame rate

Universal hardware performance


Performance targets may exist internally, but they should only become public product claims after reproducible benchmarking.

> Performance is an engineering property, not a marketing number.




---

Roadmap

VoidOne's roadmap separates established foundations from active development and long-term platform direction.

Phase I — Native Foundation

Completed

[x] C++23 project foundation

[x] Qt 6.8 / QML application layer

[x] Dedicated native core library

[x] SQLite persistence

[x] Native game model

[x] Steam manifest discovery

[x] Native executable launching

[x] File-backed logging

[x] Single-instance protection

[x] Windows CI/CD foundation

[x] CodeQL integration

[x] cppcheck integration

[x] WiX MSI packaging path


In Progress

[ ] Expand automated tests

[ ] Refine backup workflow

[ ] Stabilize UI architecture

[ ] Improve release packaging consistency

[ ] Complete AI repair workflow integration



---

Phase II — Library Intelligence

Planned

[ ] Broader local game discovery

[ ] Improved library identity handling

[ ] Store-provider abstraction

[ ] Deduplication

[ ] Rich local metadata model

[ ] Improved installation-state detection



---

Phase III — Experience

Planned

[ ] Richer library presentation

[ ] Dynamic theming

[ ] Responsive game-art presentation

[ ] Advanced personalization

[ ] Accessibility improvements

[ ] More complete localization architecture



---

Phase IV — Execution

Planned

[ ] Ghost Launch profiles

[ ] Custom launch arguments

[ ] Environment configuration

[ ] Process lifecycle controls

[ ] Background process policies

[ ] Per-game execution policies

[ ] Performance profiles



---

Phase V — Mod Platform

Planned

[ ] Mod profiles

[ ] Virtual file mapping

[ ] Non-destructive deployment

[ ] Dependency management

[ ] Load-order handling

[ ] Conflict detection

[ ] Compatibility validation



---

Phase VI — Intelligence

Planned

[ ] Local analytics

[ ] Performance history

[ ] Diagnostics

[ ] Crash analysis

[ ] Root-cause analysis

[ ] Regression detection

[ ] Expanded AI engineering workflows



---

Phase VII — Ecosystem

Long-Term

[ ] Extension APIs

[ ] Theme SDK

[ ] Provider adapters

[ ] Community integrations

[ ] Developer tooling

[ ] Broader platform interoperability

[ ] Windows + Linux platform maturation



---

Engineering Principles

Evidence Over Marketing

Repository implementation, build configuration, tests, and CI behavior determine what VoidOne can legitimately claim.

Small, Reviewable Changes

Large systems remain maintainable when architectural changes are incremental, understandable, and easy to review.

Native First

Use native system capabilities where they provide clearer ownership, stronger control, and better long-term maintainability.

Security by Default

Security controls should be integrated into engineering workflows rather than added after architecture is complete.

Human-Controlled Automation

Automation should remove repetitive engineering work without removing human accountability.

Long-Term Maintainability

Architecture decisions should optimize for the platform VoidOne may become — not only the feature being implemented today.


---

Repository Structure

The repository remains intentionally compact:

VoidOne/
├── .github/
│   ├── workflows/
│   │   ├── ai-repair.yml
│   │   ├── c.cpp.yml
│   │   ├── codeql.yml
│   │   ├── dependabot-automerge.yml
│   │   ├── greetings.yml
│   │   ├── label.yml
│   │   └── stale.yml
│   ├── dependabot.yml
│   └── labeler.yml
│
├── src/
│   ├── core/
│   │   ├── Database.*
│   │   ├── GameModel.*
│   │   ├── SaveBackupManager.*
│   │   ├── SteamScanner.*
│   │   └── TranslationManager.*
│   │
│   ├── ui/
│   │   └── qml/
│   │       ├── GameCard.qml
│   │       ├── Main.qml
│   │       ├── SaveBackupView.qml
│   │       ├── Sidebar.qml
│   │       └── SidebarButton.qml
│   │
│   └── main.cpp
│
├── scripts/
│   ├── ai_repair.py
│   └── requirements-ai-repair.txt
│
├── CMakeLists.txt
├── CMakePresets.json
├── BUILD.md
├── installer.wxs
├── LICENSE
├── SECURITY.md
├── TROUBLESHOOTING.md
├── README.md
└── README.fa.md


---

Contributing

VoidOne is intended to grow through disciplined open-source engineering.

Development Flow

Create a focused feature branch:

git checkout main
git pull origin main
git checkout -b feature/your-feature

Build the development configuration:

cmake --preset dev
cmake --build --preset dev

Run the available CTest integration:

ctest --test-dir build/dev --output-on-failure

Review the changes:

git status
git diff

Create a focused commit:

git add .
git commit -m "feat: improve Steam library discovery"

Push the branch:

git push origin feature/your-feature

Then open a Pull Request against main.

Pull Requests

A strong Pull Request should explain:

What changed

Why it changed

Affected components

Validation performed

Known limitations

Screenshots for meaningful UI changes


Contribution Areas

Useful contributions include:

C++

Qt / QML

Testing

Build engineering

Packaging

Security

Documentation

UI / UX

Platform integration

Performance engineering


The strongest contributions are focused, reproducible, and easy to review.


---

Security Reporting

Please do not disclose security vulnerabilities through public GitHub Issues.

Use the repository's security reporting process instead:

Security Policy →

Security reports should contain enough information to reproduce and assess the issue without exposing credentials, personal data, or unrelated systems.


---

Documentation

Resource	Purpose

Build Guide	Build and development information
Troubleshooting	Known problems and diagnostics
Security Policy	Security reporting process
Persian README	فارسی
GitHub Repository	Source code and project development
GitHub Releases	Published releases
Latest Release	Current release



---

License

VoidOne is distributed under the MIT License.

The repository's LICENSE file is the authoritative source for the exact license text and copyright information.

See:

LICENSE


---

<div align="center">🌌 VoidOne

Your Games. Your Hardware. Your Rules.

Built by a gamer. Engineered for performance. Built in the open.

<br>

<br>Built by a gamer. Engineered like a platform.

</div>
