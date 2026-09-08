# Audacity → VoidOne CI Reconstruction Plan

## Goal

Use Audacity AU4 and `audacity-actions` as architectural references, not as copy/paste templates, and produce concrete changes for VoidOne's two primary Windows workflows:

- `.github/workflows/c.cpp.yml` — deterministic build, test, deployment and release packaging.
- `.github/workflows/full-system-qa.yml` — runtime, deployment and system validation.

VoidOne target stack: C++23, Qt 6.11.2, QML/Qt Quick, SQLite, CMake, Ninja, Windows x64/MSVC.

## 1. Rebuild `c.cpp.yml` around explicit lifecycle stages

Recommended stages:

1. `prepare-toolchain`
   - Pin the Windows runner image.
   - Install/activate the intended MSVC toolset explicitly.
   - Install an exact CMake version instead of relying on the runner's preinstalled version.
   - Install/pin Ninja.
   - Install the exact Qt version and architecture.
   - Print versions and compiler identity into the CI log.

2. `configure`
   - Use one canonical build directory, e.g. `build/Release` or `build` for Ninja.
   - Keep all CMake options in one clearly documented block.
   - Enable tests in CI.
   - Emit `compile_commands.json` for diagnostics.

3. `build`
   - Build with explicit parallelism.
   - Preserve compiler/linker output on failure.

4. `test`
   - Run CTest from the build directory created in the same job.
   - Publish test results/logs even when tests fail.

5. `deploy`
   - Stage `VoidOne.exe` into a clean package directory.
   - Run `windeployqt` with the QML source directory.
   - Explicitly validate Qt platform plugins, QML imports and SQLite plugin.
   - Explicitly bundle the required x64 MSVC runtime DLLs rather than assuming `windeployqt --compiler-runtime` is sufficient.

6. `package`
   - Build NSIS/MSI/portable outputs from the exact same staged payload.
   - Validate that every package contains the same runtime payload.
   - Generate SHA-256 manifests.

7. `artifact`
   - Upload the staged portable payload separately from installers.
   - Upload diagnostics independently so a failed package does not hide logs.

## 2. Rebuild `full-system-qa.yml` around package contracts

Every job must either:

- build what it needs in that job, or
- download an explicitly named artifact produced by `build`.

Never assume `build/` exists on a different GitHub-hosted job. Each hosted job is an isolated machine.

Recommended dependency graph:

```text
                discover
                   |
                build-test
              /    |     \
             /     |      \
       runtime   graphics  package-runtime
          |          |          |
          +----------+----------+
                     |
                package-QA
                     |
                  qa-gate
```

Independent fixture tests such as filesystem, network, Windows registry, synthetic Steam manifests and static QML checks can run in parallel.

## 3. Startup testing must test the application, not just process existence

For each startup test:

- create a unique temporary `APPDATA` and `LOCALAPPDATA`.
- enable `QT_DEBUG_PLUGINS=1` and `QML_IMPORT_TRACE=1`.
- capture stdout/stderr where possible.
- collect `%TEMP%/VoidOne-crash.log`.
- collect the VoidOne enterprise log directory.
- wait for a defined startup grace period.
- fail if the process exits before that period, even with exit code 0.
- terminate the process only after successful startup validation.

Do not treat "process stayed alive" as the only success criterion. Add at least one observable startup signal where practical: root QML object creation, a health marker, a test-only startup mode, or a log marker emitted after initialization.

## 4. Graphics QA should separate software validation from real GPU validation

Standard `windows-2025` runners are useful for:

- Qt Quick initialization
- software backend
- D3D/OpenGL plugin availability
- QML startup
- graphics-related diagnostics

They are not a substitute for a physical GPU compatibility matrix.

Keep the standard-runner graphics matrix, but label it as **graphics backend/runtime QA**, not hardware compatibility QA. Add a future optional GPU/self-hosted job for real hardware coverage.

## 5. Database and backup QA

Do not run CTest against a missing build directory in separate jobs.

Preferred design:

- Run unit tests immediately after build in the build job.
- If a later job needs a test binary, upload a small test-runtime artifact containing only the test executable plus required DLLs.
- For application-independent backup torture, use filesystem fixtures directly.
- For real `SaveBackupManager` behavior, add a dedicated test executable and run it from the build/test job or a downloaded test-runtime artifact.

Add failure-path cases:

- missing source
- invalid destination
- overlapping source/destination
- interrupted restore simulation
- rollback preservation
- Unicode paths
- deep paths
- repeated backup/prune cycles

## 6. Package validation

Create one canonical staged directory and make every package consume it.

Validate:

- `VoidOne.exe`
- Qt Core/Gui/Qml/Quick
- `platforms/qwindows.dll`
- Qt QML modules actually imported by the application
- SQLite plugin
- `msvcp140.dll`
- `vcruntime140.dll`
- `vcruntime140_1.dll`
- expected configuration/resources

Then perform a clean-machine smoke test from the packaged output.

## 7. Determinism rules

Do not rely on:

- whatever CMake happens to be preinstalled on the runner
- whatever Qt happens to be cached on the runner
- an existing `build/` directory
- an existing user's AppData
- a globally installed VC++ runtime

Pin or explicitly provision all build-critical dependencies.

## 8. AI task

The AI implementing this plan must first inspect:

- current `c.cpp.yml`
- current `full-system-qa.yml`
- `CMakeLists.txt`
- Qt deployment logic
- NSIS packaging
- existing tests
- `src/main.cpp`
- Audacity AU4 Windows/Linux build workflows
- Audacity unit-test workflow
- Audacity dependency matrix
- `audacity-actions/configure@v1`
- `audacity-actions/build@v1`
- `audacity-actions/package@v1`

Then produce a file-by-file patch plan with:

- exact file
- exact section/job
- current problem
- proposed change
- why the change follows a proven CI pattern
- risk/compatibility impact
- validation command

The AI must not copy Audacity-specific dependencies, targets, packaging formats, licensing assumptions, or application logic.

## Acceptance criteria

The reconstruction is considered successful when:

1. A fresh Windows runner can build VoidOne without depending on preinstalled CMake version drift.
2. CTest runs in a job that actually contains the build tree or an explicitly downloaded test artifact.
3. The staged portable application starts on a clean runner.
4. Qt/QML/platform/SQLite dependencies are validated before packaging passes.
5. VC++ runtime DLLs are explicitly present in the portable payload.
6. NSIS/MSI/portable outputs derive from the same staged application payload.
7. Startup failures leave actionable crash/QML/plugin logs as artifacts.
8. QA jobs never assume filesystem state from another job.
9. The final QA gate reports the exact failing stage instead of hiding the root cause.
