# Security Policy

Security is a core part of VoidOne. Responsible disclosure helps protect users and the project.

## Supported versions

| Version | Security support |
|---|---|
| `main` / Development | 🟢 Supported |
| Latest stable release | 🟢 Supported |
| Older stable releases | 🟡 Best effort |
| End-of-life releases | 🔴 Not supported |

Support status may change as the project evolves.

## Reporting a vulnerability

**Do not publish security vulnerabilities through public GitHub Issues.**

Use GitHub's private vulnerability reporting when available:

`Repository → Security → Advisories → Report a vulnerability`

If private reporting is unavailable, contact the maintainers through the repository's official private contact channel.

A useful report should include:

- affected version or commit
- affected component
- clear reproduction steps
- expected and actual behavior
- security impact
- relevant logs or screenshots with secrets removed
- known mitigations or workarounds

Never include API keys, passwords, access tokens, private keys, or other secrets in a report.

## Response process

Maintainers aim to:

1. Acknowledge the report when possible.
2. Reproduce and assess the issue.
3. Determine severity and affected versions.
4. Develop and test a fix.
5. Release the fix when practical.
6. Publish an advisory when appropriate.

These are targets, not guarantees; complex issues may require additional investigation.

## Responsible testing

Only test systems and resources you are authorized to test. Avoid accessing or modifying other users' data, unnecessary denial-of-service testing, social engineering, or obtaining credentials that do not belong to you.

## Scope

Security reports may cover:

- application code and local privilege boundaries
- unsafe file or process handling
- code execution or command injection
- path traversal and memory-safety issues
- cryptography and secret handling
- dependencies
- update and distribution mechanisms
- CI/CD and release infrastructure

## Automated and AI-assisted tooling

VoidOne may use static analysis, sanitizers, dependency checks, CI validation, and AI-assisted development tooling. Automated systems do not replace human security review.

AI-generated changes are untrusted output and must pass deterministic validation and human review before release.

## Secrets

Never commit API keys, certificates, private keys, passwords, access tokens, or cloud credentials. If a secret is exposed, treat it as compromised and rotate or revoke it immediately.

Release signing material must remain in GitHub Actions secrets and must never be stored in the repository.

## Credits

With permission, responsible security researchers may be credited in a security advisory or release notes. Researchers may request anonymity.

## Policy changes

This policy may evolve with the project's architecture and security requirements. The repository version is authoritative.
