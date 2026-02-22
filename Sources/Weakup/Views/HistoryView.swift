import SwiftUI
import UniformTypeIdentifiers
import WeakupCore

// History View

struct HistoryView: View {
    @StateObject private var historyManager = ActivityHistoryManager.shared
    @StateObject private var l10n = L10n.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showClearConfirmation = false
    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @State private var exportFormat: ExportFormat = .json
    @State private var alertMessage: String?
    @State private var showAlert = false
    @State private var showChart = false
    @State private var sessionToDelete: ActivitySession?

    var body: some View {
        VStack(spacing: 12) {
            headerSection
            Divider()
            statisticsSection
            if showChart {
                chartSection
            }
            Divider()
            filterAndSearchSection
            sessionListSection
            Divider()
            footerSection
        }
        .padding(16)
        .frame(width: 320, height: 500)
        .preferredColorScheme(themeManager.effectiveColorScheme)
        .alert(l10n.historyClearConfirmTitle, isPresented: $showClearConfirmation) {
            Button(l10n.cancel, role: .cancel) {}
            Button(l10n.historyClear, role: .destructive) {
                historyManager.clearHistory()
            }
        } message: {
            Text(l10n.historyClearConfirmMessage)
        }
        .alert(alertMessage ?? "", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        .sheet(isPresented: $showExportSheet) {
            exportSheet
        }
        .fileImporter(
            isPresented: $showImportSheet,
            allowedContentTypes: [.json, UTType(filenameExtension: "csv") ?? .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
    }

    // View Components

    private var headerSection: some View {
        HStack {
            Text(l10n.historyTitle)
                .font(.headline)
            Spacer()
            Button(
                action: { showChart.toggle() },
                label: {
                    Image(systemName: showChart ? "chart.bar.fill" : "chart.bar")
                        .foregroundColor(.accentColor)
                }
            )
            .buttonStyle(.plain)
            .help(l10n.historyChart)

            Menu {
                Button(
                    action: { showExportSheet = true },
                    label: {
                        Label(l10n.historyExport, systemImage: "square.and.arrow.up")
                    }
                )
                .disabled(historyManager.sessions.isEmpty)

                Button(
                    action: { showImportSheet = true },
                    label: {
                        Label(l10n.historyImport, systemImage: "square.and.arrow.down")
                    }
                )
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
            .menuStyle(.borderlessButton)

            Button(
                action: { showClearConfirmation = true },
                label: {
                    Image(systemName: "trash")
                        .foregroundColor(.secondary)
                }
            )
            .buttonStyle(.plain)
            .disabled(historyManager.sessions.isEmpty)
        }
    }

    private var statisticsSection: some View {
        let stats = historyManager.statistics

        return VStack(spacing: 8) {
            HStack {
                StatCard(
                    title: l10n.historyToday,
                    value: formatDuration(stats.todayDuration),
                    subtitle: "\(stats.todaySessions) \(l10n.historySessions)"
                )
                StatCard(
                    title: l10n.historyThisWeek,
                    value: formatDuration(stats.weekDuration),
                    subtitle: "\(stats.weekSessions) \(l10n.historySessions)"
                )
            }

            HStack {
                StatCard(
                    title: l10n.historyTotal,
                    value: formatDuration(stats.totalDuration),
                    subtitle: "\(stats.totalSessions) \(l10n.historySessions)"
                )
                StatCard(
                    title: l10n.historyAverage,
                    value: formatDuration(stats.averageSessionDuration),
                    subtitle: l10n.historyPerSession
                )
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l10n.historyLast7Days)
                .font(.caption)
                .foregroundColor(.secondary)

            ActivityChart(data: historyManager.dailyStatistics(days: 7))
                .frame(height: 80)
        }
        .padding(.vertical, 4)
    }

    private var filterAndSearchSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(l10n.historySearch, text: $historyManager.searchText)
                    .textFieldStyle(.plain)
                if !historyManager.searchText.isEmpty {
                    Button(
                        action: { historyManager.searchText = "" },
                        label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)

            HStack {
                Picker(l10n.historyFilter, selection: $historyManager.filterMode) {
                    ForEach(HistoryFilterMode.allCases) { mode in
                        Text(l10n.string(forKey: mode.localizationKey)).tag(mode)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)

                Picker(l10n.historySort, selection: $historyManager.sortOrder) {
                    ForEach(HistorySortOrder.allCases) { order in
                        Text(l10n.string(forKey: order.localizationKey)).tag(order)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
            }
            .font(.caption)
        }
    }

    private var sessionListSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(l10n.historyRecentSessions)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if historyManager.filteredSessions.isEmpty {
                Text(l10n.historyNoSessions)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(historyManager.filteredSessions.prefix(50)) { session in
                            SessionRow(
                                session: session,
                                onDelete: {
                                    sessionToDelete = session
                                }
                            )
                            .contextMenu {
                                Button(role: .destructive) {
                                    historyManager.deleteSession(session)
                                } label: {
                                    Label(l10n.historyDeleteSession, systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
        }
    }

    private var footerSection: some View {
        Text(l10n.historyPrivacyNote)
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }

    private var exportSheet: some View {
        VStack(spacing: 16) {
            Text(l10n.historyExport)
                .font(.headline)

            Picker(l10n.historyExportFormat, selection: $exportFormat) {
                ForEach(ExportFormat.allCases) { format in
                    Text(format.displayName).tag(format)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                Button(l10n.cancel) {
                    showExportSheet = false
                }
                .buttonStyle(.bordered)

                Button(l10n.historyExport) {
                    performExport()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 250)
        .preferredColorScheme(themeManager.effectiveColorScheme)
    }

    // Helper Methods

    private func formatDuration(_ duration: TimeInterval) -> String {
        TimeFormatter.duration(duration)
    }

    private func performExport() {
        guard let result = historyManager.exportHistory(format: exportFormat) else {
            alertMessage = l10n.historyImportError
            showAlert = true
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [
            exportFormat == .json ? .json : UTType(filenameExtension: "csv") ?? .plainText
        ]
        savePanel.nameFieldStringValue = result.suggestedFilename

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try result.data.write(to: url)
                    alertMessage = l10n.historyExportSuccess
                    showAlert = true
                } catch {
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }

        showExportSheet = false
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else { return }

            do {
                let data = try Data(contentsOf: url)
                let format: ExportFormat = url.pathExtension.lowercased() == "json" ? .json : .csv

                let importResult = historyManager.importHistory(from: data, format: format)

                switch importResult {
                case let .success(imported, skipped):
                    var message = String(format: l10n.historyImportSuccess, imported)
                    if skipped > 0 {
                        message += "\n" + String(format: l10n.historyImportSkipped, skipped)
                    }
                    alertMessage = message
                    showAlert = true
                case let .failure(error):
                    alertMessage = "\(l10n.historyImportError): \(error)"
                    showAlert = true
                }
            } catch {
                alertMessage = "\(l10n.historyImportError): \(error.localizedDescription)"
                showAlert = true
            }

        case let .failure(error):
            alertMessage = "\(l10n.historyImportError): \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// Session Row

private struct SessionRow: View {
    let session: ActivitySession
    let onDelete: () -> Void
    @StateObject private var l10n = L10n.shared

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(formatDate(session.startTime))
                    .font(.caption)
                if session.wasTimerMode {
                    Text(l10n.historyTimerMode)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(formatDuration(session.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        TimeFormatter.sessionDuration(duration)
    }
}

// Activity Chart

private struct ActivityChart: View {
    let data: [DailyStatistic]

    private var maxDuration: TimeInterval {
        data.map(\.totalDuration).max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(data) { stat in
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            stat.totalDuration > 0
                                ? Color.accentColor : Color.secondary.opacity(0.3)
                        )
                        .frame(height: barHeight(for: stat.totalDuration))

                    Text(dayLabel(for: stat.date))
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func barHeight(for duration: TimeInterval) -> CGFloat {
        guard maxDuration > 0 else { return 4 }
        let ratio = duration / maxDuration
        return max(4, CGFloat(ratio) * 60)
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
