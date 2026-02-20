import SwiftUI
import AppKit
import Combine
import Carbon
import WeakupCore

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var viewModel = CaffeineViewModel()
    @StateObject private var l10n = L10n.shared
    private let iconManager = IconManager.shared
    private let hotkeyManager = HotkeyManager.shared
    private var viewModelObserver: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupHotkeys()
        setupIconChangeCallback()
        setupViewModelObserver()
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
        guard let statusItem = statusItem else { return }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: L10n.shared.menuSettings, action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L10n.shared.menuQuit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil  // Clear menu so left-click works again
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
            guard let self = self else { return event }

            // Check if HotkeyManager is recording
            if self.hotkeyManager.isRecording {
                self.hotkeyManager.recordKey(keyCode: event.keyCode, modifiers: event.modifierFlags)
                return nil
            }

            // Check if this matches the current hotkey config
            let config = self.hotkeyManager.currentConfig
            let modifiers = event.modifierFlags
            var carbonModifiers: UInt32 = 0
            if modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
            if modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }
            if modifiers.contains(.option) { carbonModifiers |= UInt32(optionKey) }
            if modifiers.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }

            if UInt32(event.keyCode) == config.keyCode && carbonModifiers == config.modifiers {
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
        if popover == nil {
            popover = NSPopover()
            popover?.behavior = .transient
            let rootView = SettingsView(
                viewModel: viewModel
            )
            popover?.contentViewController = NSHostingController(rootView: rootView)
        }

        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func setupIconChangeCallback() {
        iconManager.onIconChanged = { [weak self] in
            Task { @MainActor [weak self] in
                self?.updateStatusIcon()
            }
        }
    }

    private func setupViewModelObserver() {
        // Observe viewModel changes to update status bar countdown
        viewModelObserver = viewModel.objectWillChange.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateStatusIcon()
            }
        }
    }

    private func updateStatusIcon() {
        guard let button = statusItem?.button else { return }
        button.image = iconManager.currentImage(isActive: viewModel.isActive)
        button.toolTip = viewModel.isActive ? L10n.shared.statusOn : L10n.shared.statusOff

        // Show countdown in menu bar if enabled and timer is active
        if viewModel.showCountdownInMenuBar && viewModel.isActive && viewModel.timerMode && viewModel.timeRemaining > 0 {
            button.title = " " + formatMenuBarTime(viewModel.timeRemaining)
        } else {
            button.title = ""
        }
    }

    private func formatMenuBarTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Ensure sleep prevention is released on quit
        if viewModel.isActive {
            viewModel.stop()
        }
        // Close popover if open
        popover?.close()
        popover = nil
    }
}
