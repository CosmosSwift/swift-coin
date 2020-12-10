// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "swift-coin",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(name: "ABCI", url: "https://github.com/CosmosSwift/swift-abci", .upToNextMajor(from: "0.34.0")),
    ],
    targets: [
        .target(
            name: "swift-coin",
            dependencies: [
                .product(name: "ABCI", package: "ABCI"),
                .product(name: "ABCINIO", package: "ABCI"),
                .target(name: "Routing"),
                .target(name: "Cosmos"),
                .target(name: "Bank"),
            ]
        ),
        .target(name: "Routing"),
        .target(name: "Database"),
        .target(
            name: "Bank",
            dependencies: [
                .target(name: "Cosmos"),
            ]
        ),
        .target(
            name: "Cosmos",
            dependencies: [
                .target(name: "Database"),
                .product(name: "ABCI", package: "ABCI"),
            ]
        ),
        .testTarget(
            name: "swift-coinTests",
            dependencies: ["swift-coin"]
        ),
    ]
)

