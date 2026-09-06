# Windows Release Engineering

This document describes the supported release path for VoidOne on Windows x64.

## Release source of truth

A release version comes from a Git tag:

```text
vMAJOR.MINOR.PATCH[-PRERELEASE]
```

Example:

```text
v0.0.2-beta.1
```

Pull-request builds do not publish releases and use an ephemeral development version based on the commit SHA.

## Pipeline

```text
Git tag / PR
    │
    ▼
Version resolution
    │
    ▼
CMake configure + build
    │
    ▼
CTest validation
    │
    ▼
windeployqt packaging
    │
    ├── VoidOne.exe
    ├── Qt runtime/plugins
    └── Windows platform plugin
    │
    ▼
NSIS installer
    │
    ├── VoidOne-Setup-x64.exe
    └── VoidOne-Portable-x64.zip
    │
    ▼
Optional Authenticode signing
    │
    ▼
Artifact validation
    │
    ▼
GitHub Release publication (tags only)
```

## Release artifacts

- `VoidOne-Setup-x64.exe` — full Windows installer.
- `VoidOne-Portable-x64.zip` — portable application package.

The installer and portable package are generated from the same staged `package/` directory to minimize divergence between distribution formats.

## Pre-release checklist

Before creating a release tag:

- [ ] C++ and QML changes are merged and reviewed.
- [ ] CMake configuration succeeds from a clean build directory.
- [ ] CTest passes.
- [ ] Windows x64 packaging succeeds.
- [ ] Installer input preflight passes.
- [ ] Installer metadata matches the Git tag.
- [ ] Portable ZIP contains the application and required Qt runtime.
- [ ] Signing secrets are configured if release signing is required.
- [ ] Release notes are reviewed after GitHub generates them.

## Versioning rules

Do not manually edit the application version in the installer for a release. The Git tag is authoritative; CI derives the human-readable and Windows numeric versions automatically.

The Windows PE version must remain numeric (`X.X.X.X`) even when the Git tag contains a prerelease suffix.

## Recovery

If packaging fails, fix the source or packaging issue and push a new commit. Do not reuse a broken release artifact.

If a tag has already been published with incorrect artifacts, treat the release as an incident: preserve the existing tag history, document the correction, and publish corrected artifacts according to the repository's release policy.
