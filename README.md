<div align="center">🌌 VoidOne

Native PC Gaming Platform — built by a gamer, engineered like a platform.

<p>
  <strong>English</strong> •
  <a href="README.fa.md">پارسی</a>
</p><p>
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/c.cpp.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&label=CI%2FCD" alt="CI/CD Status">
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/codeql.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/codeql.yml?branch=main&style=for-the-badge&logo=github&logoColor=white&label=CodeQL" alt="CodeQL Status">
  </a>
  <img src="https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++23">
  <img src="https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6.8">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
  <img src="https://img.shields.io/badge/License-MIT-FFD60A?style=for-the-badge" alt="MIT License">
  <a href="https://github.com/VoidOne-App/VoidOne">
    <img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=for-the-badge&logo=github" alt="GitHub Stars">
  </a>
</p><p>
  <a href="#about">About</a> •
  <a href="#vision">Vision</a> •
  <a href="#manifesto">Manifesto</a> •
  <a href="#current-capabilities">Current Capabilities</a> •
  <a href="#in-progress">In Progress</a> •
  <a href="#future-platform">Future Platform</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#ai-engineering">AI Engineering</a> •
  <a href="#security">Security</a> •
  <a href="#technology-stack">Technology Stack</a> •
  <a href="#build">Build</a> •
  <a href="#testing">Testing</a> •
  <a href="#roadmap">Roadmap</a> •
  <a href="#contributing">Contributing</a>
</p></div>> VoidOne is not being built to become another storefront. It is being built to become the layer between the player, the operating system, and the gaming ecosystem.




---

About

VoidOne is an open-source native PC gaming platform built around a modern C++23 + Qt 6/QML architecture.

The current repository establishes the foundation for a local game library, Steam discovery, native executable launching, persistent SQLite storage, QML presentation, save-data backup infrastructure, bilingual UI support, structured logging, and an automated Windows engineering pipeline.

The long-term goal goes beyond the traditional launcher model.

A conventional launcher is primarily an application that opens games.

VoidOne is being designed as a platform layer that can eventually coordinate the broader relationship between:

the player

installed games

game stores

local files

operating-system services

metadata

mods

performance policies

diagnostics

automation

future extensions


The architecture is intentionally native. The project does not depend on a browser runtime for its primary application layer; the executable is a C++ application with Qt Quick/QML for presentation and a dedicated native core for application logic.

That distinction matters because the project is intended to remain maintainable at the systems level as the feature set grows.


---

Vision

PC gaming is fragmented by design.

A player's games may be spread across different storefronts, installation locations, launchers, manifests, configuration systems, mod directories, and standalone executables. Even when the actual games are already installed, the surrounding management layer can remain fragmented.

VoidOne aims to introduce a unified native orchestration layer around that reality.

The platform model

PLAYER
                      │
                      ▼
                ┌───────────┐
                │  VoidOne  │
                │ Platform  │
                └─────┬─────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
     Games         Stores        Local Files
        │             │             │
        └─────────────┼─────────────┘
                      │
                      ▼
              OPERATING SYSTEM

The objective is not to replace every ecosystem.

The objective is to provide a consistent native control layer above the fragmented infrastructure that already exists.


---

Manifesto

Gamer to Gamer

VoidOne is built around a straightforward idea:

Gaming software should belong to the player, not the other way around.

Open by Design

The project is open source and developed in public. Architecture, implementation decisions, build infrastructure, and engineering direction should remain inspectable.

Privacy-Oriented by Architecture

The current application is centered around local storage and native execution rather than requiring a centralized account service for basic library management.

Future analytics should remain useful without turning the player into the product.

Native First

Core functionality should be implemented as native system software where practical.

C++ and Qt are not merely implementation choices; they define the foundation on which the platform is intended to grow.

Performance Is an Engineering Property

Performance claims should be measured, reproducible, and tied to a known environment.

VoidOne does not treat arbitrary RAM or startup-time numbers as marketing slogans.

User Ownership

The platform should work with the user's installed games, local data, and operating system rather than hiding them behind proprietary abstractions.

Modular Engineering

The core is separated from the QML presentation layer so that future tools, services, tests, or additional interfaces can reuse the native foundation.

Transparent Engineering

Automation, including AI-assisted development tooling, remains subject to repository controls, validation, and human ownership.


---

Current Capabilities

The following capabilities are verifiable from the current repository.

Native C++23 Application Core

VoidOne is configured as a C++23 project with a dedicated static voidone_core library.

