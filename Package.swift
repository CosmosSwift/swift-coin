// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "name-service",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        // Executables
        .executable(name: "nameservicecli", targets: ["nameservicecli"]),
        .executable(name: "nameserviced", targets: ["nameserviced"]),

        // App Module
        .library(name: "App", targets: ["App"]),

        // X Modules
        .library(name: "NameService", targets: ["NameService"]),
    ],
    dependencies: [
        .package(name: "swift-cosmos", url: "https://github.com/CosmosSwift/swift-cosmos", .branch("main")),
        //.package(path: "../swift-cosmos"),
        .package(name: "swift-abci", url: "https://github.com/CosmosSwift/swift-abci", .branch("main")),
        //.package(path: "../swift-abci"),
        .package(name: "swift-tendermint", url: "https://github.com/CosmosSwift/swift-tendermint", .branch("main")),
        //.package(path: "../swift-tendermint"),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1")),
        .package(name: "swift-nio", url: "https://github.com/apple/swift-nio",  .upToNextMajor(from: "2.26.0")),
    ],
    targets: [
        .executableTarget(
            name: "nameservicecli",
            dependencies: [
                .target(name: "App"),
                .target(name: "NameService"),
                .product(name: "Auth", package: "swift-cosmos"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOTLS", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "Tendermint", package: "swift-tendermint"),
            ]
        ),
        .executableTarget(
            name: "nameserviced",
            dependencies: [
                .target(name: "App"),
                .target(name: "NameService"),
                .product(name: "Auth", package: "swift-cosmos"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOTLS", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),            ]
        ),
        .target(
            name: "App",
            dependencies: [
                .target(name: "NameService"),
                .product(name: "Cosmos", package: "swift-cosmos"),
                .product(name: "GenUtil", package: "swift-cosmos"),
                .product(name: "Auth", package: "swift-cosmos"),
                .product(name: "Params", package: "swift-cosmos"),
                .product(name: "Bank", package: "swift-cosmos"),
                .product(name: "Supply", package: "swift-cosmos"),
                .product(name: "Staking", package: "swift-cosmos"),
                .product(name: "AuthAnte", package: "swift-cosmos"),
            ]
        ),
        .target(
            name: "NameService",
            dependencies: [
                .product(name: "Cosmos", package: "swift-cosmos"),
                .product(name: "Bank", package: "swift-cosmos"),
            ],
            path: "./Sources/X/NameService"
        ),
    ]
)
