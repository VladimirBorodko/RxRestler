// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwaggerGenerator",
    dependencies: [
        .package(url: "https://github.com/kareman/SwiftShell", from: "4.1.2"),
        .package(url: "https://github.com/jatoben/CommandLine", from: "3.0.0-pre1"),
    ],
    targets: [
        .target(
            name: "SwaggerGenerator",
            dependencies: ["SwiftShell", "CommandLine"]
        ),
    ]
)

