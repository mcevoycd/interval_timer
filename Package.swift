// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IntervalTimer",
    products: [
        .library(name: "IntervalTimerCore", targets: ["IntervalTimerCore"]),
    ],
    targets: [
        .target(
            name: "IntervalTimerCore"
        ),
        .testTarget(
            name: "IntervalTimerCoreTests",
            dependencies: ["IntervalTimerCore"]
        ),
    ]
)
