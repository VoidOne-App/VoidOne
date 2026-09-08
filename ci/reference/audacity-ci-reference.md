# Audacity CI Reference for VoidOne

This document records patterns from Audacity AU4 CI that are useful as architecture references for VoidOne. It is intentionally a reference, not a copy of Audacity project-specific build logic.

## Reference sources

- Audacity Windows build workflow: `.github/workflows/au4_build_windows.yml`
- Audacity Linux build workflow: `.github/workflows/au4_build_linux.yml`
- Audacity unit-test workflow: `.github/workflows/au4_check_unit_tests.yml`
- Audacity dependency matrix: `.github/workflows/au4_deps_matrix.yml`
- Reusable CI actions: `audacity/audacity-actions`

Audacity's reusable actions separate dependency setup, CMake configuration, build, and packaging. The configure action establishes a deterministic build directory and build configuration, while package produces a deployable artifact. See the upstream action documentation for the current implementation.

## Patterns VoidOne should adopt

1. **Deterministic toolchain setup**
   - Pin important tool versions instead of depending on runner defaults.
   - Keep compiler, Qt, CMake, Ninja, and deployment tooling explicit.

2. **Clear CI stages**
   - Dependencies -> configure -> build -> test -> deploy/package -> runtime validation.
   - Keep build artifacts as the boundary between build jobs and runtime QA jobs.

3. **Stable build directory contract**
   - Define one explicit CMake build directory per configuration.
   - Never assume a `build/` directory exists on another GitHub-hosted job; jobs run on isolated machines.

4. **Deployment is a first-class stage**
   - Validate the actual packaged application, not only the compiler output.
   - Verify Qt libraries, Qt platform plugins, QML imports, SQLite plugins, and Microsoft runtime dependencies.

5. **Tests are separated from packaging concerns**
   - Run CTest immediately after the build where the build tree exists.
   - Use packaged artifacts for tests that specifically validate deployment/runtime behavior.

6. **Matrix coverage where it has real value**
   - Use matrices for configurations/backends that can actually be exercised by the runner.
   - Do not treat a generic Windows hosted VM as equivalent to a physical GPU test machine.

7. **Reusable automation over giant YAML files**
   - If VoidOne's CI grows, extract repeated setup/deployment logic into small reusable composite actions or scripts.
   - Keep project-specific policy in VoidOne workflows.

## What NOT to copy

- Audacity-specific Conan recipes and dependency versions.
- Audacity-specific targets, build levels, signing, Sentry, Artifactory, or packaging conventions.
- Audacity's application-specific environment variables.
- Any workaround whose only purpose is to support Audacity's architecture.

## AI usage policy

When an AI system is given this reference, the instruction should be:

> Analyze the referenced Audacity CI architecture and extract reusable engineering patterns. Adapt those patterns to VoidOne's C++23 + Qt 6.11.2 + QML/Qt Quick + SQLite + CMake + Ninja + Windows x64 architecture. Do not copy project-specific dependencies, targets, paths, packaging rules, credentials, or assumptions. Preserve VoidOne's existing product behavior unless a change is explicitly required to fix a verified build/runtime problem.

The goal is to make VoidOne's CI more deterministic and maintainable, not to turn VoidOne into an Audacity clone.
