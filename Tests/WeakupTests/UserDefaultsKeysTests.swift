import Testing
import Foundation
@testable import WeakupCore

/// Tests for UserDefaultsKeys and UserDefaultsStore
/// Covers key uniqueness, naming conventions, and removeAll functionality
@Suite("UserDefaultsKeys Tests")
@MainActor
struct UserDefaultsKeysTests {

    init() {
        // Clear all UserDefaults before each test
        for key in UserDefaultsKeys.all {
            UserDefaultsStore.shared.removeObject(forKey: key)
        }
    }

    // MARK: - Key Uniqueness Tests (UDK-001)

    @Test("All keys are unique")
    func allKeysAreUnique() {
        let keys = UserDefaultsKeys.all
        let uniqueKeys = Set(keys)
        #expect(keys.count == uniqueKeys.count, "All keys should be unique")
    }

    @Test("No duplicate keys in all array")
    func noDuplicateKeysInAllArray() {
        var seen = Set<String>()
        for key in UserDefaultsKeys.all {
            #expect(!seen.contains(key), "Key '\(key)' appears more than once")
            seen.insert(key)
        }
    }

    // MARK: - Naming Convention Tests (UDK-002)

    @Test("All keys have Weakup prefix")
    func allKeysHaveWeakupPrefix() {
        for key in UserDefaultsKeys.all {
            #expect(key.hasPrefix("Weakup"), "Key '\(key)' should have 'Weakup' prefix")
        }
    }

