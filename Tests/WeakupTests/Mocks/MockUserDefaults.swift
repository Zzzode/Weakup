import Foundation

/// Mock UserDefaults for testing purposes
/// Provides isolated storage that doesn't affect real UserDefaults
class MockUserDefaults: UserDefaults {
    private var storage: [String: Any] = [:]

    override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
    }

    convenience init() {
        self.init(suiteName: nil)!
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        if let value = value {
            storage[defaultName] = value
        } else {
            storage.removeValue(forKey: defaultName)
        }
    }

    override func set(_ value: Bool, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func set(_ value: Double, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func set(_ value: Int, forKey defaultName: String) {
        storage[defaultName] = value
    }

    override func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }

    override func bool(forKey defaultName: String) -> Bool {
        return storage[defaultName] as? Bool ?? false
    }

    override func double(forKey defaultName: String) -> Double {
        return storage[defaultName] as? Double ?? 0
    }

    override func integer(forKey defaultName: String) -> Int {
        return storage[defaultName] as? Int ?? 0
    }

    override func string(forKey defaultName: String) -> String? {
        return storage[defaultName] as? String
    }

    override func data(forKey defaultName: String) -> Data? {
        return storage[defaultName] as? Data
    }

    override func array(forKey defaultName: String) -> [Any]? {
        return storage[defaultName] as? [Any]
    }

    override func dictionary(forKey defaultName: String) -> [String: Any]? {
        return storage[defaultName] as? [String: Any]
    }

    override func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }

    override func synchronize() -> Bool {
        return true
    }

    // MARK: - Test Helpers

    /// Reset all stored values
    func reset() {
        storage.removeAll()
    }

    /// Get all stored keys
    var allKeys: [String] {
        return Array(storage.keys)
    }

    /// Check if a key exists
    func hasKey(_ key: String) -> Bool {
        return storage[key] != nil
    }

    /// Get the raw storage for debugging
    var rawStorage: [String: Any] {
        return storage
    }
}
