# swift-coin / nameservice [ALPHA]

![Swift5.3+](https://img.shields.io/badge/Swift-5.3+-blue.svg)
![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20linux-orange.svg)

Build blockchain applications in Swift on top of the Tendermint consensus using [SwiftNIO](https://github.com/apple/swift-nio) as the server core.

This project shows the work in progress for the port of the [Cosmos SDK](https://github.com/cosmos/cosmos-sdk) to Swift. It is based on version [0.39.1](https://github.com/cosmos/cosmos-sdk/tree/v0.39.1) of the SDK.

To make the porting more exciting, we have chosen to use the [nameservice](https://github.com/cosmos/sdk-tutorials/tree/master/nameservice) to implement the various necessary libraries for the sdk.




## Work in progress
This is work in progress. What we currrently have is the following:

| Module/App  |  milestone  |  completion  |  notes
|:-----------| :-------:|:---------:|:-------
| Framework  |  2   | ✔️ |   Framework mimics the CosmosSDK framework, including the directory structure.
| Store  (ex integration with stand alone iAVLP) |  2   | ✔️ |  Currently in memory.
| Bech32  |  2   | ✔️    |
| Auth |  2   | ✔️    | Staking, Governance, Bank requirements in progress (see respective Modules)
| Params  |  2 |   ✔️|    
| Nameservice | unplanned | 70%| Allows us to test modules.
| GenUtils | |  80%|
| Supply  |  3  |  50%  |  
| Governance  |  3  |  0% |   
| Staking  |  3   | 50%    |
| Simulation  |   3  |  50%|    
| Bank  |  3 |   70% |   
| IBC| 3 | 0% |



## Requirements
- Swift version: 5.3.x
- SwiftNIO version: 2.0.x
- ABCI version: 0.33.9 (tendermint 0.33.9)

## Installation

Requires macOS or a variant of Linux with the Swift 5.3.x toolchain installed.

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

1. run `swift build` or spawn XCode `xed .` from the root of the cloned directory.

2. Initialize a Tendermint chain node and the nameserviced as explained above

3. Run the [Go nameservicecli](https://github.com/cosmos/sdk-tutorials/tree/master/nameservice/nameservice) to drive the Swift `nameserviced`
```bash
rm -rf ~/.nameserviced
rm -rf ~/.nameservicecli

# Swift nameserviced
nameserviced init test --chain-id=namechain

# Go nameservicecli
nameservicecli config output json
nameservicecli config indent true
nameservicecli config trust-node true
nameservicecli config chain-id namechain
nameservicecli config keyring-backend test

nameservicecli keys add user1
nameservicecli keys add user2

# Swift nameserviced
nameserviced add-genesis-account $(nameservicecli keys show user1 -a) 1000nametoken,100000000stake
nameserviced add-genesis-account $(nameservicecli keys show user2 -a) 1000nametoken,100000000stake

# Not implemented
# nameserviced gentx --name user1 --keyring-backend test

echo "Collecting genesis txs..."
# Not implemented
# nameserviced collect-gentxs

echo "Validating genesis file..."
# Not implemented
# nameserviced validate-genesis
```
Then:
```bash
nameservicecli query account $(nameservicecli keys show jack -a) | jq ".value.coins[0]"
nameservicecli query account $(nameservicecli keys show alice -a) | jq ".value.coins[0]"

# Below messages are not fully working at this stage

# Buy your first name using your coins from the genesis file
# nameservicecli tx nameservice buy-name jack.id 5nametoken --from jack -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli q tx

# Set the value for the name you just bought
# nameservicecli tx nameservice set-name jack.id 8.8.8.8 --from jack -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli q tx

# Try out a resolve query against the name you registered
# nameservicecli query nameservice resolve jack.id | jq ".value"
# > 8.8.8.8

# Try out a whois query against the name you just registered
# nameservicecli query nameservice get-whois jack.id
# > {"value":"8.8.8.8","owner":"cosmos1l7k5tdt2qam0zecxrx78yuw447ga54dsmtpk2s","price":[{"denom":"nametoken","amount":"5"}]}

# Alice buys name from jack
# nameservicecli tx nameservice buy-name jack.id 10nametoken --from alice -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli q tx

# Alice decides to delete the name she just bought from jack
# nameservicecli tx nameservice delete-name jack.id --from alice -y | jq ".txhash" |  xargs $(sleep 6) nameservicecli q tx

# Try out a whois query against the name you just deleted
# nameservicecli query nameservice get-whois jack.id
# > {"value":"","owner":"","price":[{"denom":"nametoken","amount":"1"}]}

```


## Documentation

The docs for the latest tagged release are always available at the [wiki](https://github.com/CosmosSwift/swift-coin/wiki).

## Questions

For bugs or feature requests, file a new [issue](https://github.com/cosmosswift/swift-coin/issues).

For all other support requests, please email [opensource@katalysis.io](mailto:opensource@katalysis.io).

## Changelog

[SemVer](https://semver.org/) changes are documented for each release on the [releases page](https://github.com/cosmosswift/swift-coin/-/releases).

## Contributing

Check out [CONTRIBUTING.md](https://github.com/cosmosswift/swift-coin/blob/master/CONTRIBUTING.md) for more information on how to help with **swift-coin**.

## Contributors

Check out [CONTRIBUTORS.txt](https://github.com/cosmosswift/swift-coin/blob/master/CONTRIBUTORS.txt) to see the full list. This list is updated for each release.
