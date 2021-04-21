# swift-coin / nameservice [ALPHA]

![Swift5.4+](https://img.shields.io/badge/Swift-5.4+-blue.svg)
![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20linux-orange.svg)

Build blockchain applications in Swift on top of the Tendermint consensus using [SwiftNIO](https://github.com/apple/swift-nio) as the server core.

This project shows the work in progress for the port of the [Cosmos SDK](https://github.com/cosmos/cosmos-sdk) to Swift. It is originally based on version [0.39.1](https://github.com/cosmos/cosmos-sdk/tree/v0.39.1) of the SDK, however, we have also incorporated some code from later versions.

To make the porting more exciting, we have chosen to use the [nameservice](https://github.com/cosmos/sdk-tutorials/tree/master/nameservice) to implement the various necessary libraries for the sdk.

The primary focus is to get to parity with the Cosmos-SDK version 0.40. We are currently tracking version 0.33.9 because the Go nameservice still requires it.

## Requirements
- Swift version: 5.4.x
- SwiftNIO version: 2.0.x
- Tendermint/ABCI version: 0.34.0 (tendermint 0.34.0)

## Installation

Requires macOS or a variant of Linux with the Swift 5.4.x toolchain installed.

When running on an Apple M1 from XCode, you need to set the minimum macOS version to 11 in `Package.swift` as such:
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

1. Compile

```bash
swift build
```

3. Run Tendermint and the nameservice. 

Initialise and run Tendermint (for instance in Docker):
```bash
# initialise tendermint
docker run -it --rm -v "~/.nameserviced:/tendermint" tendermint/tendermint:v0.34.0 init

# initialise the namservice daemon
# note that this will update the config.toml file to use 0.0.0.0:26657 instead of 127.0.0.1:26657
# for incoming connections (this is only good for a development node or one where tendermint is running in docker)
nameserviced init new_node -o


# the following commands assume the nameservicecli and the namserviced are in your $PATH

# add a few users to the chain:
nameservicecli keys add jack
nameservicecli keys add alice

# add them to the genesis file
nameserviced add-genesis-account $(nameservicecli keys show jack -a) 1000nametoken,100000000stake
nameserviced add-genesis-account $(nameservicecli keys show alice -a) 1000nametoken,100000000stake


# run a single tendermint node
docker run -it --rm --platform linux/amd64 -v "~/.nameserviced:/tendermint" -p "26656-26657:26656-26657"  tendermint/tendermint:v0.34.0 node --proxy_app="tcp://host.docker.internal:26658"

# start the nameserviced
swift run nameserviced start --host 0.0.0.0

# now you can start sending requests to the nameserviced using the nameservicecli

nameservicecli query account $(nameservicecli keys show jack -a) | jq ".value.coins[0]"

# Buy your first name using your coins from the genesis file
nameservicecli tx nameservice buy-name jack.id 5nametoken --from jack -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli query tx

# Set the value for the name you just bought
nameservicecli tx nameservice set-name jack.id 8.8.8.8 --from jack -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli q tx

# Try out a resolve query against the name you registered
nameservicecli query nameservice resolve jack.id | jq ".value"
> 8.8.8.8

# Try out a whois query against the name you just registered
nameservicecli query nameservice get-whois jack.id
> {"value":"8.8.8.8","owner":"cosmos1l7k5tdt2qam0zecxrx78yuw447ga54dsmtpk2s","price":[{"denom":"nametoken","amount":"5"}]}

# Alice buys name from jack
nameservicecli tx nameservice buy-name jack.id 10nametoken --from alice -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli q tx

# Alice decides to delete the name she just bought from jack
nameservicecli tx nameservice delete-name jack.id --from alice -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli q tx

# Try out a whois query against the name you just deleted
nameservicecli query nameservice get-whois jack.id
> {"value":"","owner":"","price":[{"denom":"nametoken","amount":"1"}]}
```

## Development

Compile:

1. run `swift build` or spawn XCode `xed .` from the root of the cloned directory.

2. Initialize a Tendermint chain node and the nameserviced as explained above

3. In the cloned directory, if you need to reset the height of a chain:
```sh
#! /bin/sh
NAMESERVICED_ROOT=~/.nameserviced
OLD_PWD=`pwd`
cd $NAMESERVICED_ROOT
(cd $NAMESERVICED_ROOT/config; rm write-file-atomic-*)
(cd $NAMESERVICED_ROOT/data; rm -Rf *)
echo { \
  \"height\": \"0\", \
  \"round\": 0, \
  \"step\": 0 \
} > $NAMESERVICED_ROOT/config/priv_validator_state.json
cd $OLD_PWD
```


## Documentation

The docs for the latest tagged release are always available at the [wiki](https://github.com/CosmosSwift/swift-coin/wiki).

## Questions

For bugs or feature requests, file a new [issue](https://github.com/cosmosswift/swift-coin/issues).

For all other support requests, please email [opensource@katalysis.io](mailto:opensource@katalysis.io).

## Changelog

[SemVer](https://semver.org/) changes are documented for each release on the [releases page](https://github.com/cosmosswift/swift-coin/-/releases).

## Contributing

Since the software is still under heavy development, our current focus is first and foremost to reach parity with version 0.39.1 of the Cosmos SDK. In the meantime, we still welcome any contribution, however, we apologize in advance if we are slow to respond.

Should you want contribute, check out [CONTRIBUTING.md](https://github.com/cosmosswift/swift-coin/blob/master/CONTRIBUTING.md) for more information on how to help with **swift-coin**.

## Contributors

Check out [CONTRIBUTORS.txt](https://github.com/cosmosswift/swift-coin/blob/master/CONTRIBUTORS.txt) to see the full list. This list is updated for each release.
