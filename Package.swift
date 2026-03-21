// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AgentMonitor",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "AgentMonitorCore",
            targets: ["AgentMonitorCore"]
        ),
    ],
    targets: [
        // Core library (models + services, no SwiftUI dependency)
        .target(
            name: "AgentMonitorCore",
            path: "AgentMonitor/Models"
        ),
        .testTarget(
            name: "AgentMonitorTests",
            dependencies: ["AgentMonitorCore"],
            path: "AgentMonitorTests",
            resources: [.copy("Fixtures")]
        ),
    ]
)