The core currently contains native components for:

database access

Steam discovery

game models

translation

save-data backup handling


The application executable is intentionally kept relatively thin and connects the native core to the QML interface.

Qt 6.8 + QML Interface

The project requires Qt 6.8 components including:

Qt6::Core

Qt6::Gui

Qt6::Quick

Qt6::Sql


The UI is implemented through a QML module named VoidOne.

The current interface includes:

library view

game cards

sidebar navigation

settings view

marketplace placeholder

save-backup UI

English/Persian language switching


SQLite Persistence

The application initializes a local SQLite database under the platform's Qt application-data directory.

The current schema stores game records including:

identifier

name

executable path

icon path

platform


The database API also supports batch insertion, retrieval, and removal.

Steam Library Discovery

VoidOne contains a native Steam scanner that reads Steam application manifest files:

appmanifest_*.acf

The scanner currently looks for Steam installations in platform-specific locations.

On Windows it checks the conventional Steam installation path.

On Linux it includes both:

~/.local/share/Steam

and the Flatpak Steam data location when available.

The manifest parser extracts the game name and installation directory and stores the discovered entry as a Steam platform record.

The scan is performed through a worker thread rather than directly on the main UI path.

Native Game Launching

Game entries can currently be launched through Qt's detached process facilities.

The existing implementation provides a simple native execution path using the stored executable path.

This is the foundation for the more advanced execution layer planned for future versions.

Library Model Integration

The game library is exposed through a Qt QAbstractListModel.

The current model provides QML roles for:

id

name

exePath

iconPath

platform


This allows the QML interface to render the native game collection directly from the C++ model.

File-Backed Logging

VoidOne installs its own Qt message handler and writes persistent logs under the application's local data directory.

The current logger:

records timestamps

separates log levels

continues writing to the console

stores a current log file

rotates one previous log file

preserves diagnostics that can be attached to bug reports


Single-Instance Protection

The application uses QLockFile to prevent multiple VoidOne instances from operating simultaneously.

This is particularly relevant to the current SQLite-backed architecture, where multiple application instances are undesirable.

Runtime Failure Handling

The application currently includes:

QML object-creation failure handling

root-object validation after QML loading

exception handling around application initialization

explicit fatal logging for failed database initialization

clean shutdown logging


Save Backup Infrastructure

A native SaveBackupManager is present and supports:

recursive directory copying

manual backup creation

backup restoration

configurable auto-save intervals

timer-driven automatic backup execution


The backup engine exists in the native layer, while the current QML integration remains incomplete and is therefore treated as in progress rather than a finished backup product.

Bilingual UI Foundation

The repository includes a native translation manager supporting:

English (en)
Persian (fa)

The QML interface also contains direct bilingual UI strings.

The localization system is currently a foundation rather than a complete translation framework.


---

In Progress

The repository contains several systems that are implemented partially, experimentally, or remain incomplete.

Save Backup UX Integration

The native backup subsystem exists, but the current UI does not yet provide a complete end-to-end workflow for selecting save locations, configuring backup destinations, and restoring a chosen backup.

The architecture is present; product-level integration is still evolving.

Marketplace

The QML application already contains a marketplace navigation surface, but the current implementation explicitly presents the section as under construction.

No storefront should therefore be considered currently integrated through the marketplace.

UI Refinement

The current QML interface establishes the visual direction and component structure, including:

dark interface styling

cyan accent treatment

sidebar navigation

interactive game cards

scaling and hover effects

library grid presentation


The UI is still an evolving foundation rather than a finished product shell.

Test Suite Expansion

CMake explicitly supports a VOIDONE_BUILD_TESTS option and provides development/CI test presets.

However, the current repository does not contain a tests/ directory or test implementation, so the testing architecture is currently ahead of the test suite itself.

AI Repair Pipeline

The repository contains a real AI-assisted repair workflow and Python implementation using:

Gemini

Ollama

Qwen2.5-Coder

CI failure logs

patch generation

git apply

local CMake build validation

draft pull request creation


The infrastructure is real, but its automatic workflow integration still requires refinement. In particular, the AI workflow currently references a CI workflow name that does not exactly match the primary CI workflow's declared name.

This makes the AI system best classified as in progress, not as a fully autonomous production repair service.

Release Packaging Refinement

The Windows pipeline is substantially implemented, but the repository's packaging configuration is still evolving.

