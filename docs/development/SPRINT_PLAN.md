# Weakup Sprint Plan

*Created: 2026-02-22*
*Project Manager: PM Agent*

## Overview

This document outlines the sprint plan for completing the Weakup project improvements, including test coverage, new features, and documentation updates.

---

## Sprint 1: Foundation (Week 1-2)

**Goal:** Establish test infrastructure and architecture foundation

### Tasks

| Task ID | Description | Owner | Priority | Story Points |
|---------|-------------|-------|----------|--------------|
| #1 | Design test infrastructure and architecture improvements | Architect | P0 | 8 |
| #3 | Design comprehensive test suite based on QA_PLAN.md | QA | P0 | 5 |

### Acceptance Criteria

**Task #1 - Test Infrastructure:**
- [ ] Test directory structure defined following QA_PLAN.md recommendations
- [ ] Mock/stub patterns documented for IOPMAssertion, UserDefaults
- [ ] Dependency injection patterns identified for testability
- [ ] CI/CD test integration plan documented
- [ ] Architecture improvements documented with diagrams

**Task #3 - Test Suite Design:**
- [ ] Test cases mapped to QA_PLAN.md specifications
- [ ] Test data requirements documented
- [ ] Test execution order and dependencies defined
- [ ] Coverage targets aligned with QA_PLAN.md (80% overall)

### Sprint 1 Deliverables
- Architecture decision document
- Test infrastructure setup guide
- Comprehensive test case specifications

---

## Sprint 2: Core Testing (Week 3-4)

**Goal:** Implement unit tests for core business logic

### Tasks

| Task ID | Description | Owner | Priority | Story Points | Dependencies |
|---------|-------------|-------|----------|--------------|--------------|
| #4 | Implement CaffeineViewModel unit tests (90% coverage) | Dev1 | P0 | 8 | #1, #3 |
| #5 | Implement L10n and localization tests (85% coverage) | Dev2 | P0 | 5 | #1, #3 |
| #6 | Implement ActivityHistoryManager and HotkeyManager tests | Dev3 | P1 | 5 | #1, #3 |
| #7 | Implement IconManager and ThemeManager tests | Dev4 | P1 | 5 | #1, #3 |

### Acceptance Criteria

**Task #4 - CaffeineViewModel Tests:**
- [ ] All P0 test cases from QA_PLAN.md Section 3.1 implemented
- [ ] test_initialState, test_toggle_*, test_start_*, test_stop_* passing
- [ ] test_timerMode_* tests implemented and passing
- [ ] Code coverage >= 90% for CaffeineViewModel.swift
- [ ] Tests run in < 30 seconds

**Task #5 - L10n Tests:**
- [ ] All test cases from QA_PLAN.md Section 3.2 implemented
- [ ] test_defaultLanguage_detectsSystem passing
- [ ] test_setLanguage_persists passing
- [ ] All 8 languages validated for key completeness
- [ ] Code coverage >= 85% for L10n.swift

**Task #6 - ActivityHistoryManager & HotkeyManager Tests:**
- [ ] ActivitySession CRUD operations tested
- [ ] History persistence verified
- [ ] Hotkey registration/unregistration tested
- [ ] Edge cases covered (empty history, duplicate hotkeys)

**Task #7 - IconManager & ThemeManager Tests:**
- [ ] All icon styles tested (Power, Bolt, Coffee, Moon, Eye)
- [ ] Theme switching tested (System, Light, Dark)
- [ ] Icon state changes verified (active/inactive)
- [ ] Theme persistence verified

### Sprint 2 Deliverables
- Unit test suite for core ViewModels
- Unit test suite for utility managers
- Coverage report showing >= 80% overall

---

## Sprint 3: Features & Enhancements (Week 5-6)

**Goal:** Implement new features and code improvements

### Tasks

