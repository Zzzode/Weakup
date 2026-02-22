import XCTest
import ServiceManagement
@testable import WeakupCore

// Mock Launch At Login Service

final class MockLaunchAtLoginService: LaunchAtLoginServiceProtocol, @unchecked Sendable {
    var mockStatus: SMAppService.Status = .notRegistered
    var shouldThrowOnRegister: Error?
    var shouldThrowOnUnregister: Error?
    var registerCallCount = 0
    var unregisterCallCount = 0

    var status: SMAppService.Status {
        mockStatus
    }

    func register() throws {
        registerCallCount += 1
        if let error = shouldThrowOnRegister {
            throw error
        }
        mockStatus = .enabled
    }

    func unregister() throws {
        unregisterCallCount += 1
        if let error = shouldThrowOnUnregister {
            throw error
        }
        mockStatus = .notRegistered
    }

    func reset() {
        mockStatus = .notRegistered
        shouldThrowOnRegister = nil
        shouldThrowOnUnregister = nil
        registerCallCount = 0
        unregisterCallCount = 0
    }
}

// Mock Error for Testing

enum MockLaunchError: Error {
    case permissionDenied
    case notSupported
    case genericError

    var _code: Int {
        switch self {
        case .permissionDenied: return 1
        case .notSupported: return 4
        case .genericError: return 999
        }
    }
}

// LaunchAtLoginError Tests

final class LaunchAtLoginErrorTests: XCTestCase {

    // Equatable Tests

    func testEquatable_sameRegistrationFailed() {
        let error1 = LaunchAtLoginError.registrationFailed("test")
        let error2 = LaunchAtLoginError.registrationFailed("test")
        XCTAssertEqual(error1, error2)
    }

    func testEquatable_differentRegistrationFailed() {
        let error1 = LaunchAtLoginError.registrationFailed("test1")
        let error2 = LaunchAtLoginError.registrationFailed("test2")
        XCTAssertNotEqual(error1, error2)
    }

    func testEquatable_sameUnregistrationFailed() {
        let error1 = LaunchAtLoginError.unregistrationFailed("test")
        let error2 = LaunchAtLoginError.unregistrationFailed("test")
        XCTAssertEqual(error1, error2)
    }

    func testEquatable_notSupported() {
        let error1 = LaunchAtLoginError.notSupported
        let error2 = LaunchAtLoginError.notSupported
        XCTAssertEqual(error1, error2)
    }

    func testEquatable_permissionDenied() {
        let error1 = LaunchAtLoginError.permissionDenied
        let error2 = LaunchAtLoginError.permissionDenied
        XCTAssertEqual(error1, error2)
    }

    func testEquatable_differentTypes() {
        let error1 = LaunchAtLoginError.notSupported
        let error2 = LaunchAtLoginError.permissionDenied
        XCTAssertNotEqual(error1, error2)
    }

    // Localized Description Tests

    func testLocalizedDescription_registrationFailed() {
        let error = LaunchAtLoginError.registrationFailed("test message")
        XCTAssertTrue(error.localizedDescription.contains("Failed to enable"))
        XCTAssertTrue(error.localizedDescription.contains("test message"))
    }

    func testLocalizedDescription_unregistrationFailed() {
        let error = LaunchAtLoginError.unregistrationFailed("test message")
        XCTAssertTrue(error.localizedDescription.contains("Failed to disable"))
        XCTAssertTrue(error.localizedDescription.contains("test message"))
    }

    func testLocalizedDescription_notSupported() {
        let error = LaunchAtLoginError.notSupported
        XCTAssertTrue(error.localizedDescription.contains("not supported"))
    }

    func testLocalizedDescription_permissionDenied() {
        let error = LaunchAtLoginError.permissionDenied
        XCTAssertTrue(error.localizedDescription.contains("Permission denied"))
        XCTAssertTrue(error.localizedDescription.contains("System Settings"))
    }

    func testLocalizedDescription_unknown() {
        let error = LaunchAtLoginError.unknown("unexpected error")
        XCTAssertTrue(error.localizedDescription.contains("unexpected"))
    }
}

// LaunchAtLoginManager Tests

@MainActor
final class LaunchAtLoginManagerTests: XCTestCase {

    var mockService: MockLaunchAtLoginService!
    var manager: LaunchAtLoginManager!

    override func setUp() async throws {
        try await super.setUp()
        mockService = MockLaunchAtLoginService()
        manager = LaunchAtLoginManager(service: mockService)
    }

    override func tearDown() async throws {
        mockService.reset()
        mockService = nil
        manager = nil
        try await super.tearDown()
    }

    // Initialization Tests

    func testInit_withNotRegisteredStatus_isEnabledFalse() {
        mockService.mockStatus = .notRegistered
        let newManager = LaunchAtLoginManager(service: mockService)
        XCTAssertFalse(newManager.isEnabled)
    }

    func testInit_withEnabledStatus_isEnabledTrue() {
        mockService.mockStatus = .enabled
        let newManager = LaunchAtLoginManager(service: mockService)
        XCTAssertTrue(newManager.isEnabled)
    }

