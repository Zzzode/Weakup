import AppKit
import Carbon
import Combine
import SwiftUI
import WeakupCore

// App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var onboardingWindow: NSWindow?
    private var viewModel = CaffeineViewModel()
    @StateObject private var l10n = L10n.shared
    private let iconManager = IconManager.shared
    private let hotkeyManager = HotkeyManager.shared
    private let historyManager = ActivityHistoryManager.shared
    private let onboardingManager = OnboardingManager.shared
    private var viewModelObserver: Any?
    private var lastIsActive = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupHotkeys()
        setupIconChangeCallback()
        setupViewModelObserver()

        // Initialize lastIsActive state
        lastIsActive = viewModel.isActive

        // Show onboarding for first-time users
        if onboardingManager.shouldShowOnboarding {
            showOnboarding()
        }
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusIcon()

        // Left-click toggles caffeine, right-click shows menu
        statusItem?.button?.action = #selector(statusBarButtonClicked(_:))
        statusItem?.button?.target = self
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            // Right-click: show menu
            showContextMenu()
        } else {
            // Left-click: toggle caffeine
            toggleCaffeine()
        }
    }

    private func showContextMenu() {
        guard let statusItem else { return }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: L10n.shared.menuSettings, action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(
            title: L10n.shared.menuQuit,
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Clear menu so left-click works again
    }

    private func setupHotkeys() {
        // Set up global hotkey using HotkeyManager
        hotkeyManager.onHotkeyPressed = { [weak self] in
            Task { @MainActor [weak self] in
                self?.toggleCaffeine()
            }
        }
        hotkeyManager.registerHotkey()

        // Also keep local monitor for when app is focused (more reliable)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // Check if HotkeyManager is recording
            if hotkeyManager.isRecording {
                hotkeyManager.recordKey(keyCode: event.keyCode, modifiers: event.modifierFlags)
                return nil
            }

            // Check if this matches the current hotkey config
            let config = hotkeyManager.currentConfig
            let modifiers = event.modifierFlags
            var carbonModifiers: UInt32 = 0
            if modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
            if modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }
            if modifiers.contains(.option) { carbonModifiers |= UInt32(optionKey) }
            if modifiers.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }

            if UInt32(event.keyCode) == config.keyCode, carbonModifiers == config.modifiers {
                Task { @MainActor [weak self] in
                    self?.toggleCaffeine()
                }
                return nil
            }
            return event
        }
    }

    @objc private func toggleCaffeine() {
        viewModel.toggle()
        updateStatusIcon()
    }

    @objc private func showSettings() {
        if settingsWindow == nil {
            let rootView = SettingsView(viewModel: viewModel)
            let hostingController = NSHostingController(rootView: rootView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 340, height: 480),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )

            window.center()
            window.setFrameAutosaveName("SettingsWindow")
            window.title = L10n.shared.menuSettings
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden

            // Allow window to be moved by dragging background
            window.isMovableByWindowBackground = true

            settingsWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    private func setupIconChangeCallback() {
        iconManager.onIconChanged = { [weak self] in
            Task { @MainActor [weak self] in
                self?.updateStatusIcon()
            }
        }
    }

    private func setupViewModelObserver() {
        // Observe viewModel changes
        viewModelObserver = viewModel.objectWillChange.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                updateStatusIcon()
                handleStateChange()
            }
        }
    }

    private func handleStateChange() {
        if viewModel.isActive != lastIsActive {
            if viewModel.isActive {
                // Session started
                historyManager.startSession(
                    timerMode: viewModel.timerMode,
                    timerDuration: viewModel.timerMode ? viewModel.timerDuration : nil
                )
            } else {
                // Session ended
                historyManager.endSession()
            }
            lastIsActive = viewModel.isActive
        }
    }

    private func updateStatusIcon() {
        guard let button = statusItem?.button else { return }
        button.image = iconManager.currentImage(isActive: viewModel.isActive)
        button.toolTip = viewModel.isActive ? L10n.shared.statusOn : L10n.shared.statusOff

        // Show countdown in menu bar if enabled and timer is active
        if viewModel.showCountdownInMenuBar, viewModel.isActive, viewModel.timerMode, viewModel.timeRemaining > 0 {
            button.title = " " + formatMenuBarTime(viewModel.timeRemaining)
        } else {
            button.title = ""
        }
    }

    private func formatMenuBarTime(_ time: TimeInterval) -> String {
        TimeFormatter.countdown(time)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Ensure sleep prevention is released on quit
        if viewModel.isActive {
            viewModel.stop()
        }
        // Close windows if open
        settingsWindow?.close()
        settingsWindow = nil
        onboardingWindow?.close()
        onboardingWindow = nil
    }

    private func showOnboarding() {
        if onboardingWindow == nil {
            let rootView = OnboardingView(isPresented: Binding(
                get: { [weak self] in self?.onboardingWindow != nil },
                set: { [weak self] show in
                    if !show {
                        self?.onboardingWindow?.close()
                        self?.onboardingWindow = nil
                    }
                }
            ))
            let hostingController = NSHostingController(rootView: rootView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )

            window.center()
            window.title = "Welcome"
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden

            onboardingWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        onboardingWindow?.makeKeyAndOrderFront(nil)
    }
}