| Task ID | Description | Owner | Priority | Story Points | Dependencies |
|---------|-------------|-------|----------|--------------|--------------|
| #8 | Implement keyboard shortcut conflict detection | Dev5 | P1 | 5 | #1 |
| #9 | Test and enhance Launch at Login functionality | Dev6 | P1 | 3 | #1 |
| #10 | Refactor code to reduce duplication and improve maintainability | Dev7 | P2 | 5 | #1 |
| #11 | Enhance documentation and create architecture diagrams | Dev8 | P2 | 3 | #1 |

### Acceptance Criteria

**Task #8 - Keyboard Shortcut Conflict Detection:**
- [ ] Detect conflicts with system shortcuts
- [ ] Detect conflicts with other app shortcuts
- [ ] User notification when conflict detected
- [ ] Graceful fallback behavior
- [ ] Unit tests for conflict detection logic

**Task #9 - Launch at Login:**
- [ ] LaunchAtLoginManager fully tested
- [ ] Enable/disable functionality verified
- [ ] State persistence across app restarts
- [ ] macOS 13+ compatibility verified
- [ ] UI toggle in settings working

**Task #10 - Code Refactoring:**
- [ ] Duplicate code identified and consolidated
- [ ] Common patterns extracted to utilities
- [ ] No regression in existing functionality
- [ ] All existing tests still pass
- [ ] Code review approved

**Task #11 - Documentation:**
- [ ] Architecture diagrams created (component, sequence)
- [ ] API documentation updated
- [ ] README.md updated with new features
- [ ] CLAUDE.md updated for AI assistants

### Sprint 3 Deliverables
- Keyboard shortcut conflict detection feature
- Launch at Login feature fully tested
- Refactored codebase
- Updated documentation with diagrams

---

## Sprint 4: Integration & Polish (Week 7-8)

**Goal:** Integration testing, CI/CD improvements, and UX enhancements

### Tasks

| Task ID | Description | Owner | Priority | Story Points | Dependencies |
|---------|-------------|-------|----------|--------------|--------------|
| #12 | Implement integration tests and CI/CD improvements | Dev9 | P1 | 8 | #1, #3 |
| #13 | Add activity history export and UX enhancements | Dev10 | P2 | 5 | #1 |

### Acceptance Criteria

**Task #12 - Integration Tests & CI/CD:**
- [ ] Sleep prevention integration tests (QA_PLAN.md Section 4.1)
- [ ] Timer integration tests (QA_PLAN.md Section 4.2)
- [ ] Persistence integration tests (QA_PLAN.md Section 4.3)
- [ ] CI pipeline runs tests on every commit
- [ ] Coverage reports generated automatically
- [ ] Test results visible in PR checks

**Task #13 - Activity History Export & UX:**
- [ ] Export history to CSV/JSON
- [ ] History view UI improvements
- [ ] Statistics display (total time, session count)
- [ ] Clear history functionality
- [ ] User-friendly date/time formatting

### Sprint 4 Deliverables
- Integration test suite
- Enhanced CI/CD pipeline
- Activity history export feature
- UX improvements

---

## Sprint 5: QA & Release (Week 9-10)

**Goal:** Comprehensive testing and release preparation

### Tasks

| Task ID | Description | Owner | Priority | Story Points | Dependencies |
|---------|-------------|-------|----------|--------------|--------------|
| #14 | Execute comprehensive testing and create test report | QA | P0 | 8 | #4-#13 |
| #15 | Final review and release preparation | PM | P0 | 5 | #14 |

### Acceptance Criteria

**Task #14 - Comprehensive Testing:**
- [ ] All P0 test cases pass
- [ ] All P1 test cases pass (95%+)
- [ ] No S1 or S2 bugs open
- [ ] Code coverage >= 80% overall
- [ ] All critical user flows verified (QA_PLAN.md Section 7)
- [ ] Edge cases tested (QA_PLAN.md Section 6)
- [ ] Performance verified (< 1% CPU idle)
- [ ] Memory leak check passed
- [ ] Test report generated

**Task #15 - Release Preparation:**
- [ ] CHANGELOG.md updated with all changes
- [ ] Version number bumped appropriately
- [ ] Release notes drafted
- [ ] Build artifacts verified
- [ ] Code signing verified (if applicable)
- [ ] Homebrew formula updated
- [ ] GitHub release created

