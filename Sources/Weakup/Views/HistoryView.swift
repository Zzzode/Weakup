import SwiftUI
import WeakupCore

// History View

struct HistoryView: View {
    @StateObject private var historyManager = ActivityHistoryManager.shared
    @StateObject private var l10n = L10n.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(spacing: 16) {
            headerSection
            Divider()
            statisticsSection
            Divider()
            sessionListSection
            Divider()
            footerSection
        }
        .padding(16)
        .frame(width: 280, height: 400)
        .preferredColorScheme(themeManager.effectiveColorScheme)
        .alert(l10n.historyClearConfirmTitle, isPresented: $showClearConfirmation) {
            Button(l10n.cancel, role: .cancel) { }
            Button(l10n.historyClear, role: .destructive) {
                historyManager.clearHistory()
            }
        } message: {
            Text(l10n.historyClearConfirmMessage)
        }
    }

    // View Components

    private var headerSection: some View {
        HStack {
            Text(l10n.historyTitle)
                .font(.headline)
            Spacer()
            Button(action: { showClearConfirmation = true }) {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .disabled(historyManager.sessions.isEmpty)
        }
    }

    private var statisticsSection: some View {
        let stats = historyManager.statistics

        return VStack(spacing: 8) {
            HStack {
                StatCard(title: l10n.historyToday, value: formatDuration(stats.todayDuration), subtitle: "\(stats.todaySessions) \(l10n.historySessions)")
                StatCard(title: l10n.historyThisWeek, value: formatDuration(stats.weekDuration), subtitle: "\(stats.weekSessions) \(l10n.historySessions)")
            }

            HStack {
                StatCard(title: l10n.historyTotal, value: formatDuration(stats.totalDuration), subtitle: "\(stats.totalSessions) \(l10n.historySessions)")
                StatCard(title: l10n.historyAverage, value: formatDuration(stats.averageSessionDuration), subtitle: l10n.historyPerSession)
            }
        }
    }

    private var sessionListSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(l10n.historyRecentSessions)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if historyManager.sessions.isEmpty {
                Text(l10n.historyNoSessions)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(historyManager.sessions.prefix(20)) { session in
                            SessionRow(session: session)
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

    // Helper Methods

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
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
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
