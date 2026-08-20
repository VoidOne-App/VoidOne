<div align="center">

# 🌌 VoidOne

**Next-Generation, Open-Source PC Game Launcher & Library Manager**

[![VoidOne CI/CD](https://img.shields.io/github/actions/workflow/status/mohammedmk3900-rgb/NeonLauncher-Qt/c-cpp.yml?branch=main&style=for-the-badge&logo=github&label=CI/CD)](https://github.com/mohammedmk3900-rgb/NeonLauncher-Qt)
[![CodeQL Security](https://img.shields.io/github/actions/workflow/status/mohammedmk3900-rgb/NeonLauncher-Qt/codeql.yml?branch=main&style=for-the-badge&logo=github&label=CodeQL)](https://github.com/mohammedmk3900-rgb/NeonLauncher-Qt)
[![C++23](https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus)](https://en.cppreference.com/w/cpp/23)
[![Qt 6.8](https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt)](https://www.qt.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <a href="#-about">About</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-building-from-source">Building</a> •
  <a href="#-autonomous-ci-repair">AI Engine</a> •
  <a href="#-roadmap">Roadmap</a>
</p>

---

</div>

## 👁️ About VoidOne

**VoidOne** is a blazing-fast, lightweight, open-source PC game launcher engineered with modern **C++23** and **Qt 6 / QML**. Built as a unified ecosystem for PC gamers, VoidOne bridges the gap between fragmented game distribution platforms (Steam, Epic Games, GOG, Xbox) and local execution—delivering a cyberpunk-inspired, highly customizable dashboard without the telemetry bloat.

> ⚠️ **Development Status:** VoidOne is under active early-stage development. Core architecture and APIs are evolving rapidly.

---

## ✨ Key Features

### 🎮 Unified Game Aggregator
* **Auto-Discovery:** Scans local drives and platform manifests to build a single master game library.
* **Rich Metadata Engine:** Fetches high-resolution cover arts, dynamic backgrounds, and game details automatically.
* **Session Analytics:** Tracks local playtime, recent activity, and launch statistics without privacy-invading metrics.

### 🎨 Cyberpunk QML Interface
* **GPU-Accelerated Visuals:** High-performance QML/QtQuick interface with smooth 60+ FPS animations.
* **Deep Customization:** Modular UI with dynamic theme switching, layouts, and dark mode native support.

### 🧩 Integrated Mod Engine
* **Profile Manager:** Create per-game mod profiles with one-click enable/disable states.
* **Load Order Control:** Granular control over mod installation paths and load hierarchies.

### 🤖 Self-Healing CI/CD Pipeline
* **Automated AI Repair:** Integrated LLM-driven repair agent (Gemini 2.5 Pro + Qwen2.5-Coder) that automatically analyzes CI build failures and submits auto-fix PRs.

---

## ⚙️ Tech Stack & Architecture

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Core Engine** | C++23 | Low-overhead application logic & system calls |
| **GUI Framework** | Qt 6.8 / QML | Declarative, GPU-rendered user interface |
| **Database** | SQLite3 | Thread-safe, embedded local metadata storage |
| **Build System** | CMake + Ninja | Cross-platform, parallelized build pipeline |
| **Integration** | WinAPI / Linux D-Bus | OS-level launcher & process hooks |
| **CI/CD** | GitHub Actions | Automated builds, CodeQL scanning & auto-remediation |

---

## 🔨 Building from Source

### Prerequisites
* **Compiler:** MSVC 2022 (Windows) / Clang 17+ or GCC 13+ (Linux) with **C++23** support
* **Framework:** Qt 6.8+ (Desktop & Quick modules)
* **Tools:** CMake 3.25+, Ninja build system, Git

### Quick Start

```bash
# 1. Clone the repository
git clone [https://github.com/mohammedmk3900-rgb/NeonLauncher-Qt.git](https://github.com/mohammedmk3900-rgb/NeonLauncher-Qt.git)
cd NeonLauncher-Qt

# 2. Configure build system
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23

# 3. Build parallel targets
cmake --build build --config Release --parallel
