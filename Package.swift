// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "name-service",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Tendermint", targets: ["Tendermint"]),
        .library(name: "Database", targets: ["Database"]),
        .library(name: "Cosmos", targets: ["Cosmos"]),
        .library(name: "App", targets: ["App"]),
        // App Module
        .library(name: "NameService", targets: ["NameService"]),
        // Executables
        .executable(name: "nameservicecli", targets: ["nameservicecli"]),
        .executable(name: "nameserviced", targets: ["nameserviced"]),
    ],
    dependencies: [
        .package(name: "ABCI", url: "https://github.com/CosmosSwift/swift-abci", .upToNextMajor(from: "0.34.0")),
        .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "swift-crypto", url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1")),
    ],
    targets: [
        .target(
            name: "nameservicecli",
            dependencies: [
                .product(name: "ABCI", package: "ABCI"),
                .product(name: "ABCINIO", package: "ABCI"),
                .target(name: "Cosmos"),
            ]
        ),
        .target(
            name: "nameserviced",
            dependencies: [
                .target(name: "App"),
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .target(name: "Cosmos"),
                .target(name: "NameService"),
            ]
        ),
        .target(
            name: "NameService",
            dependencies: [
                .target(name: "Cosmos"),
            ]
        ),
        .target(
            name: "Cosmos",
            dependencies: [
                .target(name: "IAVL"),
                .target(name: "Database"),
                .target(name: "Tendermint"),
                .product(name: "ABCI", package: "ABCI"),
                .product(name: "ABCINIO", package: "ABCI"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "IAVL",
            dependencies: [
                .target(name: "Database"),
            ]
        ),
        .target(name: "Database"),
        .target(
            name: "Tendermint",
            dependencies: [
                .target(name: "Bech32"),
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        .target(name: "Bech32"),
    ]
)

