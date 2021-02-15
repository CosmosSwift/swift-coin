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
        
        // X Modules
        .library(name: "XAuth", targets: ["XAuth"]),
        .library(name: "XBank", targets: ["XBank"]),
        .library(name: "XGenUtil", targets: ["XGenUtil"]),
        .library(name: "XGovernance", targets: ["XGovernance"]),
        .library(name: "XParams", targets: ["XParams"]),
        .library(name: "XSimulation", targets: ["XSimulation"]),
        .library(name: "XStaking", targets: ["XStaking"]),
        .library(name: "XSupply", targets: ["XSupply"]),
                
        // Executables
        .executable(name: "nameservicecli", targets: ["nameservicecli"]),
        .executable(name: "nameserviced", targets: ["nameserviced"]),
    ],
    dependencies: [
        .package(name: "ABCI", url: "https://github.com/CosmosSwift/swift-abci", .branch("master")),
        .package(name: "iAVLPlus", url: "https://github.com/CosmosSwift/swift-iavlplus", .branch("master")),
        .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.0.0")),
        .package(name: "swift-crypto", url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.8")),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1")),
        .package(name: "BigInt", url: "https://github.com/attaswift/BigInt", .upToNextMajor(from: "5.2.1")),
        .package(name: "swift-cosmos-proto", url: "https://github.com/cosmosswift/swift-cosmos-proto.git", .branch( "main")),
        .package(name: "swift-nio", url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),

    ],
    targets: [
        .target(
            name: "nameservicecli",
            dependencies: [
                .target(name: "App"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),

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
                .target(name: "XGenUtil"),
                .target(name: "XAuth"),
                .target(name: "XParams"),
                .target(name: "XBank"),
                .target(name: "XSupply"),
                .target(name: "XStaking"),
                .target(name: "XAuthAnte"),
            ]
        ),
        .target(
            name: "NameService",
            dependencies: [
                .target(name: "Cosmos"),
                .target(name: "XBank"),
            ]
        ),
        .target(
            name: "Cosmos",
            dependencies: [
                .target(name: "Database"),
                .target(name: "Tendermint"),
                .target(name: "BIP39"),
                .target(name: "Bcrypt"),
                .product(name: "iAVLPlus", package: "iAVLPlus"),
                .product(name: "InMemoryNodeDB", package: "iAVLPlus"),
//                .product(name: "SQLiteNodeDB", package: "iAVLPlus"),
                .product(name: "ABCI", package: "ABCI"),
                .product(name: "ABCINIO", package: "ABCI"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CosmosProto", package: "swift-cosmos-proto"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOTLS", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
            ]
        ),
        .target(
            name: "XAuth",
            dependencies: [
                .target(name: "Cosmos"),
                .target(name: "Tendermint"),
                .target(name: "XParams"),
                .product(name: "ABCI", package: "ABCI"),
                .product(name: "CosmosProto", package: "swift-cosmos-proto"),
                .product(name: "NIO", package: "swift-nio"),
            ],
            path: "./Sources/X/XAuth"
        ),
        .target(
            name: "XAuthAnte",
            dependencies: [
                .target(name: "XAuth"),
                .target(name: "XSupply"),
            ],
            path: "./Sources/X/XAuthAnte"
        ),
        .target(
            name: "XBank",
            dependencies: [
                .target(name: "Cosmos"),
                .target(name: "XAuth"),
                .target(name: "XParams"),
            ],
            path: "./Sources/X/XBank"
        ),
        .target(
            name: "XGenUtil",
            dependencies: [
                .target(name: "Cosmos"),
                .target(name: "XAuth"),
                .target(name: "XStaking"),
            ],
            path: "./Sources/X/XGenUtil"
        ),
        .target(
            name: "XGovernance",
            dependencies: [
                .target(name: "Cosmos"),
            ],
            path: "./Sources/X/XGovernance"
        ),
        .target(
            name: "XParams",
            dependencies: [
                .target(name: "Cosmos"),
            ],
            path: "./Sources/X/XParams"
        ),
        .target(
            name: "XSimulation",
            dependencies: [
                .target(name: "Cosmos"),
            ],
            path: "./Sources/X/XSimulation"
        ),
        .target(
            name: "XStaking",
            dependencies: [
                .target(name: "Cosmos"),
                .target(name: "XParams"),
                .target(name: "XAuth"),
                .target(name: "XSupply"),
            ],
            path: "./Sources/X/XStaking"
        ),
        .target(
            name: "XSupply",
            dependencies: [
                .target(name: "Cosmos"),
                .target(name: "XAuth"),
                .target(name: "XBank"),
            ],
            path: "./Sources/X/XSupply"
        ),
        .target(name: "Database"),
        .target(
            name: "Tendermint",
            dependencies: [
                .target(name: "Bech32"),
                .target(name: "JSON"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ABCI", package: "ABCI"),
            ]
        ),
        .target(name: "Bech32"),
        .target(
            name: "BIP39",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "BigInt", package: "BigInt"),
            ]
        ),
        .target(name: "CBcrypt"),
        .target(
            name: "Bcrypt",
            dependencies: [
                .target(name: "CBcrypt"),
            ]
        ),
        .target(name: "JSON"),
    ]
)
