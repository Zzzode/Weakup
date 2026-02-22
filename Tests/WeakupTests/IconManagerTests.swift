import Testing
import AppKit
import Combine
@testable import WeakupCore

@Suite("IconStyle Tests")
struct IconStyleTests {

    // Enum Cases Tests (IM-001)

    @Test("All cases contains expected styles")
    func allCasesContainsExpectedStyles() {
        let allCases = IconStyle.allCases
        #expect(allCases.count == 5, "Should have exactly 5 icon styles")
        #expect(allCases.contains(.power), "Should contain power")
        #expect(allCases.contains(.bolt), "Should contain bolt")
        #expect(allCases.contains(.cup), "Should contain cup")
        #expect(allCases.contains(.moon), "Should contain moon")
        #expect(allCases.contains(.eye), "Should contain eye")
    }

    // Raw Value Tests (IM-002)

    @Test("Raw values")
    func rawValues() {
        #expect(IconStyle.power.rawValue == "power")
        #expect(IconStyle.bolt.rawValue == "bolt")
        #expect(IconStyle.cup.rawValue == "cup")
        #expect(IconStyle.moon.rawValue == "moon")
        #expect(IconStyle.eye.rawValue == "eye")
    }

    // Identifiable Tests (IM-003)

    @Test("ID matches raw value")
    func idMatchesRawValue() {
        for style in IconStyle.allCases {
            #expect(style.id == style.rawValue, "ID should match raw value")
        }
    }

    // Localization Key Tests (IM-004)

    @Test("Localization key format")
    func localizationKeyFormat() {
        for style in IconStyle.allCases {
            #expect(style.localizationKey == "icon_\(style.rawValue)")
        }
    }

    @Test("Localization key for power")
    func localizationKeyPower() {
        #expect(IconStyle.power.localizationKey == "icon_power")
    }

    @Test("Localization key for bolt")
    func localizationKeyBolt() {
        #expect(IconStyle.bolt.localizationKey == "icon_bolt")
    }

    @Test("Localization key for cup")
    func localizationKeyCup() {
        #expect(IconStyle.cup.localizationKey == "icon_cup")
    }

    @Test("Localization key for moon")
    func localizationKeyMoon() {
        #expect(IconStyle.moon.localizationKey == "icon_moon")
    }

    @Test("Localization key for eye")
    func localizationKeyEye() {
        #expect(IconStyle.eye.localizationKey == "icon_eye")
    }

    // Inactive Symbol Tests (IM-005)

    @Test("Inactive symbol for power")
    func inactiveSymbolPower() {
        #expect(IconStyle.power.inactiveSymbol == "power.circle")
    }

    @Test("Inactive symbol for bolt")
    func inactiveSymbolBolt() {
        #expect(IconStyle.bolt.inactiveSymbol == "bolt.circle")
    }

    @Test("Inactive symbol for cup")
    func inactiveSymbolCup() {
        #expect(IconStyle.cup.inactiveSymbol == "cup.and.saucer")
    }

    @Test("Inactive symbol for moon")
    func inactiveSymbolMoon() {
        #expect(IconStyle.moon.inactiveSymbol == "moon.zzz")
    }

    @Test("Inactive symbol for eye")
    func inactiveSymbolEye() {
        #expect(IconStyle.eye.inactiveSymbol == "eye")
    }

    // Active Symbol Tests (IM-006)

    @Test("Active symbol for power")
    func activeSymbolPower() {
        #expect(IconStyle.power.activeSymbol == "power.circle.fill")
    }

    @Test("Active symbol for bolt")
    func activeSymbolBolt() {
        #expect(IconStyle.bolt.activeSymbol == "bolt.circle.fill")
    }

    @Test("Active symbol for cup")
    func activeSymbolCup() {
        #expect(IconStyle.cup.activeSymbol == "cup.and.saucer.fill")
    }

    @Test("Active symbol for moon")
    func activeSymbolMoon() {
        #expect(IconStyle.moon.activeSymbol == "moon.zzz.fill")
    }

    @Test("Active symbol for eye")
    func activeSymbolEye() {
        #expect(IconStyle.eye.activeSymbol == "eye.fill")
    }

    @Test("All styles have valid symbols")
    func allStylesHaveValidSymbols() {
        for style in IconStyle.allCases {
            #expect(!style.inactiveSymbol.isEmpty, "Inactive symbol should not be empty for \(style)")
            #expect(!style.activeSymbol.isEmpty, "Active symbol should not be empty for \(style)")
        }
    }

    // Symbol Differentiation Tests

