import AppKit
import WeakupCore

// MARK: - App Entry Point

@MainActor
struct WeakupApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

// Entry point
WeakupApp.main()
