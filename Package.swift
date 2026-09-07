// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppleMediaManager",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "AppleMediaManager",
            targets: ["AppleMediaManager"]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppleMediaManager"
        ),
        .testTarget(
            name: "AppleMediaManagerTests",
            dependencies: ["AppleMediaManager"]
        )
    ]
)
