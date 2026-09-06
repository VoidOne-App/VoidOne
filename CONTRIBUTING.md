# Contributing to VoidOne

Thank you for contributing to VoidOne. The project values small, reviewable changes, evidence-based engineering, and a stable development workflow.

## Before you start

- Read the [README](README.md).
- Read the [Build Guide](docs/build.md).
- Check [Troubleshooting](docs/troubleshooting.md) before reporting a known build issue.
- For security-sensitive issues, follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Development workflow

1. Create a focused branch from `main`.
2. Make the smallest coherent change that solves the problem.
3. Build using a repository CMake preset.
4. Run the relevant tests.
5. Check formatting and generated-file changes.
6. Update documentation when behavior or developer workflow changes.
7. Open a pull request with a clear description and test evidence.

Recommended local validation:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

For Windows CI-equivalent validation:

```bash
cmake --preset ci-windows
cmake --build --preset ci-windows
ctest --preset ci-windows
```

## Repository structure

```text
VoidOne/
├── .ai/                     # AI-assisted engineering infrastructure
├── .github/                 # CI/CD and repository automation
├── assets/                  # Source-controlled application assets
├── cmake/                   # CMake templates/helpers
├── docs/                    # Engineering and user documentation
├── packaging/windows/       # Windows installer and distribution definitions
├── scripts/                 # Developer and CI scripts
├── src/                     # Application source
│   ├── core/                # Native/domain services
│   └── ui/                  # QML/presentation layer
├── tests/                   # Automated tests
├── CMakeLists.txt           # Build definition
└── CMakePresets.json        # Supported build/test presets
```

Generated output belongs in `build/`, `package/`, or `dist/` and must not be committed.

## Code guidelines

### C++

- Use modern C++23 facilities where they improve clarity and safety.
- Prefer RAII and explicit ownership.
- Keep public interfaces small and stable.
- Avoid unnecessary global state.
- Treat compiler warnings as defects; CI uses warnings-as-errors.
- Keep platform-specific code isolated behind clear boundaries.

### Qt / QML

- Keep business and persistence logic in C++ core services.
- Keep QML focused on presentation and interaction.
- Avoid coupling UI components directly to database implementation details.
- Preserve existing QML module registration when adding or renaming QML files.

### Tests

- Add or update tests for behavior changes.
- Prefer deterministic tests that do not depend on network services.
- Keep test data isolated from real user data.
- When fixing a regression, add a test that would have caught it when practical.

## Commits and pull requests

Use concise conventional-style commit subjects when possible:

```text
feat: add library indexing
fix: handle missing Steam metadata
build: update Windows packaging
ci: validate release artifacts
docs: clarify local build workflow
```

Pull requests should explain:

- what changed
- why it changed
- how it was tested
- compatibility or migration impact
- performance/security considerations when relevant

Avoid mixing unrelated refactors with feature or bug-fix changes unless the refactor is required for correctness.

## CI and release changes

Changes to `.github/workflows/`, `packaging/windows/`, version handling, signing, or release publication are high-impact. Keep them narrowly scoped and validate them on a pull request before creating a release tag.

Git tags are the release version source of truth. Do not hard-code release versions into installer metadata.

## AI-assisted development

AI-generated code is treated as untrusted output. Review it like any other external contribution and run deterministic validation before merging.

See [AI-Assisted Code Repair](docs/engineering/ai-repair.md) for the repository's CI repair infrastructure.

## Security

Never commit:

- API keys
- passwords
- private certificates
- signing material
- personal access tokens
- local environment files containing secrets

If a secret is accidentally committed, rotate it immediately and follow the security reporting process.
