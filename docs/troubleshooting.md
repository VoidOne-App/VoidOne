# VoidOne Troubleshooting

This guide covers the most common build, test, packaging, and runtime failures.

## Start with a clean build

When the failure follows a Qt, compiler, preset, or CMake change, remove the affected build directory and configure again:

```powershell
Remove-Item build -Recurse -Force -ErrorAction SilentlyContinue
cmake --preset dev
```

Avoid debugging stale CMake cache state when the configuration itself has changed.

## Qt cannot be found

Check the Qt kit and pass its root through `CMAKE_PREFIX_PATH`:

```powershell
cmake --preset release -DCMAKE_PREFIX_PATH="C:\Qt\6.11.2\msvc2022_64"
```

Confirm that the selected kit matches the compiler architecture. VoidOne's primary Windows pipeline uses MSVC x64.

## CMake configuration fails

Verify:

- CMake is 3.25 or newer.
- Ninja is installed and available on `PATH`.
- Qt 6.11.x is discoverable.
- You are building out of source.
- The selected preset exists in `CMakePresets.json`.

List presets:

```bash
cmake --list-presets
```

## Compilation warnings are treated as errors

The strict CI preset intentionally enables `VOIDONE_WARNINGS_AS_ERRORS=ON`.

For local iteration, use the `dev` preset. Fix warnings rather than suppressing them globally; CI is intended to keep the codebase warning-clean.

## Sanitizer build fails on Windows

The `dev` preset enables sanitizers in Debug mode. AddressSanitizer support depends on the installed MSVC toolchain. Ensure the selected compiler supports `/fsanitize=address` and that the build is actually Debug.

## Tests cannot load Qt plugins

For Windows tests, ensure the required Qt runtime and `platforms/qwindows.dll` are available. CI deploys Qt dependencies before running the test suite.

Useful diagnostic environment variables include:

```powershell
$env:QT_DEBUG_PLUGINS = "1"
$env:QT_LOGGING_RULES = "qt.sql.*=true"
```

Do not commit local diagnostic environment files.

## `VoidOne.exe` starts but QML fails

Check:

1. The QML module was generated successfully.
2. `src/ui/qml/` contains the QML files registered by `qt_add_qml_module`.
3. A packaged build was processed by `windeployqt` with the QML directory supplied.
4. The Qt version used to build and deploy the application is compatible.

For a packaged Windows build, inspect the generated `package/` directory before building the installer.

## Windows installer fails to compile

The supported installer source is:

```text
packaging/windows/installer.nsi
```

The script resolves repository inputs from its own location, so it can be invoked by CI without changing the working directory.

Required inputs include:

```text
assets/app-icon.ico
LICENSE
package/VoidOne.exe
package/platforms/qwindows.dll
```

The CI workflow validates these paths before invoking NSIS.

## Installer version errors

Git tags are the release source of truth. Human-readable versions may contain prerelease suffixes, while Windows PE versions must remain numeric.

For example:

```text
Git tag:       v0.0.2-beta.1
App version:   0.0.2-beta.1
PE version:    0.0.2.0
```

Do not pass a prerelease suffix directly to `VIProductVersion`.

## Installer says VoidOne is running

Close the running VoidOne application and retry. The installer deliberately avoids replacing files while the application is active.

## Repair mode

An existing installation can be repaired through the installer with:

```text
VoidOne-Setup-x64.exe /REPAIR
```

Repair mode reuses the registered installation directory and skips unnecessary setup pages.

## Packaging produces no installer

Check the CI logs in this order:

1. `Validate installer inputs`
2. `Build NSIS installer`
3. `dist/VoidOne-Setup-x64.exe` existence check

If the package is incomplete, fix the staging/deployment step before changing NSIS.

## Portable ZIP is missing runtime files

The portable package is created from the same `package/` directory used by the installer. Verify `windeployqt` completed successfully and that `package/platforms/qwindows.dll` exists.

## Release was not published

GitHub Release publication occurs only for tags matching `v*`. Pull-request and branch builds upload validation artifacts but do not publish releases.

## CI failed after a repository layout change

Check path-sensitive files first:

- `.github/workflows/c.cpp.yml`
- `CMakeLists.txt`
- `packaging/windows/installer.nsi`
- `CMakePresets.json`

Generated directories such as `build/`, `package/`, and `dist/` should never be used as source-controlled inputs.

## Reporting a bug

When opening an issue, include:

- operating system and architecture
- VoidOne version/commit
- compiler and Qt version
- exact command or preset used
- relevant error output
- whether the issue occurs in a clean build
- steps to reproduce

Never include passwords, API keys, certificates, or other secrets in logs or issues.
