# Contributing to VoidOne

First off, thanks for considering contributing — VoidOne is built entirely by
and for the community, and every contribution matters, whether it's a bug
report, a UI polish, or a new feature.

## Before You Start

- Check the [roadmap](README.md#-engineering-roadmap) to see what's already planned.
- Search [existing issues](https://github.com/VoidOne-App/VoidOne/issues) and
  [pull requests](https://github.com/VoidOne-App/VoidOne/pulls) to avoid duplicate work.
- For anything non-trivial, consider opening an issue first to discuss the
  approach before writing a lot of code.

## Development Setup

See [Building from Source](README.md#-building-from-source) in the README for
toolchain requirements. Once set up, use the CMake presets for a consistent
environment:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

The `dev` preset enables Debug symbols, AddressSanitizer/UBSan, and the test
suite — this is what you want for day-to-day development.

## Code Style

- Match the existing style in the file you're editing (brace placement,
  naming conventions, header guards).
- Run with `-DVOIDONE_ENABLE_CLANG_TIDY=ON` if you have `clang-tidy` installed
  — it'll catch most style/correctness issues before you even open a PR.
- Keep commits focused: one logical change per commit makes review much easier.

## Commit Messages

We loosely follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add save backup compression
fix: correct SteamScanner path resolution on non-C: drives
docs: update build instructions for Qt 6.9
ci: add retry logic to WiX install step
```

This isn't strictly enforced, but it makes the auto-generated changelog in
each release much more useful.

## Submitting a Pull Request

1. Fork the repository and create a branch off `main`.
2. Make your changes, following the checklist in the PR template.
3. Make sure `cmake --preset ci-windows` still builds cleanly and tests pass
   locally before opening the PR — this is exactly what CI will check.
4. Open the PR against `main` and fill out the template.
5. A maintainer will review — expect some back-and-forth, that's normal and
   not a sign anything is wrong with your contribution.

## What We Won't Merge

In line with [VoidOne's Promise](README.md#-voidones-promise--gamer-to-gamer),
we won't accept contributions that add:

- Telemetry, analytics, or any form of usage tracking
- Ads or sponsored content inside the app
- Bundled third-party software the user didn't explicitly ask for
- Mandatory online accounts for core (offline-capable) functionality

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By
participating, you're expected to uphold it.

## Questions?

Open a [Discussion](https://github.com/VoidOne-App/VoidOne/discussions) or a
regular issue — there's no such thing as a question too small.