    @Test("Sound enabled key has correct prefix")
    func soundEnabledKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.soundEnabled.hasPrefix("Weakup"))
    }

    @Test("Timer mode key has correct prefix")
    func timerModeKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.timerMode.hasPrefix("Weakup"))
    }

    @Test("Timer duration key has correct prefix")
    func timerDurationKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.timerDuration.hasPrefix("Weakup"))
    }

    @Test("Show countdown in menu bar key has correct prefix")
    func showCountdownInMenuBarKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.showCountdownInMenuBar.hasPrefix("Weakup"))
    }

    @Test("Notifications enabled key has correct prefix")
    func notificationsEnabledKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.notificationsEnabled.hasPrefix("Weakup"))
    }

    @Test("Language key has correct prefix")
    func languageKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.language.hasPrefix("Weakup"))
    }

    @Test("Theme key has correct prefix")
    func themeKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.theme.hasPrefix("Weakup"))
    }

    @Test("Icon style key has correct prefix")
    func iconStyleKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.iconStyle.hasPrefix("Weakup"))
    }

    @Test("Hotkey config key has correct prefix")
    func hotkeyConfigKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.hotkeyConfig.hasPrefix("Weakup"))
    }

    @Test("Hotkey override conflicts key has correct prefix")
    func hotkeyOverrideConflictsKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.hotkeyOverrideConflicts.hasPrefix("Weakup"))
    }

    @Test("Activity history key has correct prefix")
    func activityHistoryKeyHasCorrectPrefix() {
        #expect(UserDefaultsKeys.activityHistory.hasPrefix("Weakup"))
    }

    // MARK: - Key Value Tests (UDK-003)

    @Test("Sound enabled key value")
    func soundEnabledKeyValue() {
        #expect(UserDefaultsKeys.soundEnabled == "WeakupSoundEnabled")
    }

    @Test("Timer mode key value")
    func timerModeKeyValue() {
        #expect(UserDefaultsKeys.timerMode == "WeakupTimerMode")
    }

    @Test("Timer duration key value")
    func timerDurationKeyValue() {
        #expect(UserDefaultsKeys.timerDuration == "WeakupTimerDuration")
    }

    @Test("Show countdown in menu bar key value")
    func showCountdownInMenuBarKeyValue() {
        #expect(UserDefaultsKeys.showCountdownInMenuBar == "WeakupShowCountdownInMenuBar")
    }

    @Test("Notifications enabled key value")
    func notificationsEnabledKeyValue() {
        #expect(UserDefaultsKeys.notificationsEnabled == "WeakupNotificationsEnabled")
    }

    @Test("Language key value")
    func languageKeyValue() {
        #expect(UserDefaultsKeys.language == "WeakupLanguage")
    }

    @Test("Theme key value")
    func themeKeyValue() {
        #expect(UserDefaultsKeys.theme == "WeakupTheme")
    }

    @Test("Icon style key value")
    func iconStyleKeyValue() {
        #expect(UserDefaultsKeys.iconStyle == "WeakupIconStyle")
    }

    @Test("Hotkey config key value")
    func hotkeyConfigKeyValue() {
        #expect(UserDefaultsKeys.hotkeyConfig == "WeakupHotkeyConfig")
    }

    @Test("Hotkey override conflicts key value")
    func hotkeyOverrideConflictsKeyValue() {
        #expect(UserDefaultsKeys.hotkeyOverrideConflicts == "WeakupOverrideConflicts")
    }

    @Test("Activity history key value")
    func activityHistoryKeyValue() {
        #expect(UserDefaultsKeys.activityHistory == "WeakupActivityHistory")
    }

    // MARK: - All Array Completeness Tests (UDK-004)

    @Test("All array contains expected count")
    func allArrayContainsExpectedCount() {
        #expect(UserDefaultsKeys.all.count == 11, "Should have 11 keys")
    }

    @Test("All array contains sound enabled")
    func allArrayContainsSoundEnabled() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.soundEnabled))
    }

    @Test("All array contains timer mode")
    func allArrayContainsTimerMode() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.timerMode))
    }

    @Test("All array contains timer duration")
    func allArrayContainsTimerDuration() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.timerDuration))
    }

    @Test("All array contains show countdown in menu bar")
    func allArrayContainsShowCountdownInMenuBar() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.showCountdownInMenuBar))
    }

    @Test("All array contains notifications enabled")
    func allArrayContainsNotificationsEnabled() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.notificationsEnabled))
    }

    @Test("All array contains language")
    func allArrayContainsLanguage() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.language))
    }

    @Test("All array contains theme")
    func allArrayContainsTheme() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.theme))
    }

    @Test("All array contains icon style")
    func allArrayContainsIconStyle() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.iconStyle))
    }

    @Test("All array contains hotkey config")
    func allArrayContainsHotkeyConfig() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.hotkeyConfig))
    }

    @Test("All array contains hotkey override conflicts")
    func allArrayContainsHotkeyOverrideConflicts() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.hotkeyOverrideConflicts))
    }

    @Test("All array contains activity history")
    func allArrayContainsActivityHistory() {
        #expect(UserDefaultsKeys.all.contains(UserDefaultsKeys.activityHistory))
    }

    // MARK: - removeAll Tests (UDK-005)

    @Test("removeAll removes all keys")
    func removeAllRemovesAllKeys() {
        // Set values for all keys
        UserDefaultsStore.shared.set(true, forKey: UserDefaultsKeys.soundEnabled)
        UserDefaultsStore.shared.set(true, forKey: UserDefaultsKeys.timerMode)
        UserDefaultsStore.shared.set(1800.0, forKey: UserDefaultsKeys.timerDuration)
        UserDefaultsStore.shared.set(true, forKey: UserDefaultsKeys.showCountdownInMenuBar)
        UserDefaultsStore.shared.set(true, forKey: UserDefaultsKeys.notificationsEnabled)
        UserDefaultsStore.shared.set("en", forKey: UserDefaultsKeys.language)
        UserDefaultsStore.shared.set("dark", forKey: UserDefaultsKeys.theme)
        UserDefaultsStore.shared.set("bolt", forKey: UserDefaultsKeys.iconStyle)
        UserDefaultsStore.shared.set(Data(), forKey: UserDefaultsKeys.hotkeyConfig)
        UserDefaultsStore.shared.set(true, forKey: UserDefaultsKeys.hotkeyOverrideConflicts)
        UserDefaultsStore.shared.set(Data(), forKey: UserDefaultsKeys.activityHistory)

        // Verify values are set
        #expect(UserDefaultsStore.shared.object(forKey: UserDefaultsKeys.soundEnabled) != nil)
        #expect(UserDefaultsStore.shared.object(forKey: UserDefaultsKeys.timerMode) != nil)

        // Remove all
        UserDefaultsKeys.removeAll()

        // Verify all keys are removed
        for key in UserDefaultsKeys.all {
            #expect(UserDefaultsStore.shared.object(forKey: key) == nil, "Key '\(key)' should be removed")
        }
    }

    @Test("removeAll with custom defaults")
    func removeAllWithCustomDefaults() {
        // Create a custom UserDefaults suite for testing
        let suiteName = "TestSuite.\(ProcessInfo.processInfo.processIdentifier)"
        guard let customDefaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Failed to create custom UserDefaults")
            return
        }

        // Set values
        customDefaults.set(true, forKey: UserDefaultsKeys.soundEnabled)
        customDefaults.set("ja", forKey: UserDefaultsKeys.language)

        // Verify values are set
        #expect(customDefaults.object(forKey: UserDefaultsKeys.soundEnabled) != nil)
        #expect(customDefaults.object(forKey: UserDefaultsKeys.language) != nil)

        // Remove all from custom defaults
        UserDefaultsKeys.removeAll(from: customDefaults)

        // Verify keys are removed from custom defaults
        #expect(customDefaults.object(forKey: UserDefaultsKeys.soundEnabled) == nil)
        #expect(customDefaults.object(forKey: UserDefaultsKeys.language) == nil)

        // Clean up
        customDefaults.removePersistentDomain(forName: suiteName)
    }

    @Test("removeAll is idempotent")
    func removeAllIsIdempotent() {
        // Set some values
        UserDefaultsStore.shared.set(true, forKey: UserDefaultsKeys.soundEnabled)

        // Remove all twice
        UserDefaultsKeys.removeAll()
        UserDefaultsKeys.removeAll()

        // Should not crash and all keys should still be nil
        for key in UserDefaultsKeys.all {
            #expect(UserDefaultsStore.shared.object(forKey: key) == nil)
        }
    }

    @Test("removeAll only removes Weakup keys")
    func removeAllOnlyRemovesWeakupKeys() {
        // Set a non-Weakup key
        let nonWeakupKey = "SomeOtherAppKey"
        UserDefaultsStore.shared.set("test", forKey: nonWeakupKey)

        // Set a Weakup key
        UserDefaultsStore.shared.set(true, forKey: UserDefaultsKeys.soundEnabled)

        // Remove all Weakup keys
        UserDefaultsKeys.removeAll()

        // Non-Weakup key should still exist
        #expect(UserDefaultsStore.shared.object(forKey: nonWeakupKey) != nil)

        // Weakup key should be removed
        #expect(UserDefaultsStore.shared.object(forKey: UserDefaultsKeys.soundEnabled) == nil)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: nonWeakupKey)
    }
}

