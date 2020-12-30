import Foundation
import Logging
import ABCI
import Database

public enum BaseAppKeys {
    // MainStoreKey is the string representation of the main store
    public static let mainStoreKey = "main"
}

// mainConsensusParamsKey defines a key to store the consensus params in the
// main store.
let mainConsensusParamsKey = "consensus_params".data

// StoreLoader defines a customizable function to control how we load the CommitMultiStore
// from disk. This is useful for state migration, when loading a datastore written with
// an older version of the software. In particular, if a module changed the substore key name
// (or removed a substore) between two versions of the software.
public typealias StoreLoader = (_ commitMultiStore: CommitMultiStore) throws -> Void


// BaseApp reflects the ABCI application implementation.
open class BaseApp: Sealable {
    /// Initialized on creation
    let logger: Logger
   
    /// Application name from abci.Info
    public var name: String
    
    /// Common DB backend
    var database: Database
    
    // Main (uncached) state
    var commitMultiStore: CommitMultiStore
    
    // function to handle store loading, may be overridden with SetStoreLoader()
    var storeLoader: StoreLoader
    
    // handle any kind of message
    public var router: Router
    
    // router for redirecting query calls
    public var queryRouter: QueryRouter
    
    // unmarshal []byte into sdk.Tx
    let transactionDecoder: TransactionDecoder

    // set upon LoadVersion or LoadLatestVersion.
    // Main KVStore in cms
    var baseKey: KeyValueStoreKey?
    
    // ante handler for fee and auth
    var anteHandler: AnteHandler?
    
    // initialize state with validators and state blob
    var initChainer: InitChainer?
    
    // logic to run before any txs
    var beginBlocker: BeginBlocker?
    
    // logic to run after all txs, and to determine valset changes
    var endBlocker: EndBlocker?
    
    // filter peers by address and port
    var addressPeerFilter: PeerFilter?
    
    // filter peers by node ID
    var idPeerFilter: PeerFilter?
    
    // if true, IAVL MountStores uses MountStoresDB for simulation speed.
    var fauxMerkleMode: Bool = false

    // volatile states:
    //
    // checkState is set on InitChain and reset on Commit
    // deliverState is set on InitChain and BeginBlock and set to nil on Commit
    
    // for CheckTx
    var checkState: State?
    
    // for DeliverTx
    var deliverState: State?

    // an inter-block write-through cache provided to the context during deliverState
    var interBlockCache: MultiStorePersistentCache? = nil

    // absent validators from begin block
    var voteInfos: [VoteInfo] = []

    // consensus params
    // TODO: Move this in the future to baseapp param store on main store.
    var consensusParams: ConsensusParams?

    // The minimum gas prices a validator is willing to accept for processing a
    // transaction. This is mainly used for DoS and spam prevention.
    // TODO: Maybe make minGasPrices start with empty coins
    // instead of being nil
    var minGasPrices: DecimalCoins? = nil

    // flag for sealing options and parameters to a BaseApp
    var sealed: Bool = false

    // block height at which to halt the chain and gracefully shutdown
    var haltHeight: UInt64 = 0

    // minimum block time (in Unix seconds) at which to halt the chain and gracefully shutdown
    var haltTime: UInt64 = 0

    // application's version string
    var appVersion: String = ""

    // trace set will return full stack traces for errors in ABCI Log field
    var trace: Bool = false
    
    // NewBaseApp returns a reference to an initialized BaseApp. It accepts a
    // variadic number of option functions, which act on the BaseApp to set
    // configuration choices.
    //
    // NOTE: The db is used to store the version number for now.
    public init(
        name: String,
        logger: Logger,
        database: Database,
        transactionDecoder: @escaping TransactionDecoder,
        options: [(BaseApp) -> Void] = []
    ) {
        self.logger = logger
        self.name = name
        self.database = database
        self.commitMultiStore = makeCommitMultiStore(database: database)
        self.storeLoader =  BaseApp.defaultStoreLoader
        self.router = Router()
        self.queryRouter = QueryRouter()
        self.transactionDecoder = transactionDecoder

        for option in options {
            option(self)
        }

        if let interBlockCache = self.interBlockCache {
            commitMultiStore.set(interBlockCache: interBlockCache)
        }
    }
    
    // MountStores mounts all IAVL or DB stores to the provided keys in the BaseApp
    // multistore.
    public func mountKeyValueStores(keys: [String: KeyValueStoreKey]) {
        for key in keys.values {
            if fauxMerkleMode {
                // StoreTypeDB doesn't do anything upon commit, and it doesn't
                // retain history, but it's useful for faster simulation.
                mountStore(key: key, type: .database)
            } else {
                mountStore(key: key, type: .iavlTree)
            }
        }
    }
    
    // MountStores mounts all IAVL or DB stores to the provided keys in the BaseApp
    // multistore.
    public func mountTransientStores(keys: [String: TransientStoreKey]) {
        for key in keys.values {
            mountStore(key: key, type: .transient)
        }
    }
    
    // MountStore mounts a store to the provided key in the BaseApp multistore,
    // using the default DB.
    func mountStore(key: StoreKey, type: StoreType) {
        commitMultiStore.mountStoreWithDatabase(
            key: key,
            type: type,
            database: nil
        )
    }

    
    // LoadLatestVersion loads the latest application version. It will panic if
    // called more than once on a running BaseApp.
    public func loadLatestVersion(baseKey: KeyValueStoreKey) throws {
        try storeLoader(commitMultiStore)
        try initFromMainStore(baseKey: baseKey)
    }