WiX MSI packaging is checked in and exercised by CI. An NSIS toolchain is installed by CI, but no corresponding installer.nsi script is currently present in the repository, so NSIS packaging is not treated as a verified release path.


---

Future Platform

> The following capabilities represent planned engineering directions for future VoidOne releases. They are not generally available functionality in the current release.



VoidOne's long-term roadmap extends substantially beyond the current library-and-launch foundation.

Ghost Launch

Purpose: provide a controlled execution layer between the player and the game.

Future versions are planned to explore:

direct executable execution profiles

custom launch arguments

per-game environment configuration

launch presets

process lifecycle management

background process policies

orphan-process detection

process prioritization


The goal is not simply to call an executable.

The goal is to build a predictable, inspectable execution context around it.

Performance Engine

The performance layer is planned as a policy and diagnostics system rather than a collection of arbitrary tweaks.

Potential future capabilities include:

startup diagnostics

memory diagnostics

per-game process priority policies

background workload awareness

runtime process policies

game-specific performance profiles

benchmarking

historical performance analysis


Any official performance target will require reproducible measurements.

Potential engineering targets may be used internally, but they must never be presented as guaranteed user-facing specifications without benchmarks.

Multi-Store Aggregation

Long-term development may expand beyond the current Steam scanner.

Potential providers include:

Steam

Epic Games

GOG

EA App

local installations

additional future providers


A future aggregation layer may normalize:

game identities

installation locations

manifests

launcher ownership

metadata

duplicate entries


Steam is the current verified discovery integration. Other stores remain roadmap items unless independently implemented.

Metadata Engine

A future metadata service may normalize local game records with optional rich information such as:

cover artwork

hero banners

backgrounds

descriptions

genres

release information

developers

publishers

ratings

platform information


The intended architecture emphasizes:

asynchronous processing

local caching

non-blocking UI operation

graceful degradation when external metadata is unavailable


Local Gaming Analytics

Future releases may introduce optional local analytics including:

launch history

session tracking

play duration

per-game statistics

crash records

performance history


The guiding principle is:

> Useful analytics without turning the player into the product.



Analytics should remain local by default unless a future feature explicitly requires another model.

Mod Platform

The long-term mod architecture may introduce isolated profiles and non-destructive file management.

A conceptual future model:

Game
├── Vanilla
├── Competitive
├── Graphics Overhaul
├── Experimental
└── Custom Profile

Potential functionality includes:

mod profiles

virtual file mapping

non-destructive deployment

dependency management

load ordering

conflict detection

compatibility checks


This is a future platform direction, not a claim that a complete VFS/mod engine exists today.

Advanced UI Platform

The current QML foundation is intended to evolve into a broader visual system.

Potential future capabilities include:

dynamic themes

adaptive layouts

richer game artwork

enhanced animations

personalization

responsive scaling

accessibility improvements

optional RGB customization

richer library presentation


Visual effects should always justify their performance cost.

A native application should not become resource-heavy merely to look sophisticated.

Extension Ecosystem

Long-term development may introduce:

extension APIs

integration interfaces

theme SDKs

developer tooling

community extensions

platform adapters


The objective is to make VoidOne extensible without turning the core into an unmaintainable collection of tightly coupled integrations.


---

Architecture

The current architecture deliberately separates presentation from native application logic.

Current Architecture

flowchart TB
    UI[Qt Quick / QML UI]
    APP[Application Entry Point]
    MODEL[GameModel]
    STEAM[SteamScanner]
    BACKUP[SaveBackupManager]
    TR[TranslationManager]
    DB[(SQLite)]
    OS[Operating System / File System]
    PROC[Native Process Launch]

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

Current responsibilities include:

src/core/
├── Database
├── SteamScanner
├── GameModel
├── TranslationManager
└── SaveBackupManager

The executable itself primarily owns application startup, runtime configuration, QML initialization, and dependency injection into the UI.

QML Boundary

The current application exposes native controllers to QML through context properties:

gameModel
saveBackupManager
steamScanner
trManager

This gives the presentation layer access to native functionality without placing the implementation directly inside QML components.

Long-Term Platform Architecture

The longer-term platform can evolve toward a layered architecture:

flowchart TB
    PLAYER[Player]
    UI[VoidOne Experience Layer]
    ORCH[Platform Orchestration]
    LIB[Library & Identity]
    EXEC[Execution Services]
    META[Metadata Services]
    MODS[Mod Platform]
    DIAG[Diagnostics & Intelligence]
    STORE[Store / Provider Adapters]
    OS[Operating System]
    LOCAL[(Local State)]

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