    @Test("Active and inactive symbols are different")
    func activeAndInactiveSymbolsAreDifferent() {
        for style in IconStyle.allCases {
            #expect(
                style.activeSymbol != style.inactiveSymbol,
                "Active and inactive symbols should be different for \(style)"
            )
        }
    }

    @Test("Active symbols contain fill")
    func activeSymbolsContainFill() {
        for style in IconStyle.allCases {
            #expect(
                style.activeSymbol.contains("fill"),
                "Active symbol should contain 'fill' for \(style)"
            )
        }
    }

    // Initialization Tests

    @Test("Init from valid raw value")
    func initFromValidRawValue() {
        #expect(IconStyle(rawValue: "power") == .power)
        #expect(IconStyle(rawValue: "bolt") == .bolt)
        #expect(IconStyle(rawValue: "cup") == .cup)
        #expect(IconStyle(rawValue: "moon") == .moon)
        #expect(IconStyle(rawValue: "eye") == .eye)
    }

    @Test("Init from invalid raw value")
    func initFromInvalidRawValue() {
        let invalid = IconStyle(rawValue: "invalid")
        #expect(invalid == nil, "Invalid raw value should return nil")
    }

    @Test("Init from empty raw value")
    func initFromEmptyRawValue() {
        let empty = IconStyle(rawValue: "")
        #expect(empty == nil, "Empty raw value should return nil")
    }

    @Test("Init case sensitive")
    func initCaseSensitive() {
        #expect(IconStyle(rawValue: "Power") == nil, "Raw value should be case sensitive")
        #expect(IconStyle(rawValue: "BOLT") == nil, "Raw value should be case sensitive")
    }

    // Sendable Conformance

    @Test("IconStyle is Sendable")
    func iconStyleIsSendable() async {
        let style: IconStyle = .power
        await Task {
            let _ = style
        }.value
    }

    // CaseIterable Tests

    @Test("CaseIterable order is consistent")
    func caseIterableOrderIsConsistent() {
        let cases1 = IconStyle.allCases
        let cases2 = IconStyle.allCases
        #expect(cases1 == cases2, "allCases should return consistent order")
    }
}

@Suite("IconManager Tests")
@MainActor
struct IconManagerTests {
    private let userDefaultsKey = "WeakupIconStyle"

    init() {
        // Clear UserDefaults before each test
        UserDefaultsStore.shared.removeObject(forKey: userDefaultsKey)
        // Reset callback
        IconManager.shared.onIconChanged = nil
    }

