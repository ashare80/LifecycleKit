// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPIR",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "SPIR",
            targets: ["SPIR"]
        ),
        .library(
            name: "Lifecycle",
            targets: ["Lifecycle"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(name: "Lifecycle",
                dependencies: []),
        .testTarget(name: "LifecycleTests",
                    dependencies: ["Lifecycle"]),
        .target(name: "SPIR",
                dependencies: ["Lifecycle"]),
        .testTarget(name: "SPIRTests",
                    dependencies: ["SPIR"]),
    ]
)
