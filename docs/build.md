# VoidOne Build Guide

VoidOne is a native C++23 / Qt 6 desktop application. The repository uses CMake presets so local development and CI share the same build vocabulary.

> VoidOne is in active development. Requirements and build behavior may evolve.

## 1. Requirements

### Windows — primary platform

- Windows 10 or Windows 11, x64
- Visual Studio 2022 or Build Tools with MSVC x64
- Qt 6.11.x with the MSVC 2022 64-bit kit
- CMake 3.25+
- Ninja
- Git

### Linux

- Recent 64-bit Linux distribution
- GCC or Clang with C++23 support
- Qt 6
- CMake 3.25+
- Ninja
- Git

Linux support is part of the project direction, but Windows is currently the primary release platform.

### macOS

macOS is not currently part of the primary build/test/release pipeline.

## 2. Clone

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
```

## 3. Configure Qt

If Qt is not discoverable by CMake, set `CMAKE_PREFIX_PATH` to the appropriate Qt kit.

Windows example:

```powershell
cmake --preset release -DCMAKE_PREFIX_PATH="C:\Qt\6.11.2\msvc2022_64"
```

Linux example:

```bash
cmake --preset release -DCMAKE_PREFIX_PATH="$HOME/Qt/6.11.2/gcc_64"
```

## 4. CMake presets

The repository provides these supported presets:

| Preset | Purpose |
|---|---|
| `dev` | Debug development, tests, sanitizers |
| `release` | Local optimized release with tests |
| `ci-windows` | Strict Windows CI configuration |
| `reproducible` | Reproducibility verification |

Configure a preset:

```bash
cmake --preset dev
```

or:

```bash
cmake --preset release
```

Build using the matching build preset:

```bash
cmake --build --preset dev
```

```bash
cmake --build --preset release
```

## 5. Run tests

```bash
ctest --preset dev
```

For a release-style validation build:

```bash
ctest --preset release
```

For CI-equivalent Windows validation:

```bash
cmake --preset ci-windows
cmake --build --preset ci-windows
ctest --preset ci-windows
```

CTest is the authoritative test entry point. Use `--output-on-failure` when diagnosing a failing test locally.

## 6. Manual CMake configuration

Presets are preferred, but a direct configure remains supported:

```bash
cmake -S . -B build/manual -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DVOIDONE_BUILD_TESTS=ON
```

Build:

```bash
cmake --build build/manual --parallel
```

## 7. Run the application

The exact binary location depends on the selected preset. To locate it on Windows:

```powershell
Get-ChildItem build -Filter VoidOne.exe -Recurse -File
```

On Linux:

```bash
find build -type f -executable -name 'VoidOne*'
```

## 8. Windows packaging

Release packaging is performed by GitHub Actions and should be reproduced from the repository root.

The packaging flow stages the application under `package/`, deploys Qt with `windeployqt`, and then builds:

- `dist/VoidOne-Setup-x64.exe`
- `dist/VoidOne-Portable-x64.zip`

The NSIS source is located at:

```text
packaging/windows/installer.nsi
```

The installer expects its inputs from repository-root paths and therefore remains safe to invoke from the repository CI workflow.

## 9. Clean builds

When changing Qt versions, toolchains, presets, or major CMake configuration, prefer a clean build directory:

```powershell
Remove-Item build -Recurse -Force
```

Then configure again with the desired preset.

Do not commit generated directories. The repository `.gitignore` excludes build, package, distribution, IDE, and common compiler artifacts.

## 10. Reproducible verification

The `reproducible` preset requires `SOURCE_DATE_EPOCH` to be set before configuration.

Example in PowerShell:

```powershell
$env:SOURCE_DATE_EPOCH = "<unix-timestamp>"
cmake --preset reproducible
cmake --build --preset reproducible
```

The goal is deterministic build metadata and normalized compiler paths where the selected toolchain supports them.

## 11. CI source of truth

The Windows workflow is:

```text
.github/workflows/c.cpp.yml
```

It performs source checkout, toolchain setup, version resolution, CMake build, tests, Qt deployment, installer validation, NSIS packaging, optional signing, portable packaging, artifact upload, and release publication for tags.

When this document and the workflow disagree about an implementation detail, the workflow and the actual build scripts are authoritative.
