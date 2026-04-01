// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EnigmaApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "EnigmaCore", targets: ["EnigmaCore"]),
        .executable(name: "EnigmaApp", targets: ["EnigmaApp"])
    ],
    targets: [
        .target(
            name: "EnigmaCore",
            path: "Sources/EnigmaCore"
        ),
        .executableTarget(
            name: "EnigmaApp",
            dependencies: ["EnigmaCore"],
            path: "Sources/EnigmaApp"
        ),
        .testTarget(
            name: "EnigmaCoreTests",
            dependencies: ["EnigmaCore"],
            path: "Tests/EnigmaCoreTests"
        )
    ]
)
