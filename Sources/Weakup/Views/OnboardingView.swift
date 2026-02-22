import SwiftUI
import WeakupCore

// Onboarding View

struct OnboardingView: View {
    @StateObject private var l10n = L10n.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var currentPage = 0
    @Binding var isPresented: Bool

    private let totalPages = 4

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                featurePage1.tag(1)
                featurePage2.tag(2)
                featurePage3.tag(3)
            }
            .tabViewStyle(.automatic)
            .frame(height: 280)

            pageIndicator
                .padding(.vertical, 12)

            buttonSection
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .frame(width: 320, height: 400)
        .preferredColorScheme(themeManager.effectiveColorScheme)
    }

    // Pages

    private var welcomePage: some View {
        VStack(spacing: 16) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text(l10n.onboardingWelcome)
                .font(.title2.weight(.bold))

            Text(l10n.onboardingWelcomeMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
    }

    private var featurePage1: some View {
        FeaturePageView(
            icon: "moon.zzz.fill",
            iconColor: .purple,
            title: l10n.onboardingFeature1Title,
            description: l10n.onboardingFeature1Desc
        )
    }

    private var featurePage2: some View {
        FeaturePageView(
            icon: "timer",
            iconColor: .orange,
            title: l10n.onboardingFeature2Title,
            description: l10n.onboardingFeature2Desc
        )
    }

    private var featurePage3: some View {
        FeaturePageView(
            icon: "keyboard",
            iconColor: .blue,
            title: l10n.onboardingFeature3Title,
            description: l10n.onboardingFeature3Desc
        )
    }

    // Components

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var buttonSection: some View {
        HStack {
            if currentPage > 0 {
                Button(l10n.onboardingSkip) {
                    completeOnboarding()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }

            Spacer()

            if currentPage < totalPages - 1 {
                Button(
                    action: { withAnimation { currentPage += 1 } },
                    label: {
                        HStack {
                            Text(l10n.onboardingNext)
                            Image(systemName: "chevron.right")
                        }
                    }
                )
                .buttonStyle(.borderedProminent)
            } else {
                Button(
                    action: { completeOnboarding() },
                    label: {
                        Text(l10n.onboardingGetStarted)
                    }
                )
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func completeOnboarding() {
        OnboardingManager.shared.markOnboardingComplete()
        isPresented = false
    }
}

// Feature Page View

private struct FeaturePageView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(iconColor)

            Text(title)
                .font(.title3.weight(.semibold))

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(20)
    }
}

// Onboarding Manager

@MainActor
public final class OnboardingManager: ObservableObject {
    public static let shared = OnboardingManager()

    @Published public var shouldShowOnboarding: Bool

    private let userDefaultsKey = "WeakupOnboardingComplete"

    private init() {
        self.shouldShowOnboarding = !UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    public func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
        shouldShowOnboarding = false
    }

    public func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: userDefaultsKey)
        shouldShowOnboarding = true
    }
}