    // DefaultStoreLoader will be used by default and loads the latest version
    static func defaultStoreLoader(commitMultiStore: CommitMultiStore) throws {
         try commitMultiStore.loadLatestVersion()
    }

    
    // LoadVersion loads the BaseApp application version. It will panic if called
    // more than once on a running baseapp.
    public func load(version: Int64, baseKey: KeyValueStoreKey) throws {
        try commitMultiStore.load(version: version)
        try initFromMainStore(baseKey: baseKey)
    }
    
    // LastBlockHeight returns the last committed block height.
    var lastBlockHeight: Int64? {
        commitMultiStore.lastCommitID?.version
    }

    
    // initializes the remaining logic from app.cms
    func initFromMainStore(baseKey: KeyValueStoreKey) throws {
//        let mainStore = commitMultiStore.keyValueStore(key: baseKey)
//        guard let mainStore = commitMultiStore.keyValueStore(key: baseKey) else {
//            throw Cosmos.Error.keyNotFound(key: "baseapp expects MultiStore with 'main' KVStore")
//        }

        // memoize baseKey
        if self.baseKey != nil {
            fatalError("app.baseKey expected to be nil; duplicate init?")
        }
        
        self.baseKey = baseKey

        // TODO: Implement
        // Load the consensus params from the main store. If the consensus params are
        // nil, it will be saved later during InitChain.
        //
        // TODO: assert that InitChain hasn't yet been called.
//        if let consensusParamsData = mainStore.get(key: mainConsensusParamsKey) {
//            do {
                // TODO: Check this protobuf decoding.
//                let consensusParams: ConsensusParams = try proto.unmarshal(data: consensusParamsData)
                // TODO: If JSONDecoder is enough, we need to make ConsensusParams Codable
//                let consensusParams = try JSONDecoder().decode(ConsensusParams.self, from: consensusParamsData)
//                self.consensusParams = consensusParams
//            } catch {
//                fatalError("\(error)")
//            }
//        }

        // needed for the export command which inits from store but never calls initchain
        // TODO: Make Header initializer public on ABCI.
//        setCheckState(header: Header())
        seal()
    }
    
    // setCheckState sets the BaseApp's checkState with a cache-wrapped multi-store
    // (i.e. a CacheMultiStore) and a new Context with the cache-wrapped multi-store,
    // provided header, and minimum gas prices set. It is set on InitChain and reset
    // on Commit.
    func setCheckState(header: Header) {
        let multiStore = commitMultiStore.cacheMultiStore
        let request = Request(multiStore: multiStore, header: header, isCheckTransaction: true, logger: logger)
        // TODO: Implement
//        request.minGasPrices = minGasPrices
        
        checkState = State(
            multiStore: multiStore,
            request: request
        )
    }

    // Seal seals a BaseApp. It prohibits any further modifications to a BaseApp.
    func seal() {
        sealed = true
    }
    
    // setCheckState sets the BaseApp's checkState with a cache-wrapped multi-store
    // (i.e. a CacheMultiStore) and a new Context with the cache-wrapped multi-store,
    // provided header, and minimum gas prices set. It is set on InitChain and reset
    // on Commit.
    func set(checkState header: Header) {
        let multiStore = commitMultiStore.cacheMultiStore
        
        var request = Request(
            multiStore: multiStore,
            header: header,
            isCheckTransaction: true,
            logger: logger
        )
       
        if let minGasPrices = self.minGasPrices {
            request.minGasPrices = minGasPrices
        }

        checkState = State(
            multiStore: multiStore,
            request: request
        )
    }

    
    // setDeliverState sets the BaseApp's deliverState with a cache-wrapped multi-store
    // (i.e. a CacheMultiStore) and a new Context with the cache-wrapped multi-store,
    // and provided header. It is set on InitChain and BeginBlock and set to nil on
    // Commit.
    func set(deliverState header: Header) {
        let multiStore = commitMultiStore.cacheMultiStore
        
        deliverState = State(
            multiStore: multiStore,
            request: Request(
                multiStore: multiStore,
                header: header,
                isCheckTransaction: false,
                logger: logger
            )
        )
    }

    // setConsensusParams memoizes the consensus params.
    func set(consensusParams: ConsensusParams) {
        self.consensusParams = consensusParams
    }

    // setConsensusParams stores the consensus params to the main store.
    func store(consensusParams: ConsensusParams) {
        let consensusParamsData: Data
        
        do {
            // TODO: Protobuf was used here.
            // Maybe just JSON takes care of it
            consensusParamsData = try JSONEncoder().encode(consensusParams)
        } catch {
            fatalError("\(error)")
        }
        
        guard let baseKey = self.baseKey else {
            fatalError("baseKey not set")
        }
        
        let mainStore = commitMultiStore.keyValueStore(key: baseKey)
        mainStore.set(key: mainConsensusParamsKey, value: consensusParamsData)
    }

    // getMaximumBlockGas gets the maximum gas from the consensus params. It panics
    // if maximum block gas is less than negative one and returns zero if negative
    // one.
    var maximumBlockGas: UInt64 {
        // TODO: Check if `block` really needs to be optional
        guard let consensusParams = self.consensusParams, consensusParams.block != nil else {
            return 0
        }

        let maxGas = consensusParams.block.maxGas
        
        if maxGas < -1 {
            fatalError("invalid maximum block gas: \(maxGas)")
        } else if maxGas == -1 {
            return 0
        } else {
            return UInt64(maxGas)
        }
    }

    func validateHeight(request: RequestBeginBlock) throws {
        guard request.header.height >= 1 else {
            throw Cosmos.Error.generic(reason: "invalid height: \(request.header.height)")
        }

        // TODO: Check this default value
        let previousHeight = self.lastBlockHeight ?? 0
        
        guard request.header.height == previousHeight + 1 else {
            throw Cosmos.Error.generic(reason: "invalid height: \(request.header.height); expected: \(previousHeight + 1)")
        }
    }


}
