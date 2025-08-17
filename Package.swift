// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ExpenseTracker",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ExpenseTracker",
            targets: ["ExpenseTracker"]
        ),
    ],
    targets: [
        .target(
            name: "ExpenseTracker",
            dependencies: [],
            path: ".",
            exclude: [
                "Tests",
                "README.md",
                ".git"
            ]
        ),
        .testTarget(
            name: "ExpenseTrackerTests",
            dependencies: ["ExpenseTracker"],
            path: "Tests"
        ),
    ]
)