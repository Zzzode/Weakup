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
        // Test target for unit and integration tests (Swift Testing)
        // Note: Swift Testing is built into Swift 6.0+, no external dependency needed
        .testTarget(
            name: "WeakupTests",
            dependencies: ["WeakupCore"],
            path: "Tests/WeakupTests"
        )
        // Note: UI tests (WeakupUITests) are not included in SPM build.
        // They require XCTest/XCUITest and should be run via Xcode.
        // Swift Testing does not support UI testing.
    ]
)
