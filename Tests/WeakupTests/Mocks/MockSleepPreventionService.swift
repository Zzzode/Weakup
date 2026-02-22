import Foundation

/// Protocol for sleep prevention service abstraction
/// Allows mocking IOPMAssertion behavior in tests
protocol SleepPreventionServiceProtocol {
    func createAssertion() -> Bool
    func releaseAssertion()
    var isAssertionActive: Bool { get }
}

/// Mock implementation of sleep prevention service for testing
class MockSleepPreventionService: SleepPreventionServiceProtocol {
    // State

    private(set) var isAssertionActive = false

    // Configuration

    /// Whether createAssertion should succeed
    var shouldSucceed = true

    /// Simulated delay for assertion creation (in seconds)
    var creationDelay: TimeInterval = 0

    // Tracking

    /// Number of times createAssertion was called
    private(set) var createCount = 0

    /// Number of times releaseAssertion was called
    private(set) var releaseCount = 0

    /// History of operations for verification
    private(set) var operationHistory: [Operation] = []

    enum Operation: Equatable {
        case create(success: Bool)
        case release
    }

    // Protocol Implementation

    func createAssertion() -> Bool {
        createCount += 1

        if creationDelay > 0 {
            Thread.sleep(forTimeInterval: creationDelay)
        }

        if shouldSucceed {
            isAssertionActive = true
            operationHistory.append(.create(success: true))
            return true
        }

        operationHistory.append(.create(success: false))
        return false
    }

    func releaseAssertion() {
        releaseCount += 1
        isAssertionActive = false
        operationHistory.append(.release)
    }

    // Test Helpers

    /// Reset all state and counters
    func reset() {
        isAssertionActive = false
        shouldSucceed = true
        creationDelay = 0
        createCount = 0
        releaseCount = 0
        operationHistory.removeAll()
    }

    /// Check if there are any leaked assertions (created but not released)
    var hasLeakedAssertions: Bool {
        return createCount > releaseCount && isAssertionActive
    }

    /// Get the balance of create/release operations
    var assertionBalance: Int {
        return createCount - releaseCount
    }
}
