# Security Policy

## 🔐 Security at VoidOne

Security is a core part of the VoidOne project.

We take security vulnerabilities seriously and appreciate responsible
disclosure from security researchers, developers, and users who help us
identify and fix issues before they can affect others.

If you believe you have discovered a security vulnerability in VoidOne,
please report it responsibly rather than publicly disclosing it.

---

## 📦 Supported Versions

Security fixes are currently provided for actively maintained releases.

| Version | Security Support |
| ------- | ---------------- |
| `main` / Development | 🟢 Supported |
| Latest Stable Release | 🟢 Supported |
| Older Stable Releases | 🟡 Limited / Best Effort |
| End-of-Life Releases | 🔴 Not Supported |

> **Note:** Development builds may receive security fixes before they are
> included in a stable release.

The exact support status of a release may change as the project evolves.

---

## 🚨 Reporting a Vulnerability

### Please do NOT report security vulnerabilities through public GitHub Issues.

Publicly reporting a vulnerability before it has been investigated and fixed
may expose VoidOne users to unnecessary risk.

Instead, please use GitHub's **private vulnerability reporting** feature:

**Repository → Security → Advisories → Report a vulnerability**

If private vulnerability reporting is unavailable, contact the VoidOne
maintainers through the repository's official contact channels.

---

## 📝 What to Include

A useful security report should contain as much of the following information
as possible:

- A clear description of the vulnerability
- The affected VoidOne version or commit
- The affected component or feature
- Steps required to reproduce the issue
- A minimal proof of concept, when appropriate
- Expected behavior
- Actual behavior
- Potential security impact
- Any known workarounds or mitigations
- Relevant logs, screenshots, or crash information

Please avoid including sensitive personal information, private credentials,
API keys, access tokens, or other secrets in your report.

---

## 🔎 Vulnerability Assessment

After receiving a report, the maintainers will:

1. Acknowledge the report when possible.
2. Reproduce and investigate the reported issue.
3. Determine its security impact and severity.
4. Identify affected versions and components.
5. Develop and test an appropriate fix.
6. Release the fix when practical.
7. Publish a security advisory when appropriate.

Reports may be closed if the issue cannot be reproduced, is determined not to
be a security vulnerability, or is outside the scope of the project.

---

## ⏱️ Response Expectations

We aim to:

| Stage | Target |
| ----- | ------ |
| Initial acknowledgement | Within 7 days |
| Initial assessment | Within 14 days |
| Critical vulnerability | Prioritized immediately |
| Security fix | As soon as reasonably possible |

These are targets rather than guarantees. Complex vulnerabilities may require
additional investigation and testing.

---

## 🛡️ Responsible Disclosure

Please allow the maintainers reasonable time to investigate and address a
reported vulnerability before publicly disclosing it.

We ask security researchers to avoid:

- Accessing or modifying other users' data
- Disrupting VoidOne services or infrastructure
- Destroying or modifying project data
- Performing unnecessary denial-of-service testing
- Social engineering project contributors
- Obtaining credentials or secrets that do not belong to you
- Publicly disclosing an unpatched vulnerability

Only test against systems and resources you are authorized to test.

---

## 🎯 Scope

Security reports may include vulnerabilities affecting:

- VoidOne application code
- Authentication and authorization mechanisms
- Local privilege or permission boundaries
- Unsafe file or process handling
- Remote or local code execution
- Command injection
- Path traversal
- Memory-safety issues
- Cryptographic or secret-handling problems
- Dependency-related vulnerabilities
- Update and distribution mechanisms
- Build and release infrastructure
- CI/CD security
- Other issues with a meaningful security impact

Reports about unrelated third-party software should generally be submitted to
the appropriate upstream project.

---

## 🤖 Automated Security & CI Systems

VoidOne may use automated tooling, including CI pipelines, static analysis,
sanitizers, dependency scanning, and AI-assisted development or repair tools.

Automated systems do **not** replace human security review.

AI-generated changes must be reviewed and validated before being considered
safe for release.

---

## 🔒 Secrets

Never commit the following to the repository:

- API keys
- Access tokens
- Passwords
- Private keys
- Authentication credentials
- Personal access tokens
- Cloud credentials
- Other sensitive secrets

If a secret is accidentally committed, treat it as compromised and rotate or
revoke it immediately.

---

## 🏆 Security Researchers

We appreciate responsible security researchers and contributors who help make
VoidOne safer.

With permission, security researchers who responsibly report valid
vulnerabilities may be credited in the relevant security advisory or release
notes.

If you would like to remain anonymous, please state this in your report.

---

## 📜 Policy Changes

This security policy may be updated as the VoidOne project, its architecture,
and its security requirements evolve.

The latest version of this document is always available in the repository.

---

**Thank you for helping keep VoidOne secure.** 🔐
