# Risk Assessment Document

*Project: Weakup*
*Created: 2026-02-22*
*Author: Project Manager*

## Executive Summary

This document identifies potential risks to the Weakup project, assesses their impact and probability, and outlines mitigation strategies. The project involves implementing comprehensive test coverage, new features, and CI/CD improvements.

---

## Risk Matrix

| Probability / Impact | Low Impact | Medium Impact | High Impact |
|---------------------|------------|---------------|-------------|
| **High Probability** | Monitor | Mitigate | Critical |
| **Medium Probability** | Accept | Mitigate | Mitigate |
| **Low Probability** | Accept | Monitor | Mitigate |

---

## Identified Risks

### R1: IOPMAssertion Mocking Complexity

| Attribute | Value |
|-----------|-------|
| **Category** | Technical |
| **Probability** | Medium |
| **Impact** | High |
| **Risk Level** | Critical |

**Description:**
The IOPMAssertion API is a low-level IOKit function that directly interacts with macOS power management. Creating effective mocks or stubs for unit testing may be challenging, potentially leading to gaps in test coverage for the core sleep prevention functionality.

**Mitigation Strategies:**
1. Create an abstraction layer (protocol) around IOPMAssertion calls
2. Use dependency injection to swap real implementation with test doubles
3. Research existing open-source solutions for IOKit mocking
4. Consider integration tests that verify actual assertion behavior
5. Document any coverage gaps with justification

**Contingency Plan:**
If mocking proves infeasible, rely on integration tests with actual system calls and document the limitation in test coverage reports.

---

### R2: macOS Version Compatibility

| Attribute | Value |
|-----------|-------|
| **Category** | Technical |
| **Probability** | Medium |
| **Impact** | High |
| **Risk Level** | Critical |

**Description:**
The app targets macOS 13.0+, but API behavior may differ across versions (13.x, 14.x, 15.x). Features like Launch at Login, keyboard shortcuts, and IOPMAssertion may behave differently or have deprecated APIs.

**Mitigation Strategies:**
1. Test on multiple macOS versions in CI/CD pipeline
2. Use `@available` checks for version-specific APIs
3. Document minimum version requirements for each feature
4. Monitor Apple's deprecation notices
5. Maintain compatibility matrix in documentation

**Contingency Plan:**
If compatibility issues arise, implement version-specific code paths or adjust minimum supported version.

---

### R3: Keyboard Shortcut Conflicts

| Attribute | Value |
|-----------|-------|
| **Category** | User Experience |
| **Probability** | Medium |
| **Impact** | Medium |
| **Risk Level** | Mitigate |

**Description:**
The global keyboard shortcut (Cmd+Ctrl+0) may conflict with system shortcuts or other applications, causing the shortcut to fail silently or behave unexpectedly.

