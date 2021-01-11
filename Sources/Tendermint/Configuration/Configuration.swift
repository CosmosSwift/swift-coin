import Foundation

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
    let rpc: RPCConfiguration
    let p2p: P2PConfiguration
    let memoryPool: MemoryPoolConfiguration
    let fastSync: FastSyncConfiguration
    let consensus: ConsensusConfiguration
    let transactionIndex: TransactionIndexConfiguration
    let instrumentation: InstrumentationConfiguration
}
    
extension Configuration {
    // DefaultConfig returns a default configuration for a Tendermint node
    public static var `default`: Configuration {
        return Configuration(
            base: .default,
            rpc: .default,
            p2p: .default,
            memoryPool: .default,
            fastSync: .default,
            consensus: .default,
            transactionIndex: .default,
            instrumentation: .default
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
    static let defaultAddressBookPath = defaultConfigurationDirectory + "/" + defaultAddressBookName

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
// RPCConfig

// RPCConfig defines the configuration options for the Tendermint RPC server
struct RPCConfiguration: Codable {
    let rootDirectory: String

    // TCP or UNIX socket address for the RPC server to listen on
    let listenAddress: String
    
    // A list of origins a cross-domain request can be executed from.
    // If the special '*' value is present in the list, all origins will be allowed.
    // An origin may contain a wildcard (*) to replace 0 or more characters (i.e.: http://*.domain.com).
    // Only one wildcard can be used per origin.
    let corsAllowedOrigins: [String]
    
    // A list of methods the client is allowed to use with cross-domain requests.
    let corsAllowedMethods: [String]
    
    // A list of non simple headers the client is allowed to use with cross-domain requests.
    let corsAllowedHeaders: [String]

    // TCP or UNIX socket address for the gRPC server to listen on
    // NOTE: This server only supports /broadcast_tx_commit
    let grpcListenAddress: String

    // Maximum number of simultaneous connections.
    // Does not include RPC (HTTP&WebSocket) connections. See max_open_connections
    // If you want to accept a larger number than the default, make sure
    // you increase your OS limits.
    // 0 - unlimited.
    let grpcMaximumOpenConnections: Int

    // Activate unsafe RPC commands like /dial_persistent_peers and /unsafe_flush_mempool
    let unsafe: Bool

    // Maximum number of simultaneous connections (including WebSocket).
    // Does not include gRPC connections. See grpc_max_open_connections
    // If you want to accept a larger number than the default, make sure
    // you increase your OS limits.
    // 0 - unlimited.
    // Should be < {ulimit -Sn} - {MaxNumInboundPeers} - {MaxNumOutboundPeers} - {N of wal, db and other open files}
    // 1024 - 40 - 10 - 50 = 924 = ~900
    let maximumOpenConnections: Int

    // Maximum number of unique clientIDs that can /subscribe
    // If you're using /broadcast_tx_commit, set to the estimated maximum number
    // of broadcast_tx_commit calls per block.
    let maximumSubscriptionClients: Int

    // Maximum number of unique queries a given client can /subscribe to
    // If you're using GRPC (or Local RPC client) and /broadcast_tx_commit, set
    // to the estimated maximum number of broadcast_tx_commit calls per block.
    let maximumSubscriptionsPerClient: Int

    // How long to wait for a tx to be committed during /broadcast_tx_commit
    // WARNING: Using a value larger than 10s will result in increasing the
    // global HTTP write timeout, which applies to all connections and endpoints.
    // See https://github.com/tendermint/tendermint/issues/3435
    let timeoutBroadcastTransactionCommit: Time

    // Maximum size of request body, in bytes
    let maximumBodyBytes: Int64

    // Maximum size of request header, in bytes
    let maximumHeaderBytes: Int

    // The path to a file containing certificate that is used to create the HTTPS server.
    // Migth be either absolute path or path related to tendermint's config directory.
    //
    // If the certificate is signed by a certificate authority,
    // the certFile should be the concatenation of the server's certificate, any intermediates,
    // and the CA's certificate.
    //
    // NOTE: both tls_cert_file and tls_key_file must be present for Tendermint to create HTTPS server.
    // Otherwise, HTTP server is run.
    let tlsCertificateFile: String

    // The path to a file containing matching private key that is used to create the HTTPS server.
    // Migth be either absolute path or path related to tendermint's config directory.
    //
    // NOTE: both tls_cert_file and tls_key_file must be present for Tendermint to create HTTPS server.
    // Otherwise, HTTP server is run.
    let tlsKeyFile: String
   
    private enum CodingKeys: String, CodingKey {
        case rootDirectory = "home"
        case listenAddress = "laddr"
        case corsAllowedOrigins = "cors_allowed_origins"
        case corsAllowedMethods = "cors_allowed_methods"
        case corsAllowedHeaders = "cors_allowed_headers"
        case grpcListenAddress = "grpc_laddr"
        case grpcMaximumOpenConnections = "grpc_max_open_connections"
        case unsafe
        case maximumOpenConnections = "max_open_connections"
        case maximumSubscriptionClients = "max_subscription_clients"
        case maximumSubscriptionsPerClient = "max_subscriptions_per_client"
        case timeoutBroadcastTransactionCommit = "timeout_broadcast_tx_commit"
        case maximumBodyBytes = "max_body_bytes"
        case maximumHeaderBytes = "max_header_bytes"
        case tlsCertificateFile = "tls_cert_file"
        case tlsKeyFile = "tls_key_file"
    }
}

extension RPCConfiguration {
    // DefaultRPCConfig returns a default configuration for the RPC server
    static var `default`: RPCConfiguration {
        RPCConfiguration(
            rootDirectory: "",
            listenAddress: "tcp://0.0.0.0:26657", // instead of "tcp://127.0.0.1:26657" for usage in docker
            corsAllowedOrigins: [],
            corsAllowedMethods: ["HEAD", "GET", "POST"],
            corsAllowedHeaders: ["Origin", "Accept", "Content-Type", "X-Requested-With", "X-Server-Time"],
            grpcListenAddress: "",
            grpcMaximumOpenConnections: 900,
            unsafe: false,
            maximumOpenConnections: 900,
            maximumSubscriptionClients: 100,
            maximumSubscriptionsPerClient: 5,
            timeoutBroadcastTransactionCommit: .second(10),
            maximumBodyBytes: 1000000, // 1MB
            maximumHeaderBytes: 1 << 20, // same as the net/http default
            tlsCertificateFile: "",
            tlsKeyFile: ""
        )
    }
}

//-----------------------------------------------------------------------------
// P2PConfig

// P2PConfig defines the configuration options for the Tendermint peer-to-peer networking layer
struct P2PConfiguration: Codable {
    let rootDirectory: String

    // Address to listen for incoming connections
    let listenAddress: String
    
    // Address to advertise to peers for them to dial
    let externalAddress: String

    // Comma separated list of seed nodes to connect to
    // We only use these if we can’t connect to peers in the addrbook
    let seeds: String

    // Comma separated list of nodes to keep persistent connections to
    let persistentPeers: String

    // UPNP port forwarding
    let upnp: Bool

    // Path to address book
    let addressBook: String

    // Set true for strict address routability rules
    // Set false for private or local networks
    let addressBookStrict: Bool

    // Maximum number of inbound peers
    let maximumNumberOfInboundPeers: Int

    // Maximum number of outbound peers to connect to, excluding persistent peers
    let maximumNumberOfOutboundPeers: Int

    // List of node IDs, to which a connection will be (re)established ignoring any existing limits
    let unconditionalPeerIDs: String

    // Maximum pause when redialing a persistent peer (if zero, exponential backoff is used)
    let persistentPeersMaximumDialPeriod: Time

    // Time to wait before flushing messages out on the connection
    let flushThrottleTimeout: Time

    // Maximum size of a message packet payload, in bytes
    let maximumPacketMessagePayloadSize: Int

    // Rate at which packets can be sent, in bytes/second
    let sendRate: Int64

    // Rate at which packets can be received, in bytes/second
    let receiveRate: Int64

    // Set true to enable the peer-exchange reactor
    let peerExchangeReactor: Bool

    // Seed mode, in which node constantly crawls the network and looks for
    // peers. If another node asks it for addresses, it responds and disconnects.
    //
    // Does not work if the peer-exchange reactor is disabled.
    let seedMode: Bool

    // Comma separated list of peer IDs to keep private (will not be gossiped to
    // other peers)
    let privatePeerIDs: String

    // Toggle to disable guard against peers connecting from the same ip.
    let allowDuplicateIP: Bool

    // Peer connection configuration.
    let handshakeTimeout: Time
    let dialTimeout: Time

    // Testing params.
    // Force dial to fail
    let testDialFail: Bool
    // FUzz connection
    let testFuzz: Bool
    let testFuzzConfiguration: FuzzConnectionConfiguration
    
    private enum CodingKeys: String, CodingKey {
        case rootDirectory = "home"
        case listenAddress = "laddr"
        case externalAddress = "external_address"
        case seeds
        case persistentPeers = "persistent_peers"
        case upnp = "upnp"
        case addressBook = "addr_book_file"
        case addressBookStrict = "addr_book_strict"
        case maximumNumberOfInboundPeers = "max_num_inbound_peers"
        case maximumNumberOfOutboundPeers = "max_num_outbound_peers"
        case unconditionalPeerIDs = "unconditional_peer_ids"
        case persistentPeersMaximumDialPeriod = "persistent_peers_max_dial_period"
        case flushThrottleTimeout = "flush_throttle_timeout"
        case maximumPacketMessagePayloadSize = "max_packet_msg_payload_size"
        case sendRate = "send_rate"
        case receiveRate = "recv_rate"
        case peerExchangeReactor = "pex"
        case seedMode = "seed_mode"
        case privatePeerIDs = "private_peer_ids"
        case allowDuplicateIP = "allow_duplicate_ip"
        case handshakeTimeout = "handshake_timeout"
        case dialTimeout = "dial_timeout"
        case testDialFail = "test_dial_fail"
        case testFuzz = "test_fuzz"
        case testFuzzConfiguration = "test_fuzz_config"
    }
}

extension P2PConfiguration {
    // DefaultP2PConfig returns a default configuration for the peer-to-peer layer
    static var `default`: P2PConfiguration {
        P2PConfiguration(
            rootDirectory: "",
            listenAddress: "tcp://0.0.0.0:26656",
            externalAddress: "",
            seeds: "",
            persistentPeers: "",
            upnp: false,
            addressBook: BaseConfiguration.defaultAddressBookPath,
            addressBookStrict: true,
            maximumNumberOfInboundPeers: 40,
            maximumNumberOfOutboundPeers: 10,
            unconditionalPeerIDs: "",
            persistentPeersMaximumDialPeriod: .second(0),
            flushThrottleTimeout: .milliSecond(100),
            maximumPacketMessagePayloadSize: 1024, // 1 kB
            sendRate: 5120000, // 5 mB/s
            receiveRate: 5120000, // 5 mB/s
            peerExchangeReactor: true,
            seedMode: false,
            privatePeerIDs: "",
            allowDuplicateIP: false,
            handshakeTimeout: .second(20),
            dialTimeout: .second(3),
            testDialFail: false,
            testFuzz: false,
            testFuzzConfiguration: .default
        )
        
    }

}

// FuzzConnConfig is a FuzzedConnection configuration.
struct FuzzConnectionConfiguration: Codable {
    enum Mode: Int, Codable, CustomStringConvertible {
        // FuzzModeDrop is a mode in which we randomly drop reads/writes, connections or sleep
        case drop
        // FuzzModeDelay is a mode in which we randomly sleep
        case delay
        
        var description: String {
            "\(self.rawValue)"
        }
    }

    let mode: Mode
    let maximumDelay: Time
    let probabilityDropRW: Float64
    let probabilityDropConnection: Float64
    let probabilitySleep: Float64
}

extension FuzzConnectionConfiguration {
    // DefaultFuzzConnConfig returns the default config.
    static var `default`: FuzzConnectionConfiguration {
        FuzzConnectionConfiguration(
            mode: .drop,
            maximumDelay: .second(3),
            probabilityDropRW: 0.2,
            probabilityDropConnection: 0,
            probabilitySleep: 0
        )
    }
}

//-----------------------------------------------------------------------------
// MempoolConfig

// MempoolConfig defines the configuration options for the Tendermint mempool
struct MemoryPoolConfiguration: Codable {
    let rootDirectory: String
    let recheck: Bool
    let broadcast: Bool
    let walPath: String
    let size: Int
    let maximumTransactionsBytes: Int64
    let cacheSize: Int
    let maximumTransactionBytes: Int
    
    private enum CodingKeys: String, CodingKey {
        case rootDirectory = "home"
        case recheck
        case broadcast
        case walPath = "wal_dir"
        case size
        case maximumTransactionsBytes = "max_txs_bytes"
        case cacheSize = "cache_size"
        case maximumTransactionBytes = "max_tx_bytes"
    }
}

extension MemoryPoolConfiguration {
    // DefaultMempoolConfig returns a default configuration for the Tendermint mempool
    static var `default`: MemoryPoolConfiguration {
        MemoryPoolConfiguration(
            rootDirectory: "",
            recheck: true,
            broadcast: true,
            walPath: "",
            // Each signature verification takes .5ms, Size reduced until we implement
            // ABCI Recheck
            size: 5000,
            maximumTransactionsBytes: 1024 * 1024 * 1024, // 1GB
            cacheSize: 10000,
            maximumTransactionBytes: 1024 * 1024 // 1MB
        )
    }
}

//-----------------------------------------------------------------------------
// FastSyncConfig

// FastSyncConfig defines the configuration for the Tendermint fast sync service
struct FastSyncConfiguration: Codable {
    let version: String
}

extension FastSyncConfiguration {
    // DefaultFastSyncConfig returns a default configuration for the fast sync service
    static var `default`: FastSyncConfiguration {
        FastSyncConfiguration(version: "v0")
    }
}

//-----------------------------------------------------------------------------
// ConsensusConfig

// ConsensusConfig defines the configuration for the Tendermint consensus service,
// including timeouts and details about the WAL and the block structure.
struct ConsensusConfiguration: Codable {
    let rootDirectory: String
    let walPath: String
    var walFile: String? = nil // overrides WalPath if set
    
    let timeoutPropose: Time
    let timeoutProposeDelta: Time
    let timeoutPrevote: Time
    let timeoutPrevoteDelta: Time
    let timeoutPrecommit: Time
    let timeoutPrecommitDelta: Time
    let timeoutCommit: Time

    // Make progress as soon as we have all the precommits (as if TimeoutCommit = 0)
    let skipTimeoutCommit: Bool

    // EmptyBlocks mode and possible interval between empty blocks
    let createEmptyBlocks: Bool
    let createEmptyBlocksInterval: Time

    // Reactor sleep duration parameters
    let peerGossipSleepDuration: Time
    let peerQueryMaj23SleepDuration: Time
    
    private enum CodingKeys: String, CodingKey {
        case rootDirectory = "home"
        case walPath = "wal_file"
        case timeoutPropose = "timeout_propose"
        case timeoutProposeDelta = "timeout_propose_delta"
        case timeoutPrevote = "timeout_prevote"
        case timeoutPrevoteDelta = "timeout_prevote_delta"
        case timeoutPrecommit = "timeout_precommit"
        case timeoutPrecommitDelta = "timeout_precommit_delta"
        case timeoutCommit = "timeout_commit"
        case skipTimeoutCommit = "skip_timeout_commit"
        case createEmptyBlocks = "create_empty_blocks"
        case createEmptyBlocksInterval = "create_empty_blocks_interval"
        case peerGossipSleepDuration = "peer_gossip_sleep_duration"
        case peerQueryMaj23SleepDuration = "peer_query_maj23_sleep_duration"
    }
}

extension ConsensusConfiguration {
    // DefaultConsensusConfig returns a default configuration for the consensus service
    static var `default`: ConsensusConfiguration {
        ConsensusConfiguration(
            rootDirectory: "",
            walPath: BaseConfiguration.defaultDataDirectory + "/cs.wal/wal",
            timeoutPropose: .milliSecond(3000),
            timeoutProposeDelta: .milliSecond(500),
            timeoutPrevote: .milliSecond(1000),
            timeoutPrevoteDelta: .milliSecond(500),
            timeoutPrecommit: .milliSecond(1000),
            timeoutPrecommitDelta: .milliSecond(500),
            timeoutCommit: .milliSecond(1000),
            skipTimeoutCommit: false,
            createEmptyBlocks: true,
            createEmptyBlocksInterval: .second(0),
            peerGossipSleepDuration: .milliSecond(100),
            peerQueryMaj23SleepDuration: .milliSecond(2000)
        )
    }
}

//-----------------------------------------------------------------------------
// TxIndexConfig
// Remember that Event has the following structure:
// type: [
//  key: value,
//  ...
// ]
//
// CompositeKeys are constructed by `type.key`
// TxIndexConfig defines the configuration for the transaction indexer,
// including composite keys to index.
struct TransactionIndexConfiguration: Codable {
    // What indexer to use for transactions
    //
    // Options:
    //   1) "null"
    //   2) "kv" (default) - the simplest possible indexer,
    //      backed by key-value storage (defaults to levelDB; see DBBackend).
    let indexer: String

    // Comma-separated list of compositeKeys to index (by default the only key is "tx.hash")
    //
    // You can also index transactions by height by adding "tx.height" key here.
    //
    // It's recommended to index only a subset of keys due to possible memory
    // bloat. This is, of course, depends on the indexer's DB and the volume of
    // transactions.
    let indexKeys: String

    // When set to true, tells indexer to index all compositeKeys (predefined keys:
    // "tx.hash", "tx.height" and all keys from DeliverTx responses).
    //
    // Note this may be not desirable (see the comment above). IndexKeys has a
    // precedence over IndexAllKeys (i.e. when given both, IndexKeys will be
    // indexed).
    let indexAllKeys: Bool
    
    private enum CodingKeys: String, CodingKey {
        case indexer
        case indexKeys = "index_keys"
        case indexAllKeys = "index_all_keys"
    }
}

extension TransactionIndexConfiguration {
    // DefaultTxIndexConfig returns a default configuration for the transaction indexer.
    static var `default`: TransactionIndexConfiguration {
        TransactionIndexConfiguration(
            indexer: "kv",
            indexKeys: "",
            indexAllKeys: false
        )
    }
}

//-----------------------------------------------------------------------------
// InstrumentationConfig

// InstrumentationConfig defines the configuration for metrics reporting.
struct InstrumentationConfiguration: Codable {
    // When true, Prometheus metrics are served under /metrics on
    // PrometheusListenAddr.
    // Check out the documentation for the list of available metrics.
    let prometheus: Bool

    // Address to listen for Prometheus collector(s) connections.
    let prometheusListenAddress: String

    // Maximum number of simultaneous connections.
    // If you want to accept a larger number than the default, make sure
    // you increase your OS limits.
    // 0 - unlimited.
    let maximumOpenConnections: Int

    // Instrumentation namespace.
    let namespace: String
    
    private enum CodingKeys: String, CodingKey {
        case prometheus
        case prometheusListenAddress = "prometheus_listen_addr"
        case maximumOpenConnections = "max_open_connections"
        case namespace
    }
}

extension InstrumentationConfiguration {
    // DefaultInstrumentationConfig returns a default configuration for metrics
    // reporting.
    static var `default`: InstrumentationConfiguration {
        InstrumentationConfiguration(
            prometheus: false,
            prometheusListenAddress: ":26660",
            maximumOpenConnections: 3,
            namespace: "tendermint"
        )
    }
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
