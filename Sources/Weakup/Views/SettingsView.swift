import SwiftUI
import WeakupCore

// Settings View

struct SettingsView: View {
    @ObservedObject var viewModel: CaffeineViewModel
    @StateObject private var l10n = L10n.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var iconManager = IconManager.shared
    @StateObject private var launchAtLoginManager = LaunchAtLoginManager.shared
    @StateObject private var hotkeyManager = HotkeyManager.shared
    @State private var selectedDuration = 0
    @State private var showCustomDuration = false
    @State private var customHours = 0
    @State private var customMinutes = 30

    /// Use centralized preset durations
    private var presetDurations: [(duration: TimeInterval, key: String)] {
        AppConstants.TimerPresets.withKeys
    }

    private let customDurationIndex = 6

    var body: some View {
        VStack(spacing: 12) {
            headerSection
            Divider()
            statusSection
            timerDisplaySection
            Divider()
            timerToggleSection
            durationPickerSection
            soundToggleSection
            notificationToggleSection
            countdownInMenuBarSection
            themePickerSection
            iconPickerSection
            launchAtLoginSection
            hotkeySection
            Divider()
            mainButtonSection
            shortcutHintSection
        }
        .padding(20)
        .frame(width: 300)
        .id("SettingsView")
        .preferredColorScheme(themeManager.effectiveColorScheme)
        .sheet(isPresented: $showCustomDuration) {
            customDurationSheet
        }
    }

    // View Components

    private var headerSection: some View {
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
    }

    private var statusSection: some View {
        Text(viewModel.isActive ? l10n.statusPreventingSleep : l10n.statusSleepEnabled)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var timerDisplaySection: some View {
        if viewModel.isActive, viewModel.timerMode, viewModel.timeRemaining > 0 {
            Text(formatTime(viewModel.timeRemaining))
                .font(.system(.title2, design: .monospaced).weight(.bold))
        }
    }

    private var timerToggleSection: some View {
        HStack {
            Text(l10n.timerMode)
                .font(.subheadline)
            Spacer()
            Toggle(
                "",
                isOn: Binding(
                    get: { viewModel.timerMode },
                    set: { newValue in
                        viewModel.timerMode = newValue
                        if viewModel.isActive { viewModel.stop() }
                    }
                )
            )
            .toggleStyle(.switch)
        }
    }

    private var soundToggleSection: some View {
        HStack {
            Text(l10n.soundFeedback)
                .font(.subheadline)
            Spacer()
            Toggle("", isOn: $viewModel.soundEnabled)
                .toggleStyle(.switch)
        }
    }

    private var notificationToggleSection: some View {
        HStack {
            Text(l10n.notifications)
                .font(.subheadline)
            Spacer()
            Toggle("", isOn: $viewModel.notificationsEnabled)
                .toggleStyle(.switch)
        }
    }

    private var countdownInMenuBarSection: some View {
        HStack {
            Text(l10n.showCountdownInMenuBar)
                .font(.subheadline)
            Spacer()
            Toggle("", isOn: $viewModel.showCountdownInMenuBar)
                .toggleStyle(.switch)
        }
    }

    private var themePickerSection: some View {
        HStack {
            Text(l10n.theme)
                .font(.subheadline)
            Spacer()
            Picker("", selection: $themeManager.currentTheme) {
                ForEach(Array(AppTheme.allCases), id: \.self) { theme in
                    Text(l10n.string(forKey: theme.localizationKey)).tag(theme)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)
        }
    }

    private var iconPickerSection: some View {
        HStack {
            Text(l10n.iconStyle)
                .font(.subheadline)
            Spacer()
            Picker("", selection: $iconManager.currentStyle) {
                ForEach(IconStyle.allCases) { style in
                    HStack {
                        Image(systemName: style.activeSymbol)
                        Text(l10n.string(forKey: style.localizationKey))
                    }
                    .tag(style)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)
        }
    }

    private var launchAtLoginSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(l10n.launchAtLogin)
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $launchAtLoginManager.isEnabled)
                    .toggleStyle(.switch)
                    .disabled(!launchAtLoginManager.isAvailable)
            }

            if let error = launchAtLoginManager.lastError {
                Text(localizedErrorMessage(for: error))
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
    }

    private func localizedErrorMessage(for error: LaunchAtLoginError) -> String {
        switch error {
        case .permissionDenied:
            l10n.launchAtLoginPermissionDenied
        case .notSupported:
            l10n.launchAtLoginNotSupported
        case .registrationFailed:
            l10n.launchAtLoginEnableFailed
        case .unregistrationFailed:
            l10n.launchAtLoginDisableFailed
        case .unknown:
            error.localizedDescription
        }
    }

    private var hotkeySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(l10n.hotkey)
                    .font(.subheadline)
                Spacer()
                if hotkeyManager.isRecording {
                    Text(l10n.hotkeyRecording)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                } else {
                    Text(hotkeyManager.currentConfig.displayString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 8) {
                Button(hotkeyManager.isRecording ? l10n.cancel : l10n.hotkeyRecord) {
                    if hotkeyManager.isRecording {
                        hotkeyManager.stopRecording()
                    } else {
                        hotkeyManager.startRecording()
                    }
                }
                .font(.caption)
                .buttonStyle(.bordered)

                Button(l10n.hotkeyReset) {
                    hotkeyManager.resetToDefault()
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .disabled(hotkeyManager.currentConfig == .defaultConfig)
            }

            // Conflict detection UI
            if hotkeyManager.hasConflict {
                hotkeyConflictView
            }
        }
    }

    private var hotkeyConflictView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Show conflict message with severity-based color
            if let conflict = hotkeyManager.highestSeverityConflict {
                HStack(spacing: 4) {
                    Image(systemName: conflictIcon(for: conflict.severity))
                        .foregroundColor(conflictColor(for: conflict.severity))
                    Text(hotkeyManager.conflictMessage ?? l10n.hotkeyConflictMessage)
                        .font(.caption2)
                        .foregroundColor(conflictColor(for: conflict.severity))
                }

                // Show suggestion
                if let suggestion = conflict.suggestion {
                    Text(suggestion)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.leading, 16)
                }

                // Override option for non-high severity conflicts
                if conflict.severity != .high {
                    HStack {
                        Toggle(
                            l10n.hotkeyOverrideConflict,
                            isOn: Binding(
                                get: { hotkeyManager.overrideConflicts },
                                set: { hotkeyManager.setOverrideConflicts($0) }
                            )
                        )
                        .font(.caption2)
                        .toggleStyle(.checkbox)
                    }
                    .padding(.top, 2)
                }
            } else if let message = hotkeyManager.conflictMessage {
                Text(message)
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
    }