**Mitigation Strategies:**
1. Implement conflict detection (Task #8)
2. Provide user notification when conflicts are detected
3. Allow users to customize the shortcut
4. Document known conflicts
5. Implement graceful fallback behavior

**Contingency Plan:**
If conflict detection is too complex, provide clear documentation of known conflicts and manual resolution steps.

---

### R4: CI/CD Test Flakiness

| Attribute | Value |
|-----------|-------|
| **Category** | Process |
| **Probability** | Low |
| **Impact** | Medium |
| **Risk Level** | Monitor |

**Description:**
Automated tests, especially those involving timers, UI interactions, or system APIs, may produce inconsistent results (flaky tests), leading to unreliable CI/CD pipelines.

**Mitigation Strategies:**
1. Avoid timing-dependent assertions where possible
2. Use deterministic test data and mocks
3. Implement retry logic for known flaky tests (with limits)
4. Monitor test stability metrics
5. Quarantine consistently flaky tests for investigation

**Contingency Plan:**
If flakiness persists, mark affected tests as manual verification required and investigate root causes.

---

### R5: Scope Creep

| Attribute | Value |
|-----------|-------|
| **Category** | Management |
| **Probability** | Medium |
| **Impact** | Medium |
| **Risk Level** | Mitigate |

**Description:**
During development, additional features or improvements may be requested, potentially delaying the release schedule and diverting resources from planned tasks.

**Mitigation Strategies:**
1. Strict change control process
2. Defer non-essential features to future releases
3. Document all change requests with impact analysis
4. Maintain clear sprint goals and acceptance criteria
5. Regular communication with stakeholders

**Contingency Plan:**
If scope increases significantly, negotiate timeline extension or reduce scope of lower-priority items.

---

### R6: Test Coverage Gaps in UI Components

| Attribute | Value |
|-----------|-------|
| **Category** | Technical |
| **Probability** | Medium |
| **Impact** | Low |
| **Risk Level** | Monitor |

**Description:**
SwiftUI views (SettingsView, HistoryView) and AppDelegate may be difficult to unit test effectively, potentially leaving gaps in coverage for UI-related code.

**Mitigation Strategies:**
1. Focus unit tests on ViewModels (MVVM pattern)
2. Keep views as thin as possible (presentation only)
3. Use UI tests for critical user flows
4. Accept lower coverage targets for view layer (70%)
5. Document coverage exclusions with justification

**Contingency Plan:**
Rely on manual testing and UI tests for view layer verification.

---

### R7: Localization String Mismatches

| Attribute | Value |
|-----------|-------|
| **Category** | Quality |
| **Probability** | Low |
| **Impact** | Low |
| **Risk Level** | Accept |

**Description:**
With 8 supported languages, there's a risk of missing or mismatched localization keys, leading to untranslated strings appearing in the UI.

**Mitigation Strategies:**
1. Automated key validation in tests (Task #5)
2. Script to compare keys across all .strings files
3. Code review checklist for localization changes
4. User feedback mechanism for translation issues

**Contingency Plan:**
Fall back to English for missing keys and fix in subsequent releases.

---

### R8: Memory Leaks in Timer/Notification Handling

| Attribute | Value |
|-----------|-------|
| **Category** | Technical |
| **Probability** | Low |
| **Impact** | Medium |
| **Risk Level** | Monitor |

**Description:**
Timer callbacks and notification observers may cause retain cycles if not properly managed with weak references, leading to memory leaks over extended usage.

**Mitigation Strategies:**
1. Use `[weak self]` in all closures
2. Implement proper cleanup in deinit
3. Run memory leak detection in CI (leaks tool)
4. Monitor memory usage in long-running tests
5. Code review focus on memory management

**Contingency Plan:**
If leaks are detected, prioritize fixes before release.

---

### R9: Documentation Drift

| Attribute | Value |
|-----------|-------|
| **Category** | Process |
| **Probability** | Low |
| **Impact** | Low |
| **Risk Level** | Accept |

**Description:**
As code changes, documentation (CLAUDE.md, README.md, architecture docs) may become outdated, causing confusion for developers and AI assistants.

**Mitigation Strategies:**
1. Include documentation updates in Definition of Done
2. Review documentation in PR checklist
3. Assign documentation task (#11) to dedicated resource
4. Use automated doc generation where possible

**Contingency Plan:**
Schedule documentation review before each release.

---

## Risk Register Summary

| ID | Risk | Level | Owner | Status |
|----|------|-------|-------|--------|
| R1 | IOPMAssertion Mocking | Critical | Architect | Open |
| R2 | macOS Compatibility | Critical | QA | Open |
| R3 | Keyboard Shortcut Conflicts | Mitigate | Dev5 | Open |
| R4 | CI/CD Flakiness | Monitor | Dev9 | Open |
| R5 | Scope Creep | Mitigate | PM | Open |
| R6 | UI Test Coverage Gaps | Monitor | QA | Open |
| R7 | Localization Mismatches | Accept | Dev2 | Open |
| R8 | Memory Leaks | Monitor | Dev1 | Open |
| R9 | Documentation Drift | Accept | Dev8 | Open |

---

## Risk Review Schedule

| Review | Frequency | Participants |
|--------|-----------|--------------|
| Sprint Review | Bi-weekly | All team members |
| Risk Assessment Update | Monthly | PM, Architect, QA |
| Critical Risk Escalation | As needed | PM, Team Lead |

---

## Appendix: Risk Response Strategies

| Strategy | Description | When to Use |
|----------|-------------|-------------|
| **Avoid** | Eliminate the risk by changing approach | High impact, high probability |
| **Mitigate** | Reduce probability or impact | Medium to high risks |
| **Transfer** | Shift risk to third party | External dependencies |
| **Accept** | Acknowledge and monitor | Low impact or probability |

---

*Document Version: 1.0*
*Last Updated: 2026-02-22*
*Next Review: End of Sprint 1*