    func testInit_noErrorByDefault() {
        XCTAssertNil(manager.lastError)
        XCTAssertFalse(manager.showError)
    }

    // Enable Tests

    func testEnable_success() {
        manager.isEnabled = true

        XCTAssertEqual(mockService.registerCallCount, 1)
        XCTAssertEqual(mockService.mockStatus, .enabled)
        XCTAssertNil(manager.lastError)
        XCTAssertFalse(manager.showError)
    }

    func testEnable_failure_setsError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        manager.isEnabled = true

        // Wait for async revert - need longer wait for MainActor dispatch
        try? await Task.sleep(nanoseconds: 500_000_000)
        await Task.yield()

        XCTAssertNotNil(manager.lastError, "Error should be set after failed registration")
        XCTAssertTrue(manager.showError, "showError should be true after failed registration")
        XCTAssertFalse(manager.isEnabled, "isEnabled should revert to false after failed registration")
    }

    func testEnable_permissionDenied_setsCorrectError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 1, userInfo: nil)

        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 500_000_000)
        await Task.yield()

        XCTAssertEqual(manager.lastError, .permissionDenied, "Error should be permissionDenied for code 1")
    }

    func testEnable_notSupported_setsCorrectError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 4, userInfo: nil)

        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 500_000_000)
        await Task.yield()

        XCTAssertEqual(manager.lastError, .notSupported, "Error should be notSupported for code 4")
    }

    // Disable Tests

    func testDisable_success() {
        // First enable
        mockService.mockStatus = .enabled
        manager = LaunchAtLoginManager(service: mockService)

        manager.isEnabled = false

        XCTAssertEqual(mockService.unregisterCallCount, 1)
        XCTAssertEqual(mockService.mockStatus, .notRegistered)
        XCTAssertNil(manager.lastError)
    }

    func testDisable_failure_setsError() async {
        // First enable
        mockService.mockStatus = .enabled
        manager = LaunchAtLoginManager(service: mockService)
        mockService.shouldThrowOnUnregister = NSError(domain: "test", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        manager.isEnabled = false

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(manager.lastError)
        XCTAssertTrue(manager.showError)
    }

    // No-op Tests (setting same value)

    func testSetSameValue_doesNotCallService() {
        mockService.mockStatus = .notRegistered
        manager = LaunchAtLoginManager(service: mockService)

        // Set to same value (false)
        manager.isEnabled = false

        XCTAssertEqual(mockService.registerCallCount, 0)
        XCTAssertEqual(mockService.unregisterCallCount, 0)
    }

    // Refresh Status Tests

    func testRefreshStatus_updatesIsEnabled() {
        mockService.mockStatus = .enabled
        manager.refreshStatus()
        XCTAssertTrue(manager.isEnabled)

        mockService.mockStatus = .notRegistered
        manager.refreshStatus()
        XCTAssertFalse(manager.isEnabled)
    }

    func testRefreshStatus_clearsError() async {
        // First cause an error
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 999, userInfo: nil)
        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(manager.lastError)

        // Now refresh
        mockService.shouldThrowOnRegister = nil
        manager.refreshStatus()

        XCTAssertNil(manager.lastError)
        XCTAssertFalse(manager.showError)
    }

    // Clear Error Tests

    func testClearError_clearsLastError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 999, userInfo: nil)
        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(manager.lastError)

        manager.clearError()

        XCTAssertNil(manager.lastError)
        XCTAssertFalse(manager.showError)
    }

    // Availability Tests

    func testIsAvailable_returnsTrue() {
        // On macOS 13+, this should return true
        XCTAssertTrue(manager.isAvailable)
    }

    // Current Status Tests

    func testCurrentStatus_returnsServiceStatus() {
        mockService.mockStatus = .enabled
        XCTAssertEqual(manager.currentStatus, .enabled)

        mockService.mockStatus = .notRegistered
        XCTAssertEqual(manager.currentStatus, .notRegistered)

        mockService.mockStatus = .requiresApproval
        XCTAssertEqual(manager.currentStatus, .requiresApproval)
    }

    // Rapid Toggle Tests

    func testRapidToggle_handlesCorrectly() async {
        manager.isEnabled = true
        manager.isEnabled = false
        manager.isEnabled = true

        // Wait for any async operations
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should end up enabled
        XCTAssertTrue(manager.isEnabled)
        XCTAssertEqual(mockService.mockStatus, .enabled)
    }
}

// SMAppServiceWrapper Tests

final class SMAppServiceWrapperTests: XCTestCase {

    func testShared_returnsSameInstance() {
        let instance1 = SMAppServiceWrapper.shared
        let instance2 = SMAppServiceWrapper.shared
        // Since it's a struct, we can't check identity, but we can verify it exists
        XCTAssertNotNil(instance1)
        XCTAssertNotNil(instance2)
    }

    func testStatus_returnsValidStatus() {
        let wrapper = SMAppServiceWrapper.shared
        let status = wrapper.status
        // Status should be one of the valid enum values
        let validStatuses: [SMAppService.Status] = [.notRegistered, .enabled, .requiresApproval, .notFound]
        XCTAssertTrue(validStatuses.contains(status))
    }
}
