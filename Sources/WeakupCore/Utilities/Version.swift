import Foundation

// App Version

public enum AppVersion {
    // Default version (used as fallback)
    private static let defaultVersion = "1.1.0"
    private static let defaultBuild = "2"

    public static var string: String {
        // Try to read from bundle first, fallback to default
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return bundleVersion
        }
        return defaultVersion
    }

    public static var build: String {
        if let bundleBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return bundleBuild
        }
        return defaultBuild
    }

    public static var fullString: String {
        "\(string) (\(build))"
    }

    public struct Components: Sendable {
        public let major: Int
        public let minor: Int
        public let patch: Int
    }

    /// Semantic version components
    public static var components: Components {
        let parts = string.split(separator: ".").compactMap { Int($0) }
        return Components(
            major: !parts.isEmpty ? parts[0] : 1,
            minor: parts.count > 1 ? parts[1] : 0,
            patch: parts.count > 2 ? parts[2] : 0
        )
    }
}
