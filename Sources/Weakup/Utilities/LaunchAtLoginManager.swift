import Foundation
import ServiceManagement

// MARK: - Launch At Login Manager

@MainActor
final class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()

    @Published var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                setLaunchAtLogin(isEnabled)
            }
        }
    }

    private init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    // MARK: - Public Methods

    /// Check current launch at login status
    func refreshStatus() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    // MARK: - Private Methods

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