This diagram describes the intended platform direction, not a claim that every layer already exists.


---

AI Engineering

VoidOne contains a dedicated AI-assisted engineering workflow intended to reduce the time required to diagnose CI failures.

Current Infrastructure

The repository includes:

.github/workflows/ai-repair.yml

scripts/ai_repair.py

scripts/requirements-ai-repair.txt


The workflow can:

1. identify a failed CI run


2. check out the affected commit


3. install a Linux C++/Qt development environment


4. collect failed CI logs


5. pass diagnostic context to Gemini


6. fall back to a local Ollama model


7. request a unified diff


8. reject protected-path changes


9. validate the patch with git apply


10. rebuild the project with CMake


11. revert the changes when validation fails


12. create a draft repair branch and pull request when changes remain



The configured models currently include:

Gemini 2.5 Pro
Qwen2.5-Coder via Ollama

Repair Model

flowchart LR
    CI[CI Failure]
    LOG[Failure Logs]
    AI[AI Diagnosis]
    PATCH[Candidate Patch]
    APPLY[Patch Validation]
    BUILD[Local Build]
    PR[Draft Pull Request]
    HUMAN[Human Review]

    CI --> LOG
    LOG --> AI
    AI --> PATCH
    PATCH --> APPLY
    APPLY --> BUILD
    BUILD --> PR
    PR --> HUMAN

The important boundary is human ownership.

> AI accelerates engineering. It does not replace engineering ownership.



Future iterations may extend the system toward:

root-cause analysis

regression detection

static-analysis remediation

test-failure analysis

risk assessment

validation pipelines

draft PR generation

engineering summaries


Automated remediation must remain reviewable and bounded.


---

Security

Security is treated as an engineering discipline rather than a marketing claim.

Current Controls

The repository currently includes:

CodeQL

The CodeQL workflow runs against C/C++ and uses:

security-extended
security-and-quality

query suites.

Static Analysis

The primary CI pipeline runs cppcheck against the source tree.

Compiler Hardening

The CMake configuration includes platform-specific compiler hardening options.

On MSVC, the project enables options including:

/W4
/permissive-
/sdl

The CI build additionally supplies Windows linker hardening options including:

/NXCOMPAT
/DYNAMICBASE
/GUARD:CF
/HIGHENTROPYVA

Dependency Automation

The repository includes Dependabot configuration and automated dependency-management workflow support.

Protected AI Paths

The AI repair implementation explicitly protects:

.github/
.git/
scripts/ai_repair.py
scripts/requirements-ai-repair.txt

from AI-generated patch modifications.

Security Reporting

The repository includes a dedicated security policy and directs vulnerability reports through GitHub's private vulnerability-reporting mechanism where available.

Future Security Direction

Long-term development may include:

dependency auditing

stronger artifact verification

reproducible-build workflows

hardened update mechanisms

secure extension boundaries

runtime integrity verification

deeper release validation


VoidOne does not claim a security certification or guarantee.


---

Technology Stack

Technology	Role

C++23	Native application and platform core
Qt 6.8	Desktop framework and application runtime
QML / Qt Quick	Declarative UI and presentation layer
SQLite / Qt SQL	Local persistent game-library storage
CMake 3.25+	Build configuration and project orchestration
Ninja	Primary build generator
CTest	Test execution integration
GitHub Actions	CI/CD, packaging, release automation
CodeQL	Security-oriented static analysis
cppcheck	Additional C/C++ static analysis
WiX Toolset	Windows MSI packaging
Python	AI repair orchestration tooling
Gemini	CI failure analysis in the AI repair workflow
Ollama	Local model runtime for repair fallback
Qwen2.5-Coder	Local code-generation/repair model



---

CI/CD

The repository's primary workflow is:

VoidOne Ultimate Enterprise CI/CD

The current pipeline is centered on Windows release engineering.

Verified pipeline stages

SemVer Validation
      ↓
Static Analysis
      ├── CodeQL
      └── cppcheck
      ↓
Windows Build
      ↓
Qt Deployment
      ↓
Package Validation
      ↓
Windows Distribution Artifacts
      ↓
GitHub Release Publication

The Windows build job currently prepares a release package using:

MSVC x64

Qt 6.8

CMake

Ninja

ccache

windeployqt

WiX packaging

optional NSIS tooling


The workflow also generates SHA-256 checksums for produced distribution artifacts.

Release Tags

