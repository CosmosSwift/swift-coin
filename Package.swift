// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "name-service",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(name: "ABCI", url: "https://github.com/CosmosSwift/swift-abci", .upToNextMajor(from: "0.34.0")),
        .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "nameservicecli",
            dependencies: [
                .product(name: "ABCI", package: "ABCI"),
                .product(name: "ABCINIO", package: "ABCI"),
                .target(name: "Cosmos"),
                .target(name: "Bank"),
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
                .target(name: "Bank"),
            ]
        ),
        .target(
            name: "Cosmos",
            dependencies: [
                .target(name: "Database"),
                .target(name: "Tendermint"),
                .product(name: "ABCI", package: "ABCI"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "Bank",
            dependencies: [
                .target(name: "Cosmos"),
            ]
        ),
        .target(name: "Database"),
        .target(name: "Tendermint"),
    ]
)

