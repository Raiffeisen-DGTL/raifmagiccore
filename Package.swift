// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RaifMagicCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "RaifMagicCore",
            targets: ["RaifMagicCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/XcodeProj.git", .upToNextMajor(from: "8.10.0")),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
        .package(url: "https://github.com/Raiffeisen-DGTL/CommandExecutor.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "RaifMagicCore",
            dependencies: [
                "XcodeProj",
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "CommandExecutor", package: "CommandExecutor"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)