### Sprint 5 Deliverables
- Comprehensive test report
- Release candidate build
- Updated CHANGELOG.md
- Release notes

---

## Milestone Roadmap

```
Week 1-2   Week 3-4   Week 5-6   Week 7-8   Week 9-10
   |          |          |          |          |
   v          v          v          v          v
[Sprint 1] [Sprint 2] [Sprint 3] [Sprint 4] [Sprint 5]
Foundation  Core       Features   Integration Release
            Testing    & Enhance  & Polish    & QA
   |          |          |          |          |
   v          v          v          v          v
Milestone 1 Milestone 2 Milestone 3 Milestone 4 Milestone 5
Arch Ready  80% Tests   Features   CI/CD      v1.1.0
            Complete    Complete   Complete   Release
```

### Milestone Definitions

| Milestone | Target Date | Criteria |
|-----------|-------------|----------|
| M1: Architecture Ready | End of Week 2 | Test infrastructure designed, QA plan finalized |
| M2: Core Tests Complete | End of Week 4 | 80% test coverage, all P0 unit tests passing |
| M3: Features Complete | End of Week 6 | All new features implemented and tested |
| M4: CI/CD Complete | End of Week 8 | Integration tests in CI, coverage reports automated |
| M5: Release v1.1.0 | End of Week 10 | All acceptance criteria met, release published |

---

## Risk Assessment

### High Risk

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| IOPMAssertion mocking complexity | Test coverage gaps | Medium | Research existing solutions, create abstraction layer |
| macOS version compatibility | Feature failures on older versions | Medium | Test on multiple macOS versions, use availability checks |

### Medium Risk

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Keyboard shortcut conflicts | User experience degradation | Medium | Implement robust conflict detection, provide fallback |
| CI/CD test flakiness | Unreliable builds | Low | Use deterministic tests, avoid timing-dependent assertions |
| Scope creep | Schedule delays | Medium | Strict change control, defer non-essential features |

### Low Risk

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Localization string mismatches | Minor UI issues | Low | Automated key validation in tests |
| Documentation drift | Developer confusion | Low | Keep docs in sync with code changes |

---

## Resource Allocation

### Team Structure

| Role | Responsibilities | Sprints Active |
|------|------------------|----------------|
| Architect | Test infrastructure, architecture decisions | Sprint 1 |
| QA | Test design, comprehensive testing | Sprint 1, 5 |
| Dev1 | CaffeineViewModel tests | Sprint 2 |
| Dev2 | L10n tests | Sprint 2 |
| Dev3 | ActivityHistoryManager, HotkeyManager tests | Sprint 2 |
| Dev4 | IconManager, ThemeManager tests | Sprint 2 |
| Dev5 | Keyboard shortcut conflict detection | Sprint 3 |
| Dev6 | Launch at Login | Sprint 3 |
| Dev7 | Code refactoring | Sprint 3 |
| Dev8 | Documentation | Sprint 3 |
| Dev9 | Integration tests, CI/CD | Sprint 4 |
| Dev10 | Activity history export, UX | Sprint 4 |
| PM | Planning, coordination, release | All Sprints |

---

## Progress Tracking

### Sprint Velocity Targets

| Sprint | Planned Points | Capacity |
|--------|---------------|----------|
| Sprint 1 | 13 | 15 |
| Sprint 2 | 23 | 25 |
| Sprint 3 | 16 | 20 |
| Sprint 4 | 13 | 15 |
| Sprint 5 | 13 | 15 |
| **Total** | **78** | **90** |

### Definition of Done

A task is considered "Done" when:
1. All acceptance criteria are met
2. Code is reviewed and approved
3. Tests pass in CI
4. Documentation is updated
5. No blocking bugs remain

---

## Communication Plan

- **Daily:** Task updates via task system
- **Sprint Start:** Sprint planning and task assignment
- **Sprint End:** Sprint review and retrospective
- **Blockers:** Immediate notification to team lead

---

*Document Version: 1.0*
*Last Updated: 2026-02-22*
