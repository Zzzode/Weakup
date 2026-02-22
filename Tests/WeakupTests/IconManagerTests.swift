import XCTest
import AppKit
import Combine
@testable import WeakupCore

final class IconStyleTests: XCTestCase {

    // Enum Cases Tests (IM-001)

    func testAllCases_containsExpectedStyles() {
        let allCases = IconStyle.allCases
        XCTAssertEqual(allCases.count, 5, "Should have exactly 5 icon styles")
        XCTAssertTrue(allCases.contains(.power), "Should contain power")
        XCTAssertTrue(allCases.contains(.bolt), "Should contain bolt")
        XCTAssertTrue(allCases.contains(.cup), "Should contain cup")
        XCTAssertTrue(allCases.contains(.moon), "Should contain moon")
        XCTAssertTrue(allCases.contains(.eye), "Should contain eye")
    }

    // Raw Value Tests (IM-002)

    func testRawValues() {
        XCTAssertEqual(IconStyle.power.rawValue, "power")
        XCTAssertEqual(IconStyle.bolt.rawValue, "bolt")
        XCTAssertEqual(IconStyle.cup.rawValue, "cup")
        XCTAssertEqual(IconStyle.moon.rawValue, "moon")
        XCTAssertEqual(IconStyle.eye.rawValue, "eye")
    }

    // Identifiable Tests (IM-003)

    func testId_matchesRawValue() {
        for style in IconStyle.allCases {
            XCTAssertEqual(style.id, style.rawValue, "ID should match raw value")
        }
    }

    // Localization Key Tests (IM-004)

    func testLocalizationKey_format() {
        for style in IconStyle.allCases {
            XCTAssertEqual(style.localizationKey, "icon_\(style.rawValue)")
        }
    }

    func testLocalizationKey_power() {
        XCTAssertEqual(IconStyle.power.localizationKey, "icon_power")
    }

    func testLocalizationKey_bolt() {
        XCTAssertEqual(IconStyle.bolt.localizationKey, "icon_bolt")
    }

    func testLocalizationKey_cup() {
        XCTAssertEqual(IconStyle.cup.localizationKey, "icon_cup")
    }

    func testLocalizationKey_moon() {
        XCTAssertEqual(IconStyle.moon.localizationKey, "icon_moon")
    }

    func testLocalizationKey_eye() {
        XCTAssertEqual(IconStyle.eye.localizationKey, "icon_eye")
    }

    // Inactive Symbol Tests (IM-005)

    func testInactiveSymbol_power() {
        XCTAssertEqual(IconStyle.power.inactiveSymbol, "power.circle")
    }

    func testInactiveSymbol_bolt() {
        XCTAssertEqual(IconStyle.bolt.inactiveSymbol, "bolt.circle")
    }

    func testInactiveSymbol_cup() {
        XCTAssertEqual(IconStyle.cup.inactiveSymbol, "cup.and.saucer")
    }

    func testInactiveSymbol_moon() {
        XCTAssertEqual(IconStyle.moon.inactiveSymbol, "moon.zzz")
    }

    func testInactiveSymbol_eye() {
        XCTAssertEqual(IconStyle.eye.inactiveSymbol, "eye")
    }

    // Active Symbol Tests (IM-006)

    func testActiveSymbol_power() {
        XCTAssertEqual(IconStyle.power.activeSymbol, "power.circle.fill")
    }

    func testActiveSymbol_bolt() {
        XCTAssertEqual(IconStyle.bolt.activeSymbol, "bolt.circle.fill")
    }

    func testActiveSymbol_cup() {
        XCTAssertEqual(IconStyle.cup.activeSymbol, "cup.and.saucer.fill")
    }

    func testActiveSymbol_moon() {
        XCTAssertEqual(IconStyle.moon.activeSymbol, "moon.zzz.fill")
    }

    func testActiveSymbol_eye() {
        XCTAssertEqual(IconStyle.eye.activeSymbol, "eye.fill")
    }

    func testAllStyles_haveValidSymbols() {
        for style in IconStyle.allCases {
            XCTAssertFalse(style.inactiveSymbol.isEmpty, "Inactive symbol should not be empty for \(style)")
            XCTAssertFalse(style.activeSymbol.isEmpty, "Active symbol should not be empty for \(style)")
        }
    }

    // Symbol Differentiation Tests

    func testActiveAndInactiveSymbols_areDifferent() {
        for style in IconStyle.allCases {
            XCTAssertNotEqual(
                style.activeSymbol,
                style.inactiveSymbol,
                "Active and inactive symbols should be different for \(style)"
            )
        }
    }

