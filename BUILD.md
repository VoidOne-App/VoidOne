VoidOne Build Guide

This document explains how to build VoidOne from source.

«Development status: VoidOne is currently in active development. Build instructions and project requirements may change as the project evolves.»

---

🛠️ Prerequisites

Windows

- Windows 10 or Windows 11
- Visual Studio 2022 or Visual Studio Build Tools 2022
- MSVC x64 compiler
- Qt 6
- CMake
- Ninja
- Git

VoidOne is currently developed and tested primarily on Windows.

Linux

- A recent Linux distribution
- GCC or Clang
- Qt 6
- CMake
- Ninja
- Git
- Required system development libraries

Linux builds are currently tested through the project's CI pipeline.

macOS

macOS support is not currently part of the primary build/test configuration.

The project may support macOS in the future as the build system and platform integration mature.

---

📦 Installing Qt

VoidOne uses Qt 6 with QML.

You can obtain Qt from:

https://www.qt.io/download-open-source

For Windows, use a Qt installation containing the MSVC 2022 64-bit desktop kit.

For Linux, install the GCC 64-bit desktop kit.

---

📥 Clone the Repository

Clone the repository:

git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne


---

⚙️ Configure the Project

VoidOne uses CMake as its build system.

Windows

If Qt is available in your environment:

cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23

If CMake cannot automatically locate Qt, specify the Qt installation:

cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23 `
  -DCMAKE_PREFIX_PATH="C:\Qt\6.x.x\msvc2022_64"

Replace the path with the location of your Qt installation.

---

Linux

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23

If Qt cannot be found automatically:

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_PREFIX_PATH="$HOME/Qt/6.x.x/gcc_64"

---

🔨 Build

Build the project using:

cmake --build build --parallel

For a Debug build:

cmake \
  -S . \
  -B build-debug \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23

cmake --build build-debug --parallel

---

▶️ Running the Application

The exact executable location depends on the current CMake configuration.

To locate the executable after building:

Windows

Get-ChildItem build -Filter *.exe -Recurse

Linux

find build -type f -executable

Run the resulting executable from its build directory.

---

📦 Creating a Windows Release Package

For a distributable Windows build, the Qt runtime libraries must be deployed alongside the executable.

Qt provides the "windeployqt" tool for this purpose.

Example:

windeployqt `
  --release `
  --qmldir ".\src\ui\qml" `
  ".\build\path\to\VoidOneLauncher.exe"

The resulting directory should contain the executable and the required Qt runtime files.

You can then package the directory as a ZIP archive.

«The official GitHub Actions workflow performs this deployment automatically for Windows release builds.»

---

🐧 Linux Release Package

Linux release packaging is currently handled by the GitHub Actions workflow.

The CI pipeline:

1. Builds the Release configuration.
2. Installs the project into a package directory.
3. Verifies the executable.
4. Creates a ".tar.gz" archive.
5. Generates a SHA-256 checksum.
6. Uploads the resulting artifacts.

---

🧪 Tests

If the project has tests enabled, configure them with:

cmake \
  -S . \
  -B build-tests \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23 \
  -DNEONLAUNCHER_BUILD_TESTS=ON

Build:

cmake --build build-tests --parallel

Run:

ctest \
  --test-dir build-tests \
  --output-on-failure \
  --parallel 2

---

🔍 Static Analysis

The project can also be built using Clang and "clang-tidy".

Example:

cmake \
  -S . \
  -B build-analysis \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_CXX_CLANG_TIDY=clang-tidy

Then:

cmake --build build-analysis --parallel

---

🧹 Clean Build

If you encounter unexpected CMake or Qt configuration errors, remove the build directory and configure again.

Linux

rm -rf build

Windows PowerShell

Remove-Item -Recurse -Force build

Then configure and build again:

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23

cmake --build build --parallel

---

❗ Troubleshooting

Qt Not Found

If CMake reports that Qt cannot be found, verify that the correct Qt installation is being used.

Check your Qt path and pass it through:

CMAKE_PREFIX_PATH

For example:

-DCMAKE_PREFIX_PATH="C:\Qt\6.x.x\msvc2022_64"

or:

-DCMAKE_PREFIX_PATH="$HOME/Qt/6.x.x/gcc_64"

---

CMake Cannot Find Ninja

Install Ninja and make sure it is available in your "PATH".

Check:

ninja --version

---

Application Starts and Immediately Exits

Run the application from a terminal so that runtime output can be observed.

On Windows:

.\path\to\VoidOneLauncher.exe

On Linux:

./path/to/VoidOneLauncher

For development builds, Qt/QML debug output can help identify:

- QML loading failures
- Missing modules
- Missing runtime libraries
- Application initialization failures
- Incorrect resource paths

---

🤖 GitHub Actions

VoidOne uses GitHub Actions for automated builds and validation.

The CI pipeline currently includes:

- Windows Release
- Windows Debug
- Linux Release
- Linux Debug
- Unit Tests
- AddressSanitizer
- UndefinedBehaviorSanitizer
- Static Analysis
- QML validation
- Automated release packaging

You can view the workflow from the repository's Actions tab.

---

🌿 Development Workflow

Create a feature branch:

git checkout main
git pull origin main
git checkout -b feature/your-feature

Make your changes and test them locally.

Then commit:

git add .
git commit -m "Add your feature"

Push the branch:

git push origin feature/your-feature

Then open a Pull Request on GitHub.

---

🐛 Reporting Problems

When reporting a build or runtime problem, please include:

- Operating system
- Compiler
- Compiler version
- Qt version
- CMake version
- Relevant error messages
- Build configuration
- Steps to reproduce the problem

For runtime crashes, include any terminal or debug output available.

---

🤝 Contributing

Contributions are welcome.

You can contribute through:

- C++
- Qt / QML
- UI/UX
- Testing
- Documentation
- Bug reports
- Feature proposals
- Performance improvements
- Platform support

You do not need to be an expert to contribute.

---

📌 Current Development Focus

The project is currently focused on establishing a stable foundation:

- Reliable C++/Qt architecture
- QML application startup
- Cross-platform builds
- Automated CI/CD
- Release packaging
- Game detection
- Game library management

As the foundation becomes stable, additional launcher features will be introduced.

---

VoidOne — One launcher for your games.
