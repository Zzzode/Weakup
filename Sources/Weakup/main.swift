import SwiftUI
import AppKit
import IOKit.pwr_mgt

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

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var viewModel = CaffeineViewModel()
    @StateObject private var l10n = L10n.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupHotkeys()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusIcon()
        updateMenu()

        statusItem?.button?.action = #selector(toggleCaffeine)
        statusItem?.button?.target = self
    }

    private func updateMenu() {
        guard let statusItem = statusItem else { return }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: L10n.shared.menuSettings, action: #selector(showSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: L10n.shared.menuQuit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func setupHotkeys() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .control]) && event.keyCode == 0x1D { // Cmd+Ctrl+0 (0 key)
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

    private func updateStatusIcon() {
        guard let button = statusItem?.button else { return }
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let imageName = viewModel.isActive ? "power.circle.fill" : "power.circle"
        button.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
        button.toolTip = viewModel.isActive ? L10n.shared.statusOn : L10n.shared.statusOff
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

// MARK: - View Model

@MainActor
final class CaffeineViewModel: ObservableObject {
    @Published var isActive = false
    @Published var timerMode = false
    @Published var timeRemaining: TimeInterval = 0
    private(set) var timerDuration: TimeInterval = 0

    private var timer: Timer?
    private var assertionID: IOPMAssertionID = 0

    func toggle() {
        isActive ? stop() : start()
    }

    func start() {
        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Weakup preventing sleep" as CFString,
            &id
        )

        guard result == kIOReturnSuccess else { return }
        assertionID = id
        isActive = true

        if timerMode && timerDuration > 0 {
            timeRemaining = timerDuration
            startTimer()
        }

        updateStatusBar()
    }

    func stop() {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        timer?.invalidate()
        timer = nil
        isActive = false
        timeRemaining = 0
        updateStatusBar()
    }

    func setTimerDuration(_ seconds: TimeInterval) {
        timerDuration = seconds
        if isActive {
            stop()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.timeRemaining -= 1

                if self.timeRemaining <= 0 {
                    self.stop()
                } else {
                    self.updateStatusBar()
                }
            }
        }
    }

    private func updateStatusBar() {
        Task { @MainActor [weak self] in
            self?.objectWillChange.send()
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var viewModel: CaffeineViewModel
    @StateObject private var l10n = L10n.shared
    @State private var selectedDuration = 0

    private let durations = [
        (0, "duration_off"),
        (900, "duration_15m"),
        (1800, "duration_30m"),
        (3600, "duration_1h"),
        (7200, "duration_2h"),
        (10800, "duration_3h")
    ]

    var body: some View {
        VStack(spacing: 12) {
            // Header with language picker
            HStack {
                Circle()
                    .fill(viewModel.isActive ? Color.green : Color.gray)
                    .frame(width: 10, height: 10)
                Text(l10n.appName)
                    .font(.headline)
                Spacer()
                Picker("", selection: $l10n.currentLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 90)
            }

            Divider()

            // Status
            Text(viewModel.isActive ? l10n.statusPreventingSleep : l10n.statusSleepEnabled)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Timer display
            if viewModel.isActive && viewModel.timerMode && viewModel.timeRemaining > 0 {
                Text(formatTime(viewModel.timeRemaining))
                    .font(.system(.title2, design: .monospaced).weight(.bold))
            }

            Divider()

            // Timer toggle
            HStack {
                Text(l10n.timerMode)
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.timerMode },
                    set: { newValue in
                        viewModel.timerMode = newValue
                        if viewModel.isActive { viewModel.stop() }
                    }
                ))
                    .toggleStyle(.switch)
            }

            // Duration picker
            if viewModel.timerMode {
                HStack {
                    Text(l10n.duration)
                        .font(.subheadline)
                    Spacer()
                    Picker(l10n.duration, selection: Binding(
                        get: { selectedDuration },
                        set: { newValue in
                            selectedDuration = newValue
                            viewModel.setTimerDuration(TimeInterval(durations[selectedDuration].0))
                        }
                    )) {
                        ForEach(0..<durations.count, id: \.self) { index in
                            Text(l10n.string(forKey: durations[index].1)).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Divider()

            // Main button
            Button(action: { viewModel.toggle() }) {
                HStack {
                    Image(systemName: viewModel.isActive ? "stop.circle.fill" : "play.circle.fill")
                    Text(viewModel.isActive ? l10n.turnOff : l10n.turnOn)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(viewModel.isActive ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .foregroundColor(viewModel.isActive ? .red : .green)

            // Shortcut hint
            Text(l10n.shortcutHint)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(width: 240)
        .id("SettingsView")
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Entry point
WeakupApp.main()