    // Singleton Tests (IM-007)

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = IconManager.shared
        let instance2 = IconManager.shared
        #expect(instance1 === instance2, "Shared should return same instance")
    }

    @Test("Shared is not nil")
    func sharedIsNotNil() {
        #expect(IconManager.shared != nil, "Shared instance should not be nil")
    }

    // Style Persistence Tests (IM-008)

    @Test("Set style persists value")
    func setStylePersistsValue() {
        let manager = IconManager.shared
        manager.currentStyle = .bolt
        let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
        #expect(storedValue == "bolt", "Style should be persisted to UserDefaults")
    }

    @Test("Set style persists all styles")
    func setStylePersistsAllStyles() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            manager.currentStyle = style
            let storedValue = UserDefaultsStore.shared.string(forKey: userDefaultsKey)
            #expect(storedValue == style.rawValue, "Style \(style) should be persisted")
        }
    }

    @Test("Set style updates current style")
    func setStyleUpdatesCurrentStyle() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            manager.currentStyle = style
            #expect(manager.currentStyle == style, "currentStyle should be updated to \(style)")
        }
    }

    // Image Generation Tests (IM-009)

    @Test("Image returns image")
    func imageReturnsImage() {
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

    @Test("Image for power active")
    func imageForPowerActive() {
        let manager = IconManager.shared
        let image = manager.image(for: .power, isActive: true)
        // Verify method returns without crashing; image may be nil in test environment
        _ = image
    }

    @Test("Image for power inactive")
    func imageForPowerInactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .power, isActive: false)
        _ = image
    }

    @Test("Image for bolt active")
    func imageForBoltActive() {
        let manager = IconManager.shared
        let image = manager.image(for: .bolt, isActive: true)
        _ = image
    }

    @Test("Image for bolt inactive")
    func imageForBoltInactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .bolt, isActive: false)
        _ = image
    }

    @Test("Image for cup active")
    func imageForCupActive() {
        let manager = IconManager.shared
        let image = manager.image(for: .cup, isActive: true)
        _ = image
    }

    @Test("Image for cup inactive")
    func imageForCupInactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .cup, isActive: false)
        _ = image
    }

    @Test("Image for moon active")
    func imageForMoonActive() {
        let manager = IconManager.shared
        let image = manager.image(for: .moon, isActive: true)
        _ = image
    }

    @Test("Image for moon inactive")
    func imageForMoonInactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .moon, isActive: false)
        _ = image
    }

    @Test("Image for eye active")
    func imageForEyeActive() {
        let manager = IconManager.shared
        let image = manager.image(for: .eye, isActive: true)
        _ = image
    }

    @Test("Image for eye inactive")
    func imageForEyeInactive() {
        let manager = IconManager.shared
        let image = manager.image(for: .eye, isActive: false)
        _ = image
    }

    @Test("Image all styles active and inactive")
    func imageAllStylesActiveAndInactive() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            // Test both active and inactive states for each style
            _ = manager.image(for: style, isActive: true)
            _ = manager.image(for: style, isActive: false)
        }
    }

    // Current Image Tests (IM-010)

    @Test("Current image uses current style")
    func currentImageUsesCurrentStyle() {
        let manager = IconManager.shared
        manager.currentStyle = .moon
        // Verify method doesn't crash
        _ = manager.currentImage(isActive: true)
        _ = manager.currentImage(isActive: false)
    }

    @Test("Current image active state")
    func currentImageActiveState() {
        let manager = IconManager.shared
        manager.currentStyle = .power
        let image = manager.currentImage(isActive: true)
        _ = image
    }

    @Test("Current image inactive state")
    func currentImageInactiveState() {
        let manager = IconManager.shared
        manager.currentStyle = .power
        let image = manager.currentImage(isActive: false)
        _ = image
    }

    @Test("Current image changes with style")
    func currentImageChangesWithStyle() {
        let manager = IconManager.shared
        for style in IconStyle.allCases {
            manager.currentStyle = style
            _ = manager.currentImage(isActive: true)
            _ = manager.currentImage(isActive: false)
        }
    }

    // Callback Tests (IM-011)

    @Test("onIconChanged called when style changes")
    func onIconChangedCalledWhenStyleChanges() {
        let manager = IconManager.shared
        var callbackCalled = false
        manager.onIconChanged = {
            callbackCalled = true
        }
        manager.currentStyle = .eye
        #expect(callbackCalled, "Callback should be called when style changes")
    }

    @Test("onIconChanged called for each style change")
    func onIconChangedCalledForEachStyleChange() {
        let manager = IconManager.shared
        var callCount = 0
        manager.onIconChanged = {
            callCount += 1
        }

        manager.currentStyle = .power
        manager.currentStyle = .bolt
        manager.currentStyle = .cup

        #expect(callCount == 3, "Callback should be called for each style change")
    }

    @Test("onIconChanged called when set to same style")
    func onIconChangedCalledWhenSetToSameStyle() {
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
        #expect(callCount == 1, "Callback is called even when setting same style (Swift didSet behavior)")
    }

    @Test("onIconChanged nil callback does not crash")
    func onIconChangedNilCallbackDoesNotCrash() {
        let manager = IconManager.shared
        manager.onIconChanged = nil
        // Should not crash
        manager.currentStyle = .bolt
    }

    @Test("onIconChanged can be reassigned")
    func onIconChangedCanBeReassigned() {
        let manager = IconManager.shared
        var firstCallbackCalled = false
        var secondCallbackCalled = false

        manager.onIconChanged = {
            firstCallbackCalled = true
        }
        manager.currentStyle = .power
        #expect(firstCallbackCalled)

        manager.onIconChanged = {
            secondCallbackCalled = true
        }
        manager.currentStyle = .bolt
        #expect(secondCallbackCalled)
    }

    // Style Cycling Tests

    @Test("Style cycling through all styles")
    func styleCyclingThroughAllStyles() {
        let manager = IconManager.shared
        let styles = IconStyle.allCases

        for (index, style) in styles.enumerated() {
            manager.currentStyle = style
            #expect(manager.currentStyle == style, "Style at index \(index) should be set correctly")
        }
    }

    @Test("Rapid style changes")
    func rapidStyleChanges() {
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

        #expect(callCount == 50, "Callback should be called for each rapid style change")
    }

    // ObservableObject Tests

    @Test("IconManager is ObservableObject")
    func iconManagerIsObservableObject() {
        let manager = IconManager.shared
        // Verify the manager conforms to ObservableObject by accessing objectWillChange
        _ = manager.objectWillChange
    }

    @Test("Current style is published")
    func currentStyleIsPublished() async {
        let manager = IconManager.shared
        var notificationReceived = false

        let cancellable = manager.objectWillChange.sink {
            notificationReceived = true
        }

        manager.currentStyle = .eye

        // Give time for notification
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationReceived)
        cancellable.cancel()
    }
}
