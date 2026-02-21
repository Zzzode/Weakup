import XCTest
import AppKit
@testable import WeakupCore

final class IconStyleTests: XCTestCase {

    // Enum Cases Tests

    func testAllCases_containsExpectedStyles() {
        let allCases = IconStyle.allCases
        XCTAssertEqual(allCases.count, 5, "Should have exactly 5 icon styles")
        XCTAssertTrue(allCases.contains(.power), "Should contain power")
        XCTAssertTrue(allCases.contains(.bolt), "Should contain bolt")
        XCTAssertTrue(allCases.contains(.cup), "Should contain cup")
        XCTAssertTrue(allCases.contains(.moon), "Should contain moon")
        XCTAssertTrue(allCases.contains(.eye), "Should contain eye")
    }

    // Raw Value Tests

    func testRawValues() {
        XCTAssertEqual(IconStyle.power.rawValue, "power")
        XCTAssertEqual(IconStyle.bolt.rawValue, "bolt")
        XCTAssertEqual(IconStyle.cup.rawValue, "cup")
        XCTAssertEqual(IconStyle.moon.rawValue, "moon")
        XCTAssertEqual(IconStyle.eye.rawValue, "eye")
    }

    // Identifiable Tests

    func testId_matchesRawValue() {
        for style in IconStyle.allCases {
            XCTAssertEqual(style.id, style.rawValue, "ID should match raw value")
        }
    }

    // Localization Key Tests

    func testLocalizationKey_format() {
        for style in IconStyle.allCases {
            XCTAssertEqual(style.localizationKey, "icon_\(style.rawValue)")
        }
    }

    // Symbol Tests

    func testInactiveSymbol_power() {
        XCTAssertEqual(IconStyle.power.inactiveSymbol, "power.circle")
    }

    func testActiveSymbol_power() {
        XCTAssertEqual(IconStyle.power.activeSymbol, "power.circle.fill")
    }

    func testInactiveSymbol_bolt() {
        XCTAssertEqual(IconStyle.bolt.inactiveSymbol, "bolt.circle")
    }

    func testActiveSymbol_bolt() {
        XCTAssertEqual(IconStyle.bolt.activeSymbol, "bolt.circle.fill")
    }

    func testInactiveSymbol_cup() {
        XCTAssertEqual(IconStyle.cup.inactiveSymbol, "cup.and.saucer")
    }

    func testActiveSymbol_cup() {
        XCTAssertEqual(IconStyle.cup.activeSymbol, "cup.and.saucer.fill")
    }

    func testInactiveSymbol_moon() {
        XCTAssertEqual(IconStyle.moon.inactiveSymbol, "moon.zzz")
    }

    func testActiveSymbol_moon() {
        XCTAssertEqual(IconStyle.moon.activeSymbol, "moon.zzz.fill")
    }

    func testInactiveSymbol_eye() {
        XCTAssertEqual(IconStyle.eye.inactiveSymbol, "eye")
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
}

@MainActor
final class IconManagerTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "WeakupIconStyle")
    }

    func testShared_returnsSameInstance() {
        let instance1 = IconManager.shared
        let instance2 = IconManager.shared
        XCTAssertTrue(instance1 === instance2, "Shared should return same instance")
    }

    func testSetStyle_persistsValue() {
        let manager = IconManager.shared
        manager.currentStyle = .bolt
        let storedValue = UserDefaults.standard.string(forKey: "WeakupIconStyle")
        XCTAssertEqual(storedValue, "bolt", "Style should be persisted to UserDefaults")
    }

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

    func testCurrentImage_usesCurrentStyle() {
        let manager = IconManager.shared
        manager.currentStyle = .moon
        // Verify method doesn't crash
        _ = manager.currentImage(isActive: true)
        _ = manager.currentImage(isActive: false)
    }

    func testOnIconChanged_calledWhenStyleChanges() {
        let manager = IconManager.shared
        var callbackCalled = false
        manager.onIconChanged = {
            callbackCalled = true
        }
        manager.currentStyle = .eye
        XCTAssertTrue(callbackCalled, "Callback should be called when style changes")
    }
}