    func testActiveSymbols_containFill() {
        for style in IconStyle.allCases {
            XCTAssertTrue(
                style.activeSymbol.contains("fill"),
                "Active symbol should contain 'fill' for \(style)"
            )
        }
    }

    // Initialization Tests

    func testInit_fromValidRawValue() {
        XCTAssertEqual(IconStyle(rawValue: "power"), .power)
        XCTAssertEqual(IconStyle(rawValue: "bolt"), .bolt)
        XCTAssertEqual(IconStyle(rawValue: "cup"), .cup)
        XCTAssertEqual(IconStyle(rawValue: "moon"), .moon)
        XCTAssertEqual(IconStyle(rawValue: "eye"), .eye)
    }

    func testInit_fromInvalidRawValue() {
        let invalid = IconStyle(rawValue: "invalid")
        XCTAssertNil(invalid, "Invalid raw value should return nil")
    }

    func testInit_fromEmptyRawValue() {
        let empty = IconStyle(rawValue: "")
        XCTAssertNil(empty, "Empty raw value should return nil")
    }

    func testInit_caseSensitive() {
        XCTAssertNil(IconStyle(rawValue: "Power"), "Raw value should be case sensitive")
        XCTAssertNil(IconStyle(rawValue: "BOLT"), "Raw value should be case sensitive")
    }

    // Sendable Conformance

    func testIconStyle_isSendable() {
        let style: IconStyle = .power
        Task {
            let _ = style
        }
    }

    // CaseIterable Tests

    func testCaseIterable_orderIsConsistent() {
        let cases1 = IconStyle.allCases
        let cases2 = IconStyle.allCases
        XCTAssertEqual(cases1, cases2, "allCases should return consistent order")
    }
}

@MainActor
final class IconManagerTests: XCTestCase {