Release publication is tied to v* tags and validates semantic-versioning formats such as:

v1.0.0
v1.2.3-beta.1
v2.0.0-rc.1

Exact release versions should always be taken from the repository's actual GitHub Releases page.


---

Download

Official releases are published through GitHub:

VoidOne Releases

Latest Release

The repository's current Windows CI pipeline is configured to produce:

Windows x64 portable ZIP packages

WiX MSI installers

SHA-256 checksum files for generated distribution artifacts


NSIS EXE packaging is conditionally supported by the workflow, but the current repository does not contain an installer.nsi script, so it is not treated as a verified release format.

Exact artifact names and versions should be taken directly from the release page rather than hardcoded into documentation.

SHA-256 Verification

For a downloaded portable archive:

Get-FileHash .\VoidOne-Windows-x64-Portable-<version>.zip -Algorithm SHA256

For a generated MSI:

Get-FileHash .\VoidOne-Setup-x64-<version>.msi -Algorithm SHA256

Compare the result against the corresponding .sha256 file published with the release.


---

Build

VoidOne is primarily developed around Windows + MSVC + Qt 6.8, while the source tree also contains platform-specific Linux logic, including Linux Steam discovery paths.

The current repository's release pipeline is Windows-focused.

Prerequisites

Windows

Windows 10 or later

Visual Studio 2022 or Visual Studio Build Tools 2022

MSVC x64 toolchain

Qt 6.8.x

CMake 3.25+

Ninja

Git


The Qt installation must contain the desktop MSVC 2022 x64 kit.

Linux

The codebase contains Linux-specific support and can be configured with:

a current Linux distribution

GCC or Clang with C++23 support

Qt 6.8+

CMake 3.25+

Ninja

Git

required Qt/system development packages


Linux is not currently the primary published release target in the repository's main packaging workflow.

Clone

git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne

Release Build

The repository provides a dedicated CMake preset:

cmake --preset release
cmake --build --preset release

Equivalent direct configuration:

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23
cmake --build build --config Release --parallel

Development Build

The repository also provides a development preset with:

Debug configuration

tests enabled

ASan/UBSan enabled where supported

LTO disabled


cmake --preset dev
cmake --build --preset dev

Custom Qt Path

When CMake cannot locate Qt automatically, provide the Qt installation explicitly.

Windows example:

