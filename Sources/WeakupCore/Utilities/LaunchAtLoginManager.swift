import Foundation
import ServiceManagement

// Launch At Login Manager

@MainActor
public final class LaunchAtLoginManager: ObservableObject {
    public static let shared = LaunchAtLoginManager()

    @Published public var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                setLaunchAtLogin(isEnabled)
            }
        }
    }

    private init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    // Public Methods

    /// Check current launch at login status
    public func refreshStatus() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    // Private Methods

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error.localizedDescription)")
            // Revert the published value if operation failed
            Task { @MainActor in
                self.isEnabled = SMAppService.mainApp.status == .enabled
            }
        }
    }
}
