# Weakup Documentation Index

This directory contains all technical documentation for the Weakup project.

## 📚 Core Documentation

### Architecture & Design
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Complete system architecture, design patterns, component diagrams, and dependency management
- **[TESTING.md](TESTING.md)** - Testing strategy, test pyramid, coverage targets, and best practices
- **[TEST_SPECIFICATIONS.md](TEST_SPECIFICATIONS.md)** - Detailed test cases covering all 150+ test specifications

### Development
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Development environment setup, build process, debugging tips
- **[TRANSLATIONS.md](TRANSLATIONS.md)** - Localization guide, adding new languages, translation workflow

### Deployment
- **[CODE_SIGNING.md](CODE_SIGNING.md)** - Code signing and notarization for macOS distribution
- **[HOMEBREW.md](HOMEBREW.md)** - Homebrew formula creation and maintenance

### Legal & Privacy
- **[PRIVACY.md](PRIVACY.md)** - Privacy policy and data handling practices

---

## 🚀 Release Documentation

Release-specific documentation for each version:

### v1.1.0 (Current)
- **[RELEASE_NOTES_v1.1.0.md](releases/RELEASE_NOTES_v1.1.0.md)** - User-facing release notes
- **[RELEASE_READINESS_REPORT.md](releases/RELEASE_READINESS_REPORT.md)** - Internal release approval
- **[TEST_REPORT.md](releases/TEST_REPORT.md)** - Final QA test results (462/462 tests passing)

---

## 🛠️ Development Process

Documentation from the development process (for reference):

- **[SPRINT_PLAN.md](development/SPRINT_PLAN.md)** - 5-sprint development plan with task breakdown
- **[RISK_ASSESSMENT.md](development/RISK_ASSESSMENT.md)** - Risk analysis and mitigation strategies
- **[TEST_EXECUTION_PLAN.md](development/TEST_EXECUTION_PLAN.md)** - QA test execution procedures
- **[QA_PLAN.md](development/QA_PLAN.md)** - Quality assurance strategy

---

## 📦 Archived Documentation

Historical documents that have been superseded:

- **[ARCHITECTURE_DIAGRAMS.md](archive/ARCHITECTURE_DIAGRAMS.md)** - Old architecture diagrams
- **[ARCHITECTURE_SUMMARY.md](archive/ARCHITECTURE_SUMMARY.md)** - Old architecture summary
- **[REFACTORING_PLAN.md](archive/REFACTORING_PLAN.md)** - Completed refactoring plans
- **[TEST_INFRASTRUCTURE.md](archive/TEST_INFRASTRUCTURE.md)** - Old test infrastructure docs

---

## 🔍 Quick Links by Role

### For New Developers
1. Start with [DEVELOPMENT.md](DEVELOPMENT.md) - Setup your environment
2. Read [ARCHITECTURE.md](ARCHITECTURE.md) - Understand the system
3. Review [TESTING.md](TESTING.md) - Learn testing practices
4. Check [TRANSLATIONS.md](TRANSLATIONS.md) - If working on localization

### For QA Engineers
1. [TEST_SPECIFICATIONS.md](TEST_SPECIFICATIONS.md) - All test cases
2. [TESTING.md](TESTING.md) - Testing strategy
3. [TEST_REPORT.md](releases/TEST_REPORT.md) - Latest test results

### For Release Managers
1. [CODE_SIGNING.md](CODE_SIGNING.md) - Signing and notarization
2. [HOMEBREW.md](HOMEBREW.md) - Homebrew distribution
3. [RELEASE_NOTES_v1.1.0.md](releases/RELEASE_NOTES_v1.1.0.md) - Release notes template

### For Contributors
1. [../CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
2. [DEVELOPMENT.md](DEVELOPMENT.md) - Development workflow
3. [TRANSLATIONS.md](TRANSLATIONS.md) - Translation contributions

---

## 📝 Documentation Standards

### File Organization
- **Root `/docs`** - Core technical documentation
- **`/docs/development`** - Process and planning documents
- **`/docs/releases`** - Version-specific release documentation
- **`/docs/archive`** - Historical/superseded documents

### Naming Conventions
- Use UPPERCASE for major documents (e.g., `ARCHITECTURE.md`)
- Include version numbers for release docs (e.g., `RELEASE_NOTES_v1.1.0.md`)
- Use descriptive names that indicate content

### Content Guidelines
- Start with clear title and purpose
- Include table of contents for long documents (>200 lines)
- Use consistent Markdown formatting
- Add code examples where helpful
- Keep language clear and concise

---

## 🔄 Keeping Documentation Updated

- Review quarterly for accuracy
- Archive superseded documents to `/archive`
- Update cross-references when moving files
- Keep [CHANGELOG.md](../CHANGELOG.md) current with each release

---

**Last Updated**: 2026-02-22
**Project Version**: 1.1.0
