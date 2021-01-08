enum LogFormat: String, Codable {
    // LogFormatPlain is a format for colored text
    case plain
    // LogFormatJSON is a format for json output
    case json
}

// Config defines the top level configuration for a Tendermint node
public struct Configuration: Codable {
    // Top level options use an anonymous struct
    var base: BaseConfiguration

    // Options for services
//    let rpc: RPCConfig
//    let p2p: P2PConfig
//    let mempool: MempoolConfig
//    let fastSync: FastSyncConfig
//    let consensus: ConsensusConfig
//    let txIndex: TxIndexConfig
//    let instrumentation: InstrumentationConfig
}
    
extension Configuration {
    // DefaultConfig returns a default configuration for a Tendermint node
    public static var `default`: Configuration {
        return Configuration(
            base: .default
//            RPC:             DefaultRPCConfig(),
//            P2P:             DefaultP2PConfig(),
//            Mempool:         DefaultMempoolConfig(),
//            FastSync:        DefaultFastSyncConfig(),
//            Consensus:       DefaultConsensusConfig(),
//            TxIndex:         DefaultTxIndexConfig(),
//            Instrumentation: DefaultInstrumentationConfig(),
        )
    }
}

extension Configuration {
    public var rootDirectory: String {
        get {
            base.rootDirectory
        }
        set {
            base.rootDirectory = newValue
        }
    }
    
    public var moniker: String {
        get {
            base.moniker
        }
        set {
            base.moniker = newValue
        }
    }
}

extension Configuration {
    // SetRoot sets the RootDir for all Config structs
    public mutating func set(rootDirectory: String) {
        base.rootDirectory = rootDirectory
//        rpc.rootDirectory = rootDirectory
//        p2p.rootDirectory = rootDirectory
//        mempool.rootDirectory = rootDirectory
//        consensus.rootDirectory = rootDirectory
    }
    
    // GenesisFile returns the full path to the genesis.json file
    public var genesisFilePath: String {
        rootify(path: base.genesis, root: base.rootDirectory)
    }
    
    // PrivValidatorKeyFile returns the full path to the priv_validator_key.json file
    public var privateValidatorKeyFile: String {
        rootify(path: base.privateValidatorKey, root: base.rootDirectory)
    }

    // PrivValidatorFile returns the full path to the priv_validator_state.json file
    public var privateValidatorStateFile: String {
        rootify(path: base.privateValidatorState, root: base.rootDirectory)
    }

    // NodeKeyFile returns the full path to the node_key.json file
    public var nodeKeyFilePath: String {
        rootify(path: base.nodeKey, root: base.rootDirectory)
    }
}

//-----------------------------------------------------------------------------
// BaseConfig
//
// BaseConfig defines the base configuration for a Tendermint node
struct BaseConfiguration: Codable {
    // chainID is unexposed and immutable but here for convenience
    var chainID: String? = nil

    // The root directory for all data.
    // This should be set in viper so it can unmarshal into this struct
    public var rootDirectory: String

    // TCP or UNIX socket address of the ABCI application,
    // or the name of an ABCI application compiled in with the Tendermint binary
    var proxyApp: String

    // A custom human readable name for this node
    public var moniker: String

    // If this node is many blocks behind the tip of the chain, FastSync
    // allows them to catchup quickly by downloading blocks in parallel
    // and verifying their commits
    var fastSyncMode: Bool

    // Database backend: goleveldb | cleveldb | boltdb | rocksdb
    // * goleveldb (github.com/syndtr/goleveldb - most popular implementation)
    //   - pure go
    //   - stable
    // * cleveldb (uses levigo wrapper)
    //   - fast
    //   - requires gcc
    //   - use cleveldb build tag (go build -tags cleveldb)
    // * boltdb (uses etcd's fork of bolt - github.com/etcd-io/bbolt)
    //   - EXPERIMENTAL
    //   - may be faster is some use-cases (random reads - indexer)
    //   - use boltdb build tag (go build -tags boltdb)
    // * rocksdb (uses github.com/tecbot/gorocksdb)
    //   - EXPERIMENTAL
    //   - requires gcc
    //   - use rocksdb build tag (go build -tags rocksdb)
    var databaseBackend: String

    // Database directory
    var databasePath: String

    // Output level for logging
    var logLevel: String

    // Output format: 'plain' (colored text) or 'json'
    var logFormat: LogFormat

    // Path to the JSON file containing the initial validator set and other meta data
    var genesis: String

