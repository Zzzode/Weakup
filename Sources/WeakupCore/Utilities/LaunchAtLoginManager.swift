import Foundation
import ServiceManagement

// Launch At Login Error Types

/// Errors that can occur when managing launch at login settings
public enum LaunchAtLoginError: Error, Equatable {
    case registrationFailed(String)
    case unregistrationFailed(String)
    case notSupported
    case permissionDenied
    case unknown(String)

    public var localizedDescription: String {
        switch self {
        case let .registrationFailed(message):
            "Failed to enable launch at login: \(message)"
        case let .unregistrationFailed(message):
            "Failed to disable launch at login: \(message)"
        case .notSupported:
            "Launch at login is not supported on this system"
        case .permissionDenied:
            "Permission denied. Please check System Settings > Login Items"
        case let .unknown(message):
            "An unexpected error occurred: \(message)"
        }
    }
}

// Launch At Login Service Protocol

/// Protocol for launch at login service to enable testing
public protocol LaunchAtLoginServiceProtocol: Sendable {
    var status: SMAppService.Status { get }
    func register() throws
    func unregister() throws
}

/// Default implementation using SMAppService
public struct SMAppServiceWrapper: LaunchAtLoginServiceProtocol {
    public static let shared = SMAppServiceWrapper()

    public var status: SMAppService.Status {
        SMAppService.mainApp.status
    }

    public func register() throws {
        try SMAppService.mainApp.register()
    }

    public func unregister() throws {
        try SMAppService.mainApp.unregister()
    }
}

// Launch At Login Manager

@MainActor
public final class LaunchAtLoginManager: ObservableObject {
    public static let shared = LaunchAtLoginManager()

    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
            NSClassFromString("XCTestCase") != nil
    }

    @Published public var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled, !isReverting {
                setLaunchAtLogin(isEnabled)
            }
        }
    }

    /// The last error that occurred, if any
    @Published public private(set) var lastError: LaunchAtLoginError?

    /// Whether an error is currently being displayed
    @Published public var showError: Bool = false

    /// Flag to prevent recursive calls during error revert
    private var isReverting = false

    private let service: LaunchAtLoginServiceProtocol

    private init() {
        self.service = SMAppServiceWrapper.shared
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    /// Initialize with a custom service (for testing)
    public init(service: LaunchAtLoginServiceProtocol) {
        self.service = service
        self.isEnabled = service.status == .enabled
    }

    // Public Methods

    /// Check current launch at login status
    public func refreshStatus() {
        isEnabled = service.status == .enabled
        // Clear any previous error on refresh
        clearError()
    }

    /// Clear the current error state
    public func clearError() {
        lastError = nil
        showError = false
    }

    /// Check if the service is available on this system
    public var isAvailable: Bool {
        // SMAppService is available on macOS 13+
        if #available(macOS 13.0, *) {
            return true
        }
        return false
    }

    /// Get the current status from the service
    public var currentStatus: SMAppService.Status {
        service.status
    }

    // Private Methods

    private func setLaunchAtLogin(_ enabled: Bool) {
        // Clear previous error
        clearError()

        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            let launchError = mapError(error, isEnabling: enabled)
            lastError = launchError
            showError = true

            // Log the error for debugging
            if !Self.isRunningTests {
                print("LaunchAtLoginManager: \(launchError.localizedDescription)")
            }

            // Revert the published value if operation failed
            Task { @MainActor in
                self.isReverting = true
                self.isEnabled = self.service.status == .enabled
                self.isReverting = false
            }
        }
    }

    private func mapError(_ error: Error, isEnabling: Bool) -> LaunchAtLoginError {
        let nsError = error as NSError

        // Check for specific error codes
        switch nsError.code {
        case 1: // Operation not permitted
            return .permissionDenied
        case 4: // Not supported
            return .notSupported
        default:
            if isEnabling {
                return .registrationFailed(error.localizedDescription)
            } else {
                return .unregistrationFailed(error.localizedDescription)
            }
        }
    }
}
