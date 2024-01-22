// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Logging",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Logging",
            targets: ["Logging"]
        ),
    ],
    targets: [
        .target(name: "Logging"),
        .testTarget(
            name: "LoggingTests",
            dependencies: ["Logging"]
        ),
    ]
)