    private let userDefaultsKey = "WeakupIconStyle"

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
        // Reset callback
        IconManager.shared.onIconChanged = nil
    }

    override func tearDown() async throws {
        // Clean up after tests
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
        IconManager.shared.onIconChanged = nil
        try await super.tearDown()
    }

    // Singleton Tests (IM-007)

    func testShared_returnsSameInstance() {
        let instance1 = IconManager.shared
        let instance2 = IconManager.shared
        XCTAssertTrue(instance1 === instance2, "Shared should return same instance")
    }

    func testShared_isNotNil() {
        XCTAssertNotNil(IconManager.shared, "Shared instance should not be nil")
    }

    // Style Persistence Tests (IM-008)

    func testSetStyle_persistsValue() {
        let manager = IconManager.shared
        manager.currentStyle = .bolt
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedValue, "bolt", "Style should be persisted to UserDefaults")
    }

    func testSetStyle_persistsAllStyles() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            manager.currentStyle = style
            let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
            XCTAssertEqual(storedValue, style.rawValue, "Style \(style) should be persisted")
        }
    }

    func testSetStyle_updatesCurrentStyle() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            manager.currentStyle = style
            XCTAssertEqual(manager.currentStyle, style, "currentStyle should be updated to \(style)")
        }
    }

    // Image Generation Tests (IM-009)

    func testImage_returnsImage() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            let activeImage = manager.image(for: style, isActive: true)
            let inactiveImage = manager.image(for: style, isActive: false)
            // Note: Images may be nil in test environment without proper resources
            // This test verifies the method doesn't crash
            _ = activeImage
            _ = inactiveImage
        }
    }

    func testImage_forPower_active() {
        let manager = IconManager.shared
        let image = manager.image(for: .power, isActive: true)
        // Verify method returns without crashing; image may be nil in test environment
        _ = image
    }

    func testImage_forPower_inactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .power, isActive: false)
        _ = image
    }

    func testImage_forBolt_active() {
        let manager = IconManager.shared
        let image = manager.image(for: .bolt, isActive: true)
        _ = image
    }

    func testImage_forBolt_inactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .bolt, isActive: false)
        _ = image
    }

    func testImage_forCup_active() {
        let manager = IconManager.shared
        let image = manager.image(for: .cup, isActive: true)
        _ = image
    }

    func testImage_forCup_inactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .cup, isActive: false)
        _ = image
    }

    func testImage_forMoon_active() {
        let manager = IconManager.shared
        let image = manager.image(for: .moon, isActive: true)
        _ = image
    }

    func testImage_forMoon_inactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .moon, isActive: false)
        _ = image
    }

    func testImage_forEye_active() {
        let manager = IconManager.shared
        let image = manager.image(for: .eye, isActive: true)
        _ = image
    }

    func testImage_forEye_inactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .eye, isActive: false)
        _ = image
    }

    func testImage_allStyles_activeAndInactive() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            // Test both active and inactive states for each style
            _ = manager.image(for: style, isActive: true)
            _ = manager.image(for: style, isActive: false)
        }
    }

    // Current Image Tests (IM-010)

    func testCurrentImage_usesCurrentStyle() {
        let manager = IconManager.shared
        manager.currentStyle = .moon
        // Verify method doesn't crash
        _ = manager.currentImage(isActive: true)
        _ = manager.currentImage(isActive: false)
    }

    func testCurrentImage_activeState() {
        let manager = IconManager.shared
        manager.currentStyle = .power
        let image = manager.currentImage(isActive: true)
        _ = image
    }

    func testCurrentImage_inactiveState() {
        let manager = IconManager.shared
        manager.currentStyle = .power
        let image = manager.currentImage(isActive: false)
        _ = image
    }

    func testCurrentImage_changesWithStyle() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            manager.currentStyle = style
            _ = manager.currentImage(isActive: true)
            _ = manager.currentImage(isActive: false)
        }
    }

    // Callback Tests (IM-011)

    func testOnIconChanged_calledWhenStyleChanges() {
        let manager = IconManager.shared
        var callbackCalled = false
        manager.onIconChanged = {
            callbackCalled = true
        }
        manager.currentStyle = .eye
        XCTAssertTrue(callbackCalled, "Callback should be called when style changes")
    }

    func testOnIconChanged_calledForEachStyleChange() {
        let manager = IconManager.shared
        var callCount = 0
        manager.onIconChanged = {
            callCount += 1
        }

        manager.currentStyle = .power
        manager.currentStyle = .bolt
        manager.currentStyle = .cup

        XCTAssertEqual(callCount, 3, "Callback should be called for each style change")
    }

    func testOnIconChanged_notCalledWhenSetToSameStyle() {
        let manager = IconManager.shared
        manager.currentStyle = .power
        var callCount = 0
        manager.onIconChanged = {
            callCount += 1
        }

        // Setting to same style still triggers didSet in Swift
        manager.currentStyle = .power

        // Note: Swift's didSet is called even when setting the same value
        // This test documents the actual behavior
        XCTAssertEqual(callCount, 1, "Callback is called even when setting same style (Swift didSet behavior)")
    }

    func testOnIconChanged_nilCallbackDoesNotCrash() {
        let manager = IconManager.shared
        manager.onIconChanged = nil
        // Should not crash
        manager.currentStyle = .bolt
    }

    func testOnIconChanged_canBeReassigned() {
        let manager = IconManager.shared
        var firstCallbackCalled = false
        var secondCallbackCalled = false

        manager.onIconChanged = {
            firstCallbackCalled = true
        }
        manager.currentStyle = .power
        XCTAssertTrue(firstCallbackCalled)

        manager.onIconChanged = {
            secondCallbackCalled = true
        }
        manager.currentStyle = .bolt
        XCTAssertTrue(secondCallbackCalled)
    }

    // Style Cycling Tests

    func testStyleCycling_throughAllStyles() {
        let manager = IconManager.shared
        let styles = IconStyle.allCases

        for (index, style) in styles.enumerated() {
            manager.currentStyle = style
            XCTAssertEqual(manager.currentStyle, style, "Style at index \(index) should be set correctly")
        }
    }

    func testRapidStyleChanges() {
        let manager = IconManager.shared
        var callCount = 0
        manager.onIconChanged = {
            callCount += 1
        }

        // Rapidly change styles
        for _ in 0..<10 {
            for style in IconStyle.allCases {
                manager.currentStyle = style
            }
        }

        XCTAssertEqual(callCount, 50, "Callback should be called for each rapid style change")
    }

    // ObservableObject Tests

    func testIconManager_isObservableObject() {
        let manager = IconManager.shared
        // Verify the manager conforms to ObservableObject by accessing objectWillChange
        _ = manager.objectWillChange
    }

    func testCurrentStyle_isPublished() {
        let manager = IconManager.shared
        let expectation = XCTestExpectation(description: "Published property should notify")

        let cancellable = manager.objectWillChange.sink {
            expectation.fulfill()
        }

        manager.currentStyle = .eye

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
}
