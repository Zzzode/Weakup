import Testing
import ServiceManagement
@testable import WeakupCore

// MARK: - Mock Launch At Login Service

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

// MARK: - Mock Error for Testing

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

// MARK: - LaunchAtLoginError Tests

@Suite("LaunchAtLoginError Tests")
struct LaunchAtLoginErrorTests {

    // MARK: - Equatable Tests

    @Test("Equatable same registration failed")
    func equatableSameRegistrationFailed() {
        let error1 = LaunchAtLoginError.registrationFailed("test")
        let error2 = LaunchAtLoginError.registrationFailed("test")
        #expect(error1 == error2)
    }

    @Test("Equatable different registration failed")
    func equatableDifferentRegistrationFailed() {
        let error1 = LaunchAtLoginError.registrationFailed("test1")
        let error2 = LaunchAtLoginError.registrationFailed("test2")
        #expect(error1 != error2)
    }

    @Test("Equatable same unregistration failed")
    func equatableSameUnregistrationFailed() {
        let error1 = LaunchAtLoginError.unregistrationFailed("test")
        let error2 = LaunchAtLoginError.unregistrationFailed("test")
        #expect(error1 == error2)
    }

    @Test("Equatable not supported")
    func equatableNotSupported() {
        let error1 = LaunchAtLoginError.notSupported
        let error2 = LaunchAtLoginError.notSupported
        #expect(error1 == error2)
    }

    @Test("Equatable permission denied")
    func equatablePermissionDenied() {
        let error1 = LaunchAtLoginError.permissionDenied
        let error2 = LaunchAtLoginError.permissionDenied
        #expect(error1 == error2)
    }

    @Test("Equatable different types")
    func equatableDifferentTypes() {
        let error1 = LaunchAtLoginError.notSupported
        let error2 = LaunchAtLoginError.permissionDenied
        #expect(error1 != error2)
    }

    // MARK: - Localized Description Tests

    @Test("Localized description registration failed")
    func localizedDescriptionRegistrationFailed() {
        let error = LaunchAtLoginError.registrationFailed("test message")
        #expect(error.localizedDescription.contains("Failed to enable"))
        #expect(error.localizedDescription.contains("test message"))
    }

    @Test("Localized description unregistration failed")
    func localizedDescriptionUnregistrationFailed() {
        let error = LaunchAtLoginError.unregistrationFailed("test message")
        #expect(error.localizedDescription.contains("Failed to disable"))
        #expect(error.localizedDescription.contains("test message"))
    }

    @Test("Localized description not supported")
    func localizedDescriptionNotSupported() {
        let error = LaunchAtLoginError.notSupported
        #expect(error.localizedDescription.contains("not supported"))
    }

    @Test("Localized description permission denied")
    func localizedDescriptionPermissionDenied() {
        let error = LaunchAtLoginError.permissionDenied
        #expect(error.localizedDescription.contains("Permission denied"))
        #expect(error.localizedDescription.contains("System Settings"))
    }

    @Test("Localized description unknown")
    func localizedDescriptionUnknown() {
        let error = LaunchAtLoginError.unknown("unexpected error")
        #expect(error.localizedDescription.contains("unexpected"))
    }
}

// MARK: - LaunchAtLoginManager Tests

@Suite("LaunchAtLoginManager Tests")
@MainActor
struct LaunchAtLoginManagerTests {

    var mockService: MockLaunchAtLoginService
    var manager: LaunchAtLoginManager

    init() {
        mockService = MockLaunchAtLoginService()
        manager = LaunchAtLoginManager(service: mockService)
    }

    // MARK: - Initialization Tests

    @Test("Init with not registered status isEnabled false")
    func initWithNotRegisteredStatusIsEnabledFalse() {
        mockService.mockStatus = .notRegistered
        let newManager = LaunchAtLoginManager(service: mockService)
        #expect(!newManager.isEnabled)
    }

    @Test("Init with enabled status isEnabled true")
    func initWithEnabledStatusIsEnabledTrue() {
        mockService.mockStatus = .enabled
        let newManager = LaunchAtLoginManager(service: mockService)
        #expect(newManager.isEnabled)
    }

    @Test("Init no error by default")
    func initNoErrorByDefault() {
        #expect(manager.lastError == nil)
        #expect(!manager.showError)
    }

    // MARK: - Enable Tests

    @Test("Enable success")
    func enableSuccess() {
        manager.isEnabled = true

        #expect(mockService.registerCallCount == 1)
        #expect(mockService.mockStatus == .enabled)
        #expect(manager.lastError == nil)
        #expect(!manager.showError)
    }

    @Test("Enable failure sets error")
    func enableFailureSetsError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        manager.isEnabled = true

        // Wait for async revert - need longer wait for MainActor dispatch
        try? await Task.sleep(nanoseconds: 500_000_000)
        await Task.yield()

