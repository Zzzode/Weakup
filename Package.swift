// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Weakup",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "weakup", targets: ["Weakup"])
    ],
    targets: [
        .executableTarget(
            name: "Weakup",
            path: "Sources",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("IOKit"),
                .linkedFramework("Carbon"),
            ]
        )
    ]
)
