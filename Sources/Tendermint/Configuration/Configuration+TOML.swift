import Foundation

extension Configuration {
    // Note: any changes to the comments/variables/mapstructure
    // must be reflected in the appropriate struct in config/config.go
    var defaultConfigurationTemplate: String {
        """
        # This is a TOML config file.
        # For more information, see https://github.com/toml-lang/toml

        # NOTE: Any path below can be absolute (e.g. "/var/myawesomeapp/data") or
        # relative to the home directory (e.g. "data"). The home directory is
        # "$HOME/.tendermint" by default, but could be changed via $TMHOME env variable
        # or --home cmd flag.

        ##### main base config options #####

        # TCP or UNIX socket address of the ABCI application,
        # or the name of an ABCI application compiled in with the Tendermint binary
        proxy_app = "\(base.proxyApp)"

        # A custom human readable name for this node
        moniker = "\(base.moniker)"

        # If this node is many blocks behind the tip of the chain, FastSync
        # allows them to catchup quickly by downloading blocks in parallel
        # and verifying their commits
        fast_sync = \(base.fastSyncMode)

        # Database backend: goleveldb | cleveldb | boltdb | rocksdb
        # * goleveldb (github.com/syndtr/goleveldb - most popular implementation)
        #   - pure go
        #   - stable
        # * cleveldb (uses levigo wrapper)
        #   - fast
        #   - requires gcc
        #   - use cleveldb build tag (go build -tags cleveldb)
        # * boltdb (uses etcd's fork of bolt - github.com/etcd-io/bbolt)
        #   - EXPERIMENTAL
        #   - may be faster is some use-cases (random reads - indexer)
        #   - use boltdb build tag (go build -tags boltdb)
        # * rocksdb (uses github.com/tecbot/gorocksdb)
        #   - EXPERIMENTAL
        #   - requires gcc
        #   - use rocksdb build tag (go build -tags rocksdb)
        db_backend = "\(base.databaseBackend)"

        # Database directory
        db_dir = "\(base.databasePath)"

        # Output level for logging, including package level options
        log_level = "\(base.logLevel)"

        # Output format: 'plain' (colored text) or 'json'
        log_format = "\(base.logFormat)"

        ##### additional base config options #####

        # Path to the JSON file containing the initial validator set and other meta data
        genesis_file = "\(base.genesis).json"

        # Path to the JSON file containing the private key to use as a validator in the consensus protocol
        priv_validator_key_file = "\(base.privateValidatorKey).json"

        # Path to the JSON file containing the last sign state of a validator
        priv_validator_state_file = "\(base.privateValidatorState).json"

        # TCP or UNIX socket address for Tendermint to listen on for
        # connections from an external PrivValidator process
        priv_validator_laddr = "\(base.privateValidatorListenAddress)"

        # Path to the JSON file containing the private key to use for node authentication in the p2p protocol
        node_key_file = "\(base.nodeKey).json"

        # Mechanism to connect to the ABCI application: socket | grpc
        abci = "\(base.abci)"

        # TCP or UNIX socket address for the profiling server to listen on
        prof_laddr = "\(base.profilingListenAddress)"

        # If true, query the ABCI app on connecting to a new peer
        # so the app can decide if we should keep the connection or not
        filter_peers = \(base.filterPeers)

        ##### advanced configuration options #####

        ##### rpc server configuration options #####
        [rpc]

        # TCP or UNIX socket address for the RPC server to listen on
        laddr = "(RPC.ListenAddress)"

        # A list of origins a cross-domain request can be executed from
        # Default value '[]' disables cors support
        # Use '["*"]' to allow any origin
        cors_allowed_origins = [(range .RPC.CORSAllowedOrigins)(printf "%q, " .){{end}}]

        # A list of methods the client is allowed to use with cross-domain requests
        cors_allowed_methods = [(range .RPC.CORSAllowedMethods)(printf "%q, " .){{end}}]

        # A list of non simple headers the client is allowed to use with cross-domain requests
        cors_allowed_headers = [(range .RPC.CORSAllowedHeaders)(printf "%q, " .){{end}}]

        # TCP or UNIX socket address for the gRPC server to listen on
        # NOTE: This server only supports /broadcast_tx_commit
        grpc_laddr = "(RPC.GRPCListenAddress)"

        # Maximum number of simultaneous connections.
        # Does not include RPC (HTTP&WebSocket) connections. See max_open_connections
        # If you want to accept a larger number than the default, make sure
        # you increase your OS limits.
        # 0 - unlimited.
        # Should be < {ulimit -Sn} - {MaxNumInboundPeers} - {MaxNumOutboundPeers} - {N of wal, db and other open files}
        # 1024 - 40 - 10 - 50 = 924 = ~900
        grpc_max_open_connections = (RPC.GRPCMaxOpenConnections)

        # Activate unsafe RPC commands like /dial_seeds and /unsafe_flush_mempool
        unsafe = (RPC.Unsafe)

        # Maximum number of simultaneous connections (including WebSocket).
        # Does not include gRPC connections. See grpc_max_open_connections
        # If you want to accept a larger number than the default, make sure
        # you increase your OS limits.
        # 0 - unlimited.
        # Should be < {ulimit -Sn} - {MaxNumInboundPeers} - {MaxNumOutboundPeers} - {N of wal, db and other open files}
        # 1024 - 40 - 10 - 50 = 924 = ~900
        max_open_connections = (RPC.MaxOpenConnections)

        # Maximum number of unique clientIDs that can /subscribe
        # If you're using /broadcast_tx_commit, set to the estimated maximum number
        # of broadcast_tx_commit calls per block.
        max_subscription_clients = (RPC.MaxSubscriptionClients)

        # Maximum number of unique queries a given client can /subscribe to
        # If you're using GRPC (or Local RPC client) and /broadcast_tx_commit, set to
        # the estimated # maximum number of broadcast_tx_commit calls per block.
        max_subscriptions_per_client = (RPC.MaxSubscriptionsPerClient)

        # How long to wait for a tx to be committed during /broadcast_tx_commit.
        # WARNING: Using a value larger than 10s will result in increasing the
        # global HTTP write timeout, which applies to all connections and endpoints.
        # See https://github.com/tendermint/tendermint/issues/3435
        timeout_broadcast_tx_commit = "(RPC.TimeoutBroadcastTxCommit)"

        # Maximum size of request body, in bytes
        max_body_bytes = (RPC.MaxBodyBytes)

        # Maximum size of request header, in bytes
        max_header_bytes = (RPC.MaxHeaderBytes)

        # The path to a file containing certificate that is used to create the HTTPS server.
        # Migth be either absolute path or path related to tendermint's config directory.
        # If the certificate is signed by a certificate authority,
        # the certFile should be the concatenation of the server's certificate, any intermediates,
        # and the CA's certificate.
        # NOTE: both tls_cert_file and tls_key_file must be present for Tendermint to create HTTPS server.
        # Otherwise, HTTP server is run.
        tls_cert_file = "(RPC.TLSCertFile)"

        # The path to a file containing matching private key that is used to create the HTTPS server.
        # Migth be either absolute path or path related to tendermint's config directory.
        # NOTE: both tls_cert_file and tls_key_file must be present for Tendermint to create HTTPS server.
        # Otherwise, HTTP server is run.
        tls_key_file = "(RPC.TLSKeyFile)"

        ##### peer to peer configuration options #####
        [p2p]

        # Address to listen for incoming connections
        laddr = "(P2P.ListenAddress)"

        # Address to advertise to peers for them to dial
        # If empty, will use the same port as the laddr,
        # and will introspect on the listener or use UPnP
        # to figure out the address.
        external_address = "(P2P.ExternalAddress)"

        # Comma separated list of seed nodes to connect to
        seeds = "(P2P.Seeds)"

        # Comma separated list of nodes to keep persistent connections to
        persistent_peers = "(P2P.PersistentPeers)"

        # UPNP port forwarding
        upnp = (P2P.UPNP)

        # Path to address book
        addr_book_file = "(js .P2P.AddrBook)"

        # Set true for strict address routability rules
        # Set false for private or local networks
        addr_book_strict = (P2P.AddrBookStrict)

        # Maximum number of inbound peers
        max_num_inbound_peers = (P2P.MaxNumInboundPeers)

        # Maximum number of outbound peers to connect to, excluding persistent peers
        max_num_outbound_peers = (P2P.MaxNumOutboundPeers)

        # List of node IDs, to which a connection will be (re)established ignoring any existing limits
        unconditional_peer_ids = "(P2P.UnconditionalPeerIDs)"

        # Maximum pause when redialing a persistent peer (if zero, exponential backoff is used)
        persistent_peers_max_dial_period = "(P2P.PersistentPeersMaxDialPeriod)"

        # Time to wait before flushing messages out on the connection
        flush_throttle_timeout = "(P2P.FlushThrottleTimeout)"

        # Maximum size of a message packet payload, in bytes
        max_packet_msg_payload_size = (P2P.MaxPacketMsgPayloadSize)

        # Rate at which packets can be sent, in bytes/second
        send_rate = (P2P.SendRate)

        # Rate at which packets can be received, in bytes/second
        recv_rate = (P2P.RecvRate)

        # Set true to enable the peer-exchange reactor
        pex = (P2P.PexReactor)

        # Seed mode, in which node constantly crawls the network and looks for
        # peers. If another node asks it for addresses, it responds and disconnects.
        #
        # Does not work if the peer-exchange reactor is disabled.
        seed_mode = (P2P.SeedMode)

        # Comma separated list of peer IDs to keep private (will not be gossiped to other peers)
        private_peer_ids = "(P2P.PrivatePeerIDs)"

        # Toggle to disable guard against peers connecting from the same ip.
        allow_duplicate_ip = (P2P.AllowDuplicateIP)

        # Peer connection configuration.
        handshake_timeout = "(P2P.HandshakeTimeout)"
        dial_timeout = "(P2P.DialTimeout)"

        ##### mempool configuration options #####
        [mempool]

        recheck = (Mempool.Recheck)
        broadcast = (Mempool.Broadcast)
        wal_dir = "(js .Mempool.WalPath)"

        # Maximum number of transactions in the mempool
        size = (Mempool.Size)

        # Limit the total size of all txs in the mempool.
        # This only accounts for raw transactions (e.g. given 1MB transactions and
        # max_txs_bytes=5MB, mempool will only accept 5 transactions).
        max_txs_bytes = (Mempool.MaxTxsBytes)

        # Size of the cache (used to filter transactions we saw earlier) in transactions
        cache_size = (Mempool.CacheSize)

        # Maximum size of a single transaction.
        # NOTE: the max size of a tx transmitted over the network is {max_tx_bytes} + {amino overhead}.
        max_tx_bytes = (Mempool.MaxTxBytes)

        ##### fast sync configuration options #####
        [fastsync]

        # Fast Sync version to use:
        #   1) "v0" (default) - the legacy fast sync implementation
        #   2) "v1" - refactor of v0 version for better testability
        #   3) "v2" - refactor of v1 version for better usability
        version = "(FastSync.Version)"

        ##### consensus configuration options #####
        [consensus]

        wal_file = "(js .Consensus.WalPath)"

        timeout_propose = "(Consensus.TimeoutPropose)"
        timeout_propose_delta = "(Consensus.TimeoutProposeDelta)"
        timeout_prevote = "(Consensus.TimeoutPrevote)"
        timeout_prevote_delta = "(Consensus.TimeoutPrevoteDelta)"
        timeout_precommit = "(Consensus.TimeoutPrecommit)"
        timeout_precommit_delta = "(Consensus.TimeoutPrecommitDelta)"
        timeout_commit = "(Consensus.TimeoutCommit)"

        # Make progress as soon as we have all the precommits (as if TimeoutCommit = 0)
        skip_timeout_commit = (Consensus.SkipTimeoutCommit)

        # EmptyBlocks mode and possible interval between empty blocks
        create_empty_blocks = (Consensus.CreateEmptyBlocks)
        create_empty_blocks_interval = "(Consensus.CreateEmptyBlocksInterval)"

        # Reactor sleep duration parameters
        peer_gossip_sleep_duration = "(Consensus.PeerGossipSleepDuration)"
        peer_query_maj23_sleep_duration = "(Consensus.PeerQueryMaj23SleepDuration)"

        ##### transactions indexer configuration options #####
        [tx_index]

        # What indexer to use for transactions
        #
        # Options:
        #   1) "null"
        #   2) "kv" (default) - the simplest possible indexer, backed by key-value storage (defaults to levelDB; see DBBackend).
        indexer = "(TxIndex.Indexer)"

        # Comma-separated list of compositeKeys to index (by default the only key is "tx.hash")
        # Remember that Event has the following structure: type.key
        # type: [
        #  key: value,
        #  ...
        # ]
        #
        # You can also index transactions by height by adding "tx.height" key here.
        #
        # It's recommended to index only a subset of keys due to possible memory
        # bloat. This is, of course, depends on the indexer's DB and the volume of
        # transactions.
        index_keys = "(TxIndex.IndexKeys)"

        # When set to true, tells indexer to index all compositeKeys (predefined keys:
        # "tx.hash", "tx.height" and all keys from DeliverTx responses).
        #
        # Note this may be not desirable (see the comment above). IndexKeys has a
        # precedence over IndexAllKeys (i.e. when given both, IndexKeys will be
        # indexed).
        index_all_keys = (TxIndex.IndexAllKeys)

        ##### instrumentation configuration options #####
        [instrumentation]

        # When true, Prometheus metrics are served under /metrics on
        # PrometheusListenAddr.
        # Check out the documentation for the list of available metrics.
        prometheus = (Instrumentation.Prometheus)

        # Address to listen for Prometheus collector(s) connections
        prometheus_listen_addr = "(Instrumentation.PrometheusListenAddr)"

        # Maximum number of simultaneous connections.
        # If you want to accept a larger number than the default, make sure
        # you increase your OS limits.
        # 0 - unlimited.
        max_open_connections = (Instrumentation.MaxOpenConnections)

        # Instrumentation namespace
        namespace = "(Instrumentation.Namespace)"
        """
    }

    // WriteConfigFile renders config using the template and writes it to configFilePath.
    public func writeConfigurationFile(atPath path: String) {
        let data = defaultConfigurationTemplate.data(using: .utf8)!

        let url = URL(fileURLWithPath: path)
        try! data.write(to: url)
       
        // TODO: Check if this is required
//        try! FileManager.default.setAttributes(
//            [.posixPermissions: NSNumber(value: Int16(0644))],
//            ofItemAtPath: path
//        )
    }
}