@Suite("UserDefaultsStore Tests")
@MainActor
struct UserDefaultsStoreTests {

    // MARK: - Test Isolation Tests (UDS-001)

    @Test("Shared instance exists")
    func sharedInstanceExists() {
        #expect(UserDefaultsStore.shared != nil)
    }

    @Test("Shared instance is consistent")
    func sharedInstanceIsConsistent() {
        let instance1 = UserDefaultsStore.shared
        let instance2 = UserDefaultsStore.shared
        #expect(instance1 === instance2, "Shared should return same instance")
    }

    @Test("Test environment uses isolated store")
    func testEnvironmentUsesIsolatedStore() {
        // In test environment, UserDefaultsStore should use a suite name
        // This test verifies isolation by checking that we can set/get values
        let testKey = "TestIsolationKey"
        let testValue = "TestValue"

        UserDefaultsStore.shared.set(testValue, forKey: testKey)
        let retrieved = UserDefaultsStore.shared.string(forKey: testKey)

        #expect(retrieved == testValue)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: testKey)
    }

    @Test("Values persist within test session")
    func valuesPersistWithinTestSession() {
        let key = "PersistenceTestKey"
        let value = 42

        UserDefaultsStore.shared.set(value, forKey: key)
        let retrieved = UserDefaultsStore.shared.integer(forKey: key)

        #expect(retrieved == value)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    // MARK: - Data Type Tests (UDS-002)

    @Test("Store and retrieve bool")
    func storeAndRetrieveBool() {
        let key = "BoolTestKey"

        UserDefaultsStore.shared.set(true, forKey: key)
        #expect(UserDefaultsStore.shared.bool(forKey: key) == true)

        UserDefaultsStore.shared.set(false, forKey: key)
        #expect(UserDefaultsStore.shared.bool(forKey: key) == false)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    @Test("Store and retrieve string")
    func storeAndRetrieveString() {
        let key = "StringTestKey"
        let value = "Hello, World!"

        UserDefaultsStore.shared.set(value, forKey: key)
        #expect(UserDefaultsStore.shared.string(forKey: key) == value)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    @Test("Store and retrieve integer")
    func storeAndRetrieveInteger() {
        let key = "IntegerTestKey"
        let value = 12345

        UserDefaultsStore.shared.set(value, forKey: key)
        #expect(UserDefaultsStore.shared.integer(forKey: key) == value)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    @Test("Store and retrieve double")
    func storeAndRetrieveDouble() {
        let key = "DoubleTestKey"
        let value = 3.14159

        UserDefaultsStore.shared.set(value, forKey: key)
        #expect(UserDefaultsStore.shared.double(forKey: key) == value)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    @Test("Store and retrieve data")
    func storeAndRetrieveData() {
        let key = "DataTestKey"
        let value = "Test Data".data(using: .utf8)!

        UserDefaultsStore.shared.set(value, forKey: key)
        #expect(UserDefaultsStore.shared.data(forKey: key) == value)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    @Test("Store and retrieve array")
    func storeAndRetrieveArray() {
        let key = "ArrayTestKey"
        let value = ["one", "two", "three"]

        UserDefaultsStore.shared.set(value, forKey: key)
        let retrieved = UserDefaultsStore.shared.array(forKey: key) as? [String]
        #expect(retrieved == value)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    @Test("Store and retrieve dictionary")
    func storeAndRetrieveDictionary() {
        let key = "DictionaryTestKey"
        let value: [String: Any] = ["name": "Test", "count": 42]

        UserDefaultsStore.shared.set(value, forKey: key)
        let retrieved = UserDefaultsStore.shared.dictionary(forKey: key)

        #expect(retrieved?["name"] as? String == "Test")
        #expect(retrieved?["count"] as? Int == 42)

        // Clean up
        UserDefaultsStore.shared.removeObject(forKey: key)
    }

    // MARK: - Remove Object Tests (UDS-003)

    @Test("Remove object removes value")
    func removeObjectRemovesValue() {
        let key = "RemoveTestKey"

        UserDefaultsStore.shared.set("value", forKey: key)
        #expect(UserDefaultsStore.shared.object(forKey: key) != nil)

        UserDefaultsStore.shared.removeObject(forKey: key)
        #expect(UserDefaultsStore.shared.object(forKey: key) == nil)
    }

    @Test("Remove non-existent key does not crash")
    func removeNonExistentKeyDoesNotCrash() {
        let key = "NonExistentKey"

        // Should not crash
        UserDefaultsStore.shared.removeObject(forKey: key)
        #expect(UserDefaultsStore.shared.object(forKey: key) == nil)
    }

    // MARK: - Default Value Tests (UDS-004)

    @Test("Bool returns false for non-existent key")
    func boolReturnsFalseForNonExistentKey() {
        let key = "NonExistentBoolKey"
        #expect(UserDefaultsStore.shared.bool(forKey: key) == false)
    }

    @Test("Integer returns zero for non-existent key")
    func integerReturnsZeroForNonExistentKey() {
        let key = "NonExistentIntKey"
        #expect(UserDefaultsStore.shared.integer(forKey: key) == 0)
    }

    @Test("Double returns zero for non-existent key")
    func doubleReturnsZeroForNonExistentKey() {
        let key = "NonExistentDoubleKey"
        #expect(UserDefaultsStore.shared.double(forKey: key) == 0.0)
    }

    @Test("String returns nil for non-existent key")
    func stringReturnsNilForNonExistentKey() {
        let key = "NonExistentStringKey"
        #expect(UserDefaultsStore.shared.string(forKey: key) == nil)
    }

    @Test("Data returns nil for non-existent key")
    func dataReturnsNilForNonExistentKey() {
        let key = "NonExistentDataKey"
        #expect(UserDefaultsStore.shared.data(forKey: key) == nil)
    }

    @Test("Array returns nil for non-existent key")
    func arrayReturnsNilForNonExistentKey() {
        let key = "NonExistentArrayKey"
        #expect(UserDefaultsStore.shared.array(forKey: key) == nil)
    }

    @Test("Dictionary returns nil for non-existent key")
    func dictionaryReturnsNilForNonExistentKey() {
        let key = "NonExistentDictKey"
        #expect(UserDefaultsStore.shared.dictionary(forKey: key) == nil)
    }
}