cmake -S . -B build -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23 `
  -DCMAKE_PREFIX_PATH="C:\Qt\6.8.x\msvc2022_64"

Linux example:

cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_PREFIX_PATH="$HOME/Qt/6.8.x/gcc_64"

Build Options

The CMake project exposes several engineering switches:

Option	Default	Purpose

VOIDONE_BUILD_TESTS	OFF	Enable the test integration
VOIDONE_ENABLE_CONSOLE	ON	Keep the Windows console enabled
VOIDONE_WARNINGS_AS_ERRORS	OFF	Treat compiler warnings as errors
VOIDONE_ENABLE_LTO	ON	Enable Release LTO when supported
VOIDONE_ENABLE_SANITIZERS	OFF	Enable ASan/UBSan for Debug GCC/Clang builds
VOIDONE_ENABLE_CLANG_TIDY	OFF	Enable clang-tidy during compilation
VOIDONE_ENABLE_UNITY_BUILD	OFF	Enable CMake unity builds
VOIDONE_REPRODUCIBLE_BUILD	OFF	Enable best-effort reproducibility controls
VOIDONE_BUILD_DOCS	OFF	Generate Doxygen documentation when installed



---

Packaging

WiX MSI

The repository contains:

installer.wxs

and the main Windows CI workflow invokes WiX to produce an MSI installer.

The installer configuration includes:

per-machine installation

Add/Remove Programs integration

Start Menu shortcut

Desktop shortcut

application icon

embedded package files


The package version and artifact filename are resolved by the release workflow.

Portable Distribution

The CI pipeline deploys the Qt runtime with:

windeployqt

and creates a compressed Windows x64 portable archive.

The portable package is intended to contain the executable together with the runtime files required to launch the Qt application.


---

Testing

The build system is prepared for CTest and exposes test presets through CMakePresets.json.

Example development configuration:

cmake --preset dev
cmake --build --preset dev

CTest can then be invoked with:

ctest --test-dir build/dev --output-on-failure

The current repository does not contain a tests/ directory or committed test suite implementation.

That distinction matters:

> Testing infrastructure exists; a mature repository test suite does not yet.



The CI workflow also contains a CTest stage. Expanding actual automated tests remains part of the engineering roadmap.


---

Performance Policy

VoidOne is intended to remain a native, resource-conscious application, but performance claims must be evidence-based.

Benchmark dimensions

Future official benchmarks should identify at minimum:

Dimension	Example

Hardware	CPU / GPU / RAM
Operating System	Windows version / Linux distribution
Compiler	MSVC / GCC / Clang
Qt Version	Exact Qt build
Build Type	Debug / Release
Library Size	Number of indexed games
Cold Start	Process start to usable UI
Warm Start	Subsequent launch
Idle Memory	Steady-state working set
Peak Memory	Peak during scanning/loading
Scan Duration	Discovery completion time
Frame-Time	UI responsiveness under representative workloads


Performance targets may exist internally, but reproducible measurements are required before they become product claims.

VoidOne does not currently guarantee:

a specific RAM ceiling

a fixed startup time

a fixed frame rate

universal hardware performance


The engineering goal is simple:

Native architecture should provide a strong foundation for measurable performance, not an excuse for unsupported marketing numbers.


---

Roadmap

The roadmap separates what is already established from what is actively being built and what remains future work.

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


Phase II — Library Intelligence

Planned

[ ] Broader local game discovery

[ ] Improved library identity handling

[ ] Store-provider abstraction

[ ] Deduplication

[ ] Rich local metadata model

[ ] Better installation-state detection


Phase III — Experience

Planned

[ ] Richer library presentation

[ ] Dynamic theming

[ ] Responsive game-art presentation

[ ] Advanced personalization

[ ] Accessibility improvements

[ ] More complete localization architecture


Phase IV — Execution

Planned

[ ] Ghost Launch profiles

[ ] Custom launch arguments

[ ] Environment configuration

[ ] Process lifecycle controls

[ ] Background process policies

[ ] Per-game execution policies

[ ] Performance profiles


Phase V — Mod Platform

Planned

[ ] Mod profiles

[ ] Virtual file mapping

[ ] Non-destructive deployment

[ ] Dependency management

[ ] Load-order handling

[ ] Conflict detection

[ ] Compatibility validation


Phase VI — Intelligence

Planned

[ ] Local analytics

[ ] Performance history

[ ] Diagnostics

[ ] Crash analysis

[ ] Root-cause analysis

[ ] Regression detection

[ ] Expanded AI engineering workflows


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

Security controls should be integrated into engineering workflows instead of added after the architecture is complete.

Human-Controlled Automation

Automation should reduce repetitive engineering work without removing human accountability.

Long-Term Maintainability

Architecture decisions should optimize for the project that VoidOne may become, not only the feature being implemented today.


---

Repository Structure

The current repository remains intentionally compact.

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

Create a feature branch:

git checkout main
git pull origin main
git checkout -b feature/your-feature

Build the project:

cmake --preset dev
cmake --build --preset dev

Run the available tests:

ctest --test-dir build/dev --output-on-failure

Review your changes:

git status
git diff

Commit a focused change:

git add .
git commit -m "feat: improve Steam library discovery"

Push the branch:

git push origin feature/your-feature

Then open a Pull Request against main.

Pull Requests

A strong Pull Request should explain:

what changed

why it changed

affected components

validation performed

known limitations

screenshots for meaningful UI changes


Contribution Priorities

Useful contributions include:

C++

Qt / QML

testing

build engineering

packaging

security

documentation

UI/UX

platform integration

performance engineering


The strongest contributions are focused, reproducible, and easy to review.


---

Security Reporting

Please do not disclose security vulnerabilities through public GitHub Issues.

Use the repository's security reporting process instead:

Security Policy

Security reports should include enough information to reproduce and assess the problem without exposing credentials, personal data, or unrelated systems.


---

Related Documentation

Build Guide

Troubleshooting

Security Policy

Persian README

GitHub Repository

GitHub Releases

Latest Release



---

License

VoidOne is distributed under the MIT License.

The repository's LICENSE file is the authoritative source for the exact license text and copyright notice.

See:

LICENSE


---

<div align="center">🌌 VoidOne

Your Games. Your Hardware. Your Rules.

Built by a gamer. Engineered for performance. Built in the open.

<p>
  <a href="https://github.com/VoidOne-App/VoidOne">
    <img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=for-the-badge&logo=github" alt="Star VoidOne on GitHub">
  </a>
</p><p><strong>Built by a gamer. Engineered like a platform.</strong></p></div>
