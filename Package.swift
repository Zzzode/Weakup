// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Weakup",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "weakup", targets: ["Weakup"]),
        .library(name: "WeakupCore", targets: ["WeakupCore"])
    ],
    targets: [
        // Core library containing testable business logic
        .target(
            name: "WeakupCore",
            path: "Sources/WeakupCore",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("IOKit"),
                .linkedFramework("UserNotifications"),
            ]
        ),
        // Main executable
        .executableTarget(
            name: "Weakup",
            dependencies: ["WeakupCore"],
            path: "Sources/Weakup",
            exclude: ["Info.plist", "Weakup.entitlements"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("IOKit"),
                .linkedFramework("Carbon"),
            ]
        ),
        // Test target
        .testTarget(
            name: "WeakupTests",
            dependencies: ["WeakupCore"],
            path: "Tests/WeakupTests"
        )
    ]
)
