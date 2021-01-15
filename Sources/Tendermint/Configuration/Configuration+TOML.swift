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
        genesis_file = "\(base.genesis)"

        # Path to the JSON file containing the private key to use as a validator in the consensus protocol
        priv_validator_key_file = "\(base.privateValidatorKey)"

        # Path to the JSON file containing the last sign state of a validator
        priv_validator_state_file = "\(base.privateValidatorState)"

        # TCP or UNIX socket address for Tendermint to listen on for
        # connections from an external PrivValidator process
        priv_validator_laddr = "\(base.privateValidatorListenAddress)"

        # Path to the JSON file containing the private key to use for node authentication in the p2p protocol
        node_key_file = "\(base.nodeKey)"

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
        laddr = "\(rpc.listenAddress)"

        # A list of origins a cross-domain request can be executed from
        # Default value '[]' disables cors support
        # Use '["*"]' to allow any origin
        cors_allowed_origins = [\(rpc.corsAllowedOrigins.map({"\"\($0)\""}).joined(separator: ", "))]

        # A list of methods the client is allowed to use with cross-domain requests
        cors_allowed_methods = [\(rpc.corsAllowedMethods.map({"\"\($0)\""}).joined(separator: ", "))]

        # A list of non simple headers the client is allowed to use with cross-domain requests
        cors_allowed_headers = [\(rpc.corsAllowedHeaders.map({"\"\($0)\""}).joined(separator: ", "))]

        # TCP or UNIX socket address for the gRPC server to listen on
        # NOTE: This server only supports /broadcast_tx_commit
        grpc_laddr = "\(rpc.grpcListenAddress)"

        # Maximum number of simultaneous connections.
        # Does not include RPC (HTTP&WebSocket) connections. See max_open_connections
        # If you want to accept a larger number than the default, make sure
        # you increase your OS limits.
        # 0 - unlimited.
        # Should be < {ulimit -Sn} - {MaxNumInboundPeers} - {MaxNumOutboundPeers} - {N of wal, db and other open files}
        # 1024 - 40 - 10 - 50 = 924 = ~900
        grpc_max_open_connections = \(rpc.grpcMaximumOpenConnections)

        # Activate unsafe RPC commands like /dial_seeds and /unsafe_flush_mempool
        unsafe = \(rpc.unsafe)

        # Maximum number of simultaneous connections (including WebSocket).
        # Does not include gRPC connections. See grpc_max_open_connections
        # If you want to accept a larger number than the default, make sure
        # you increase your OS limits.
        # 0 - unlimited.
        # Should be < {ulimit -Sn} - {MaxNumInboundPeers} - {MaxNumOutboundPeers} - {N of wal, db and other open files}
        # 1024 - 40 - 10 - 50 = 924 = ~900
        max_open_connections = \(rpc.maximumOpenConnections)

        # Maximum number of unique clientIDs that can /subscribe
        # If you're using /broadcast_tx_commit, set to the estimated maximum number
        # of broadcast_tx_commit calls per block.
        max_subscription_clients = \(rpc.maximumSubscriptionClients)

        # Maximum number of unique queries a given client can /subscribe to
        # If you're using GRPC (or Local RPC client) and /broadcast_tx_commit, set to
        # the estimated # maximum number of broadcast_tx_commit calls per block.
        max_subscriptions_per_client = \(rpc.maximumSubscriptionsPerClient)

        # How long to wait for a tx to be committed during /broadcast_tx_commit.
        # WARNING: Using a value larger than 10s will result in increasing the
        # global HTTP write timeout, which applies to all connections and endpoints.
        # See https://github.com/tendermint/tendermint/issues/3435
        timeout_broadcast_tx_commit = "\(rpc.timeoutBroadcastTransactionCommit)"

        # Maximum size of request body, in bytes
        max_body_bytes = \(rpc.maximumBodyBytes)

        # Maximum size of request header, in bytes
        max_header_bytes = \(rpc.maximumHeaderBytes)

        # The path to a file containing certificate that is used to create the HTTPS server.
        # Migth be either absolute path or path related to tendermint's config directory.
        # If the certificate is signed by a certificate authority,
        # the certFile should be the concatenation of the server's certificate, any intermediates,
        # and the CA's certificate.
        # NOTE: both tls_cert_file and tls_key_file must be present for Tendermint to create HTTPS server.
        # Otherwise, HTTP server is run.
        tls_cert_file = "\(rpc.tlsCertificateFile)"

        # The path to a file containing matching private key that is used to create the HTTPS server.
        # Migth be either absolute path or path related to tendermint's config directory.
        # NOTE: both tls_cert_file and tls_key_file must be present for Tendermint to create HTTPS server.
        # Otherwise, HTTP server is run.
        tls_key_file = "\(rpc.tlsKeyFile)"

        ##### peer to peer configuration options #####
        [p2p]

        # Address to listen for incoming connections
        laddr = "\(p2p.listenAddress)"

        # Address to advertise to peers for them to dial
        # If empty, will use the same port as the laddr,
        # and will introspect on the listener or use UPnP
        # to figure out the address.
        external_address = "\(p2p.externalAddress)"

        # Comma separated list of seed nodes to connect to
        seeds = "\(p2p.seeds)"

        # Comma separated list of nodes to keep persistent connections to
        persistent_peers = "\(p2p.persistentPeers)"

        # UPNP port forwarding
        upnp = \(p2p.upnp)

        # Path to address book
        addr_book_file = "\(p2p.addressBook)"

        # Set true for strict address routability rules
        # Set false for private or local networks
        addr_book_strict = \(p2p.addressBookStrict)

        # Maximum number of inbound peers
        max_num_inbound_peers = \(p2p.maximumNumberOfInboundPeers)

        # Maximum number of outbound peers to connect to, excluding persistent peers
        max_num_outbound_peers = \(p2p.maximumNumberOfOutboundPeers)

        # List of node IDs, to which a connection will be (re)established ignoring any existing limits
        unconditional_peer_ids = "\(p2p.unconditionalPeerIDs)"

        # Maximum pause when redialing a persistent peer (if zero, exponential backoff is used)
        persistent_peers_max_dial_period = "\(p2p.persistentPeersMaximumDialPeriod)"

        # Time to wait before flushing messages out on the connection
        flush_throttle_timeout = "\(p2p.flushThrottleTimeout)"

        # Maximum size of a message packet payload, in bytes
        max_packet_msg_payload_size = \(p2p.maximumPacketMessagePayloadSize)

        # Rate at which packets can be sent, in bytes/second
        send_rate = \(p2p.sendRate)

        # Rate at which packets can be received, in bytes/second
        recv_rate = \(p2p.receiveRate)

        # Set true to enable the peer-exchange reactor
        pex = \(p2p.peerExchangeReactor)

        # Seed mode, in which node constantly crawls the network and looks for
        # peers. If another node asks it for addresses, it responds and disconnects.
        #
        # Does not work if the peer-exchange reactor is disabled.
        seed_mode = \(p2p.seedMode)

        # Comma separated list of peer IDs to keep private (will not be gossiped to other peers)
        private_peer_ids = "\(p2p.privatePeerIDs)"

        # Toggle to disable guard against peers connecting from the same ip.
        allow_duplicate_ip = \(p2p.allowDuplicateIP)

        # Peer connection configuration.
        handshake_timeout = "\(p2p.handshakeTimeout)"
        dial_timeout = "\(p2p.dialTimeout)"

        ##### mempool configuration options #####
        [mempool]

        recheck = \(memoryPool.recheck)
        broadcast = \(memoryPool.broadcast)
        wal_dir = "\(memoryPool.walPath)"

        # Maximum number of transactions in the mempool
        size = \(memoryPool.size)

        # Limit the total size of all txs in the mempool.
        # This only accounts for raw transactions (e.g. given 1MB transactions and
        # max_txs_bytes=5MB, mempool will only accept 5 transactions).
        max_txs_bytes = \(memoryPool.maximumTransactionsBytes)

        # Size of the cache (used to filter transactions we saw earlier) in transactions
        cache_size = \(memoryPool.cacheSize)

        # Maximum size of a single transaction.
        # NOTE: the max size of a tx transmitted over the network is {max_tx_bytes} + {amino overhead}.
        max_tx_bytes = \(memoryPool.maximumTransactionBytes)

        ##### fast sync configuration options #####
        [fastsync]

        # Fast Sync version to use:
        #   1) "v0" (default) - the legacy fast sync implementation
        #   2) "v1" - refactor of v0 version for better testability
        #   3) "v2" - refactor of v1 version for better usability
        version = "\(fastSync.version)"

        ##### consensus configuration options #####
        [consensus]

        wal_file = "\(consensus.walPath)"

        timeout_propose = "\(consensus.timeoutPropose)"
        timeout_propose_delta = "\(consensus.timeoutProposeDelta)"
        timeout_prevote = "\(consensus.timeoutPrevote)"
        timeout_prevote_delta = "\(consensus.timeoutPrevoteDelta)"
        timeout_precommit = "\(consensus.timeoutPrecommit)"
        timeout_precommit_delta = "\(consensus.timeoutPrecommitDelta)"
        timeout_commit = "\(consensus.timeoutCommit)"

        # Make progress as soon as we have all the precommits (as if TimeoutCommit = 0)
        skip_timeout_commit = \(consensus.skipTimeoutCommit)

        # EmptyBlocks mode and possible interval between empty blocks
        create_empty_blocks = \(consensus.createEmptyBlocks)
        create_empty_blocks_interval = "\(consensus.createEmptyBlocksInterval)"

        # Reactor sleep duration parameters
        peer_gossip_sleep_duration = "\(consensus.peerGossipSleepDuration)"
        peer_query_maj23_sleep_duration = "\(consensus.peerQueryMaj23SleepDuration)"

        ##### transactions indexer configuration options #####
        [tx_index]

        # What indexer to use for transactions
        #
        # Options:
        #   1) "null"
        #   2) "kv" (default) - the simplest possible indexer, backed by key-value storage (defaults to levelDB; see DBBackend).
        indexer = "\(transactionIndex.indexer)"

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
        index_keys = "\(transactionIndex.indexKeys)"

        # When set to true, tells indexer to index all compositeKeys (predefined keys:
        # "tx.hash", "tx.height" and all keys from DeliverTx responses).
        #
        # Note this may be not desirable (see the comment above). IndexKeys has a
        # precedence over IndexAllKeys (i.e. when given both, IndexKeys will be
        # indexed).
        index_all_keys = \(transactionIndex.indexAllKeys)

        ##### instrumentation configuration options #####
        [instrumentation]

        # When true, Prometheus metrics are served under /metrics on
        # PrometheusListenAddr.
        # Check out the documentation for the list of available metrics.
        prometheus = \(instrumentation.prometheus)

        # Address to listen for Prometheus collector(s) connections
        prometheus_listen_addr = "\(instrumentation.prometheusListenAddress)"

        # Maximum number of simultaneous connections.
        # If you want to accept a larger number than the default, make sure
        # you increase your OS limits.
        # 0 - unlimited.
        max_open_connections = \(instrumentation.maximumOpenConnections)

        # Instrumentation namespace
        namespace = "\(instrumentation.namespace)"
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