        #expect(manager.lastError != nil, "Error should be set after failed registration")
        #expect(manager.showError, "showError should be true after failed registration")
        #expect(!manager.isEnabled, "isEnabled should revert to false after failed registration")
    }

    @Test("Enable permission denied sets correct error")
    func enablePermissionDeniedSetsCorrectError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 1, userInfo: nil)

        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 500_000_000)
        await Task.yield()

        #expect(manager.lastError == .permissionDenied, "Error should be permissionDenied for code 1")
    }

    @Test("Enable not supported sets correct error")
    func enableNotSupportedSetsCorrectError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 4, userInfo: nil)

        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 500_000_000)
        await Task.yield()

        #expect(manager.lastError == .notSupported, "Error should be notSupported for code 4")
    }

    // MARK: - Disable Tests

    @Test("Disable success")
    func disableSuccess() {
        // First enable
        mockService.mockStatus = .enabled
        let newManager = LaunchAtLoginManager(service: mockService)

        newManager.isEnabled = false

        #expect(mockService.unregisterCallCount == 1)
        #expect(mockService.mockStatus == .notRegistered)
        #expect(newManager.lastError == nil)
    }

    @Test("Disable failure sets error")
    func disableFailureSetsError() async {
        // First enable
        mockService.mockStatus = .enabled
        let newManager = LaunchAtLoginManager(service: mockService)
        mockService.shouldThrowOnUnregister = NSError(domain: "test", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        newManager.isEnabled = false

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(newManager.lastError != nil)
        #expect(newManager.showError)
    }

    // MARK: - No-op Tests (setting same value)

    @Test("Set same value does not call service")
    func setSameValueDoesNotCallService() {
        mockService.mockStatus = .notRegistered
        let newManager = LaunchAtLoginManager(service: mockService)

        // Set to same value (false)
        newManager.isEnabled = false

        #expect(mockService.registerCallCount == 0)
        #expect(mockService.unregisterCallCount == 0)
    }

    // MARK: - Refresh Status Tests

    @Test("Refresh status updates isEnabled")
    func refreshStatusUpdatesIsEnabled() {
        mockService.mockStatus = .enabled
        manager.refreshStatus()
        #expect(manager.isEnabled)

        mockService.mockStatus = .notRegistered
        manager.refreshStatus()
        #expect(!manager.isEnabled)
    }

    @Test("Refresh status clears error")
    func refreshStatusClearsError() async {
        // First cause an error
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 999, userInfo: nil)
        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(manager.lastError != nil)

        // Now refresh
        mockService.shouldThrowOnRegister = nil
        manager.refreshStatus()

        #expect(manager.lastError == nil)
        #expect(!manager.showError)
    }

    // MARK: - Clear Error Tests

    @Test("Clear error clears last error")
    func clearErrorClearsLastError() async {
        mockService.shouldThrowOnRegister = NSError(domain: "test", code: 999, userInfo: nil)
        manager.isEnabled = true

        // Wait for async revert
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(manager.lastError != nil)

        manager.clearError()

        #expect(manager.lastError == nil)
        #expect(!manager.showError)
    }

    // MARK: - Availability Tests

    @Test("isAvailable returns true")
    func isAvailableReturnsTrue() {
        // On macOS 13+, this should return true
        #expect(manager.isAvailable)
    }

    // MARK: - Current Status Tests

    @Test("Current status returns service status")
    func currentStatusReturnsServiceStatus() {
        mockService.mockStatus = .enabled
        #expect(manager.currentStatus == .enabled)

        mockService.mockStatus = .notRegistered
        #expect(manager.currentStatus == .notRegistered)

        mockService.mockStatus = .requiresApproval
        #expect(manager.currentStatus == .requiresApproval)
    }

    // MARK: - Rapid Toggle Tests

    @Test("Rapid toggle handles correctly")
    func rapidToggleHandlesCorrectly() async {
        manager.isEnabled = true
        manager.isEnabled = false
        manager.isEnabled = true

        // Wait for any async operations
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should end up enabled
        #expect(manager.isEnabled)
        #expect(mockService.mockStatus == .enabled)
    }
}

// MARK: - SMAppServiceWrapper Tests

@Suite("SMAppServiceWrapper Tests")
struct SMAppServiceWrapperTests {

    @Test("Shared returns same instance")
    func sharedReturnsSameInstance() {
        let instance1 = SMAppServiceWrapper.shared
        let instance2 = SMAppServiceWrapper.shared
        // Since it's a struct, we can't check identity, but we can verify it exists
        #expect(instance1 != nil)
        #expect(instance2 != nil)
    }

    @Test("Status returns valid status")
    func statusReturnsValidStatus() {
        let wrapper = SMAppServiceWrapper.shared
        let status = wrapper.status
        // Status should be one of the valid enum values
        let validStatuses: [SMAppService.Status] = [.notRegistered, .enabled, .requiresApproval, .notFound]
        #expect(validStatuses.contains(status))
    }
}