    private func conflictColor(for severity: HotkeyConflict.ConflictSeverity) -> Color {
        switch severity {
        case .high: .red
        case .medium: .orange
        case .low: .yellow
        }
    }

    private func conflictIcon(for severity: HotkeyConflict.ConflictSeverity) -> String {
        switch severity {
        case .high: "exclamationmark.triangle.fill"
        case .medium: "exclamationmark.circle.fill"
        case .low: "info.circle.fill"
        }
    }

    @ViewBuilder
    private var durationPickerSection: some View {
        if viewModel.timerMode {
            VStack(spacing: 8) {
                HStack {
                    Text(l10n.duration)
                        .font(.subheadline)
                    Spacer()
                    Picker(
                        l10n.duration,
                        selection: Binding(
                            get: { selectedDuration },
                            set: { newValue in
                                if newValue == customDurationIndex {
                                    showCustomDuration = true
                                } else {
                                    selectedDuration = newValue
                                    viewModel.setTimerDuration(presetDurations[newValue].duration)
                                }
                            }
                        )
                    ) {
                        ForEach(0..<presetDurations.count, id: \.self) { index in
                            Text(l10n.string(forKey: presetDurations[index].key)).tag(index)
                        }
                        Text(l10n.durationCustom).tag(customDurationIndex)
                    }
                    .pickerStyle(.menu)
                }

                // Show custom duration display if selected
                if selectedDuration == customDurationIndex, viewModel.timerDuration > 0 {
                    HStack {
                        Spacer()
                        Text(formatDurationDisplay(viewModel.timerDuration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button(
                            action: { showCustomDuration = true },
                            label: {
                                Image(systemName: "pencil.circle")
                                    .foregroundColor(.accentColor)
                            }
                        )
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var customDurationSheet: some View {
        VStack(spacing: 16) {
            Text(l10n.customDurationTitle)
                .font(.headline)

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text(l10n.hours)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Stepper(value: $customHours, in: 0...24) {
                        Text("\(customHours)")
                            .font(.system(.title2, design: .monospaced))
                            .frame(width: 40)
                    }
                }

                VStack(spacing: 4) {
                    Text(l10n.minutes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Stepper(value: $customMinutes, in: 0...59) {
                        Text("\(customMinutes)")
                            .font(.system(.title2, design: .monospaced))
                            .frame(width: 40)
                    }
                }
            }

            Text(l10n.maxDurationHint)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button(l10n.cancel) {
                    showCustomDuration = false
                }
                .buttonStyle(.bordered)

                Button(l10n.set) {
                    applyCustomDuration()
                }
                .buttonStyle(.borderedProminent)
                .disabled(customHours == 0 && customMinutes == 0)
            }
        }
        .padding(20)
        .frame(width: 240)
        .preferredColorScheme(themeManager.effectiveColorScheme)
    }

    private var mainButtonSection: some View {
        Button(
            action: { viewModel.toggle() },
            label: {
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
        )
        .buttonStyle(.plain)
        .foregroundColor(viewModel.isActive ? .red : .green)
    }

    private var shortcutHintSection: some View {
        VStack(spacing: 4) {
            Text(l10n.shortcutHint)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("v\(AppVersion.string)")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.7))
        }
    }

    // Helper Methods

    private func formatTime(_ time: TimeInterval) -> String {
        TimeFormatter.countdown(time)
    }

    private func formatDurationDisplay(_ seconds: TimeInterval) -> String {
        TimeFormatter.duration(seconds)
    }

    private func applyCustomDuration() {
        let totalSeconds = TimeFormatter.interval(hours: customHours, minutes: customMinutes)
        // Enforce max duration
        let clampedSeconds = min(totalSeconds, AppConstants.TimerPresets.maximum)
        viewModel.setTimerDuration(clampedSeconds)
        selectedDuration = customDurationIndex
        showCustomDuration = false
    }
}
