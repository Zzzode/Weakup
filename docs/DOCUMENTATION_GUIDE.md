# Documentation Organization Guide

**Last Updated**: 2026-02-22
**Version**: 1.0

This guide explains how documentation is organized in the Weakup project and provides guidelines for maintaining it.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Directory Structure](#directory-structure)
3. [File Locations](#file-locations)
4. [Naming Conventions](#naming-conventions)
5. [Content Guidelines](#content-guidelines)
6. [Maintenance Process](#maintenance-process)

---

## Overview

The Weakup project maintains comprehensive documentation organized into logical categories. This structure makes it easy to find information and keeps the repository clean.

### Design Principles

1. **Visibility** - User-facing docs stay in root for easy discovery
2. **Organization** - Technical docs grouped by purpose
3. **Clarity** - Clear naming and consistent structure
4. **Maintenance** - Regular reviews and archiving of outdated content

---

## Directory Structure

```
Weakup/
├── README.md                    # Project overview (English)
├── README.zh.md                 # Project overview (Chinese)
├── CHANGELOG.md                 # Version history
├── CONTRIBUTING.md              # Contribution guide (English)
├── CONTRIBUTING.zh.md           # Contribution guide (Chinese)
├── CLAUDE.md                    # AI assistant guide
│
├── docs/                        # Technical documentation
│   ├── README.md                # Documentation index (this helps!)
│   ├── ARCHITECTURE.md          # System architecture
│   ├── TESTING.md               # Testing strategy
│   ├── TEST_SPECIFICATIONS.md   # Detailed test cases
│   ├── DEVELOPMENT.md           # Development setup
│   ├── TRANSLATIONS.md          # Localization guide
│   ├── CODE_SIGNING.md          # Code signing guide
│   ├── HOMEBREW.md              # Homebrew distribution
│   ├── PRIVACY.md               # Privacy policy
│   │
│   ├── development/             # Development process docs
│   │   ├── SPRINT_PLAN.md
│   │   ├── RISK_ASSESSMENT.md
│   │   ├── TEST_EXECUTION_PLAN.md
│   │   └── QA_PLAN.md
│   │
│   ├── releases/                # Release documentation
│   │   ├── RELEASE_NOTES_v1.1.0.md
│   │   ├── RELEASE_READINESS_REPORT.md
│   │   └── TEST_REPORT.md
│   │
│   └── archive/                 # Archived/superseded docs
│       ├── ARCHITECTURE_DIAGRAMS.md
│       ├── ARCHITECTURE_SUMMARY.md
│       ├── REFACTORING_PLAN.md
│       └── TEST_INFRASTRUCTURE.md
│
└── screenshots/                 # Visual assets
    ├── README.md
    └── *.png
```

---

## File Locations

### Root Level (`/`)

**Purpose**: High-visibility, user-facing documentation

**Files**:
- `README.md` / `README.zh.md` - Project overview, installation, quick start
- `CHANGELOG.md` - Version history and release notes
- `CONTRIBUTING.md` / `CONTRIBUTING.zh.md` - How to contribute
- `CLAUDE.md` - Context for AI assistants (development guide)

**When to add here**:
- Documents that users need to see immediately
- Frequently accessed reference documents
- Standard open-source project files

### Technical Docs (`/docs`)

**Purpose**: Core technical documentation for developers

**Files**:
- `ARCHITECTURE.md` - System design, patterns, components
- `TESTING.md` - Testing strategy and best practices
- `TEST_SPECIFICATIONS.md` - Detailed test case specifications
- `DEVELOPMENT.md` - Setup, build, debug workflows
- `TRANSLATIONS.md` - Localization and i18n guide
- `CODE_SIGNING.md` - Signing and notarization
- `HOMEBREW.md` - Homebrew formula maintenance
- `PRIVACY.md` - Privacy policy

**When to add here**:
- Technical architecture documents
- Development guides
- Testing documentation
- Deployment procedures

### Development Process (`/docs/development`)

**Purpose**: Sprint planning, risk assessment, and process documentation

**Files**:
- `SPRINT_PLAN.md` - Sprint breakdown and timeline
- `RISK_ASSESSMENT.md` - Risk analysis and mitigation
- `TEST_EXECUTION_PLAN.md` - QA procedures
- `QA_PLAN.md` - Quality assurance strategy

**When to add here**:
- Sprint planning documents
- Project management artifacts
- Process documentation
- Risk and quality assessments

### Release Documentation (`/docs/releases`)

**Purpose**: Version-specific release artifacts

**Files**:
- `RELEASE_NOTES_vX.Y.Z.md` - User-facing release notes
- `RELEASE_READINESS_REPORT.md` - Internal release approval
- `TEST_REPORT.md` - Final QA results

**When to add here**:
- Release notes for each version
- Release approval documents
- Final test reports
- Version-specific announcements

### Archived Docs (`/docs/archive`)

**Purpose**: Historical documents that have been superseded

**Files**:
- Old architecture documents
- Completed refactoring plans
- Superseded technical specs
- Historical process documents

**When to add here**:
- Documents replaced by newer versions
- Completed planning documents
- Historical reference material
- Outdated technical specs

---

## Naming Conventions

### File Names

1. **UPPERCASE for major docs**: `ARCHITECTURE.md`, `TESTING.md`
2. **Descriptive names**: Use clear, specific names
3. **Version numbers**: Include in release docs (`RELEASE_NOTES_v1.1.0.md`)
4. **Language suffix**: Use `.zh.md` for Chinese versions
5. **No spaces**: Use underscores or hyphens (`TEST_SPECIFICATIONS.md`)

### Examples

✅ **Good**:
- `ARCHITECTURE.md` - Clear, uppercase major doc
- `RELEASE_NOTES_v1.1.0.md` - Includes version
- `README.zh.md` - Language suffix
- `TEST_EXECUTION_PLAN.md` - Descriptive

❌ **Bad**:
- `arch.md` - Too abbreviated
- `release notes.md` - Contains space
- `doc1.md` - Not descriptive
- `README_Chinese.md` - Use `.zh.md` suffix

---

## Content Guidelines

### Document Structure

Every document should have:

1. **Title** - Clear H1 heading at the top
2. **Metadata** (optional) - Date, version, author
3. **Table of Contents** - For docs > 200 lines
4. **Introduction** - Purpose and scope
5. **Main Content** - Well-organized sections
6. **References** (optional) - Links to related docs

### Markdown Formatting

**Headings**:
```markdown
# H1 - Document Title
## H2 - Major Section
### H3 - Subsection
#### H4 - Detail Level
```

**Code Blocks**:
````markdown
```swift
// Swift code with syntax highlighting
func example() { }
```
````

**Lists**:
```markdown
- Unordered list
  - Nested item

1. Ordered list
2. Second item
```

**Links**:
```markdown
[Text](path/to/file.md)
[External](https://example.com)
```

**Tables**:
```markdown
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |
```

### Writing Style

1. **Be Clear** - Use simple, direct language
2. **Be Concise** - Avoid unnecessary words
3. **Be Specific** - Include concrete examples
4. **Be Consistent** - Follow existing patterns
5. **Be Helpful** - Think about the reader's needs

### Code Examples

- Include working code snippets
- Add comments to explain complex parts
- Show both correct and incorrect usage when helpful
- Use syntax highlighting

---

## Maintenance Process

### Regular Reviews

**Quarterly Review** (every 3 months):
1. Check all docs for accuracy
2. Update outdated information
3. Fix broken links
4. Archive superseded documents
5. Update version numbers and dates

### When to Archive

Move documents to `/docs/archive` when:
- Replaced by a newer version
- Planning/process docs are completed
- Technical specs are outdated
- No longer relevant to current development

### When to Update

Update documentation when:
- Code changes affect documented behavior
- New features are added
- Architecture changes
- Process improvements
- User feedback indicates confusion

### Version Control

- Commit documentation changes with code changes
- Use descriptive commit messages
- Reference issue/PR numbers when applicable
- Review docs in pull requests

---

## Quick Reference

### Adding New Documentation

1. **Determine category**:
   - User-facing? → Root
   - Technical? → `/docs`
   - Process? → `/docs/development`
   - Release? → `/docs/releases`

2. **Choose name**: Follow naming conventions

3. **Create file**: Use template structure

4. **Update index**: Add to `/docs/README.md`

5. **Cross-reference**: Update related docs

### Moving Documentation

1. **Move file** to new location
2. **Update all references** in other docs
3. **Test links** to ensure they work
4. **Update index** (`/docs/README.md`)
5. **Commit with explanation**

### Archiving Documentation

1. **Move to** `/docs/archive`
2. **Add note** at top explaining why archived
3. **Remove from** main index
4. **Update references** in other docs
5. **Keep in git history**

---

## Examples

### Good Documentation Structure

```markdown
# Feature Name

**Version**: 1.0
**Last Updated**: 2026-02-22
**Author**: Team Name

## Overview

Brief description of the feature and its purpose.

## Table of Contents

1. [Installation](#installation)
2. [Usage](#usage)
3. [Examples](#examples)
4. [API Reference](#api-reference)

## Installation

Step-by-step installation instructions...

## Usage

How to use the feature...

## Examples

### Example 1: Basic Usage

```swift
// Code example
```

## API Reference

Detailed API documentation...

## See Also

- [Related Doc 1](path/to/doc1.md)
- [Related Doc 2](path/to/doc2.md)
```

---

## Questions?

If you have questions about documentation:

1. Check this guide first
2. Look at existing docs for examples
3. Ask in pull request reviews
4. Propose improvements to this guide

---

**Remember**: Good documentation is as important as good code. Take time to write clear, helpful documentation that makes the project accessible to everyone.