    // Path to the JSON file containing the private key to use as a validator in the consensus protocol
    var privateValidatorKey: String

    // Path to the JSON file containing the last sign state of a validator
    var privateValidatorState: String

    // TCP or UNIX socket address for Tendermint to listen on for
    // connections from an external PrivValidator process
    var privateValidatorListenAddress: String

    // A JSON file containing the private key to use for p2p authenticated encryption
    let nodeKey: String

    // Mechanism to connect to the ABCI application: socket | grpc
    let abci: String

    // TCP or UNIX socket address for the profiling server to listen on
    let profilingListenAddress: String

    // If true, query the ABCI app on connecting to a new peer
    // so the app can decide if we should keep the connection or not
    let filterPeers: Bool // false
    
    private enum CodingKeys: String, CodingKey {
        case rootDirectory = "home"
        case proxyApp = "proxy_app"
        case moniker
        case fastSyncMode = "fast_sync"
        case databaseBackend = "db_backend"
        case databasePath = "db_dir"
        case logLevel = "log_level"
        case logFormat = "log_format"
        case genesis = "genesis_file"
        case nodeKey = "node_key_file"
        case privateValidatorKey = "priv_validator_key_file"
        case privateValidatorState = "priv_validator_state_file"
        case privateValidatorListenAddress = "priv_validator_laddr"
        case abci
        case profilingListenAddress = "prof_laddr"
        case filterPeers = "filter_peers"
    }
}

extension BaseConfiguration {
    // NOTE: Most of the structs & relevant comments + the
    // default configuration options were used to manually
    // generate the config.toml. Please reflect any changes
    // made here in the defaultConfigTemplate constant in
    // config/toml.go
    // NOTE: libs/cli must know to look in the config dir!
    static let defaultTendermintDirectory = ".tendermint"
    static let defaultConfigurationDirectory = "config"
    static let defaultDataDirectory = "data"

    static let defaultConfigurationFileName = "config.toml"
    static let defaultGenesisJSONName = "genesis.json"

    static let defaultPrivateValidatorKeyName = "priv_validator_key.json"
    static let defaultPrivateValidatorStateName = "priv_validator_state.json"

    static let defaultNodeKeyName = "node_key.json"
    static let defaultAddressBookName = "addrbook.json"

    static let defaultConfigurationFilePath = defaultConfigurationDirectory + "/" + defaultConfigurationFileName
    static let defaultGenesisJSONPath = defaultConfigurationDirectory + "/" + defaultGenesisJSONName
    static let defaultPrivateValidatorKeyPath = defaultConfigurationDirectory + "/" + defaultPrivateValidatorKeyName
    static let defaultPrivateValidatorStatePath = defaultConfigurationDirectory + "/" + defaultPrivateValidatorStateName

    static let defaultNodeKeyPath = defaultConfigurationDirectory + "/" + defaultNodeKeyName
    static let defaultAddrBookPath = defaultConfigurationDirectory + "/" + defaultAddressBookName

    // DefaultBaseConfig returns a default base configuration for a Tendermint node
    static var `default`: BaseConfiguration {
        BaseConfiguration(
            chainID: nil,
            rootDirectory: "",
            proxyApp: "tcp://127.0.0.1:26658",
            moniker: "",
            fastSyncMode: true,
            databaseBackend: "goleveldb",
            databasePath: "data",
            logLevel: defaultPackageLogLevels,
            logFormat: .plain,
            genesis: defaultGenesisJSONPath,
            privateValidatorKey: defaultPrivateValidatorKeyPath,
            privateValidatorState: defaultPrivateValidatorStatePath,
            privateValidatorListenAddress: "",
            nodeKey: defaultNodeKeyPath,
            abci: "socket",
            profilingListenAddress: "",
            filterPeers: false
        )
    }
}

extension BaseConfiguration {
    // DefaultLogLevel returns a default log level of "error"
    static let defaultLogLevel = "error"

    // DefaultPackageLogLevels returns a default log level setting so all packages
    // log at "error", while the `state` and `main` packages log at "info"
    static let defaultPackageLogLevels = "main:info,state:info,*:\(defaultLogLevel)"
}


//-----------------------------------------------------------------------------
// Utils

// helper function to make config creation independent of root dir
fileprivate func rootify(path: String, root: String) -> String {
    if path.hasPrefix("/") {
        return path
    }
    
    return root + "/" + path
}
