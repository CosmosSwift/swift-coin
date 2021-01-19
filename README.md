# swift-coin

![Swift5.3+](https://img.shields.io/badge/Swift-5.3+-blue.svg)
![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20linux-orange.svg)

Build blockchain applications in Swift on top of the Tendermint consensus using [SwiftNIO](https://github.com/apple/swift-nio) as the server core.

This project shows the work in progress for the port of the [Cosmos SDK]() to Swift. It is based on version [0.39.1]() of the SDK.

To make the porting more exciting, we have chosen to use the nameservice to implement the various necessary libraries for the sdk.

- Swift version: 5.3.x
- SwiftNIO version: 2.0.x
- ABCI version: 0.34 (tendermint 0.34)


## Installation

Requires macOS or a variant of Linux with the Swift 5.3.x toolchain installed.

When running on an Apple M1 from XCode, you need to set the minimum macOS version to 11 in `Pachage.swift` as such:
```
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "name-service",
    platforms: [
        //.macOS(.v10_15),
        .macOS("11.0")
    ],
...
)
```

## Getting Started

1. Checkout the code from github:
```
git clone https://github.com/cosmosswift/swift-coin.git
```

2. Compile and run

```bash
swift build
swift run nameserviced ${COMMAND} ${OPTIONS}
```

3. Run Tendermint and the nameservice.

Initialise and run Tendermint (for instance in Docker):

```bash
# initialise tendermint
docker run -it --rm -v "/tmp:/tendermint" tendermint/tendermint:v0.34 init

# initialise the namservice daemon
# note that this will update the config.toml file to use 0.0.0.0:26657 instead of 127.0.0.1:26657
# for incoming connections (this is only good for a development node or one where tendermint is running in docker)
swift run nameserviced init new_node -o

# run a single tendermint node
docker run -it --rm -v "/tmp:/tendermint" -p "26656-26657:26656-26657"  tendermint/tendermint:v0.34 node --proxy_app="tcp://host.docker.internal:26658"
# when using Docker for Apple M1 preview 7, add --platform linux/amd64 --add-host=host.docker.internal:host-gateway
# also, possibly replace the proxy_app flag with this: --proxy_app="tcp://192.168.64.1:26658"

# start the nameserviced
swift run nameserviced start
# when using Docker for Apple M1 preview 7, add --host 0.0.0.0 to enable listening from all addresses

```

## Development

Compile:

1. run `swift build`

## Documentation

The docs for the latest tagged release are always available at the [wiki](https://github.com/CosmosSwift/swift-coin/wiki).

## Questions

For bugs or feature requests, file a new [issue](https://github.com/cosmosswift/swift-coin/issues).

For all other support requests, please email [opensource@katalysis.io](mailto:opensource@katalysis.io).

## Changelog

[SemVer](https://semver.org/) changes are documented for each release on the [releases page](https://github.com/cosmosswift/swift-coin/-/releases).

## Contributing

Check out [CONTRIBUTING.md](https://github.com/cosmosswift/swift-coin/blob/master/CONTRIBUTING.md) for more information on how to help with **swift-abci**.

## Contributors

Check out [CONTRIBUTORS.txt](https://github.com/cosmosswift/swift-coin/blob/master/CONTRIBUTORS.txt) to see the full list. This list is updated for each release.
