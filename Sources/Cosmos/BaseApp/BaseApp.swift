import Foundation
import Logging
import ABCI
import Database

enum Key {
// MainStoreKey is the string representation of the main store
 public static let MainStoreKey = "main"
}

// mainConsensusParamsKey defines a key to store the consensus params in the
// main store.
let mainConsensusParamsKey = "consensus_params".data

// StoreLoader defines a customizable function to control how we load the CommitMultiStore
// from disk. This is useful for state migration, when loading a datastore written with
// an older version of the software. In particular, if a module changed the substore key name
// (or removed a substore) between two versions of the software.
typealias StoreLoader = (_ commitMultiStore: CommitMultiStore) throws -> Void


// BaseApp reflects the ABCI application implementation.
open class BaseApp {
    /// Initialized on creation
    let logger: Logger
   
    /// Application name from abci.Info
    let name: String
    
    /// Common DB backend
    let database: Database
    
    // Main (uncached) state
    let commitMultiStore: CommitMultiStore
    
    // function to handle store loading, may be overridden with SetStoreLoader()
    let storeLoader: StoreLoader
    
    // handle any kind of message
    let router: Router
    
    // router for redirecting query calls
    let queryRouter: QueryRouter
    
    // unmarshal []byte into sdk.Tx
    let transactionDecoder: TransactionDecoder

    // set upon LoadVersion or LoadLatestVersion.
    // Main KVStore in cms
    var baseKey: KeyValueStoreKey?

//    anteHandler    sdk.AnteHandler  // ante handler for fee and auth
//    initChainer    sdk.InitChainer  // initialize state with validators and state blob
//    beginBlocker   sdk.BeginBlocker // logic to run before any txs
//    endBlocker     sdk.EndBlocker   // logic to run after all txs, and to determine valset changes
//    addrPeerFilter sdk.PeerFilter   // filter peers by address and port
//    idPeerFilter   sdk.PeerFilter   // filter peers by node ID
    let fauxMerkleMode: Bool             // if true, IAVL MountStores uses MountStoresDB for simulation speed.

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
    let voteInfos: [VoteInfo]

    // consensus params
    // TODO: Move this in the future to baseapp param store on main store.
    var consensusParams: ConsensusParams?

    // The minimum gas prices a validator is willing to accept for processing a
    // transaction. This is mainly used for DoS and spam prevention.
    var minGasPrices: DecimalCoins? = nil

    // flag for sealing options and parameters to a BaseApp
    var sealed: Bool

    // block height at which to halt the chain and gracefully shutdown
    var haltHeight: UInt64

    // minimum block time (in Unix seconds) at which to halt the chain and gracefully shutdown
    var haltTime: UInt64

    // application's version string
    let appVersion: String

    // trace set will return full stack traces for errors in ABCI Log field
    var trace: Bool
    
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
        fauxMerkleMode: Bool = false,
        trace: Bool = false
    ) {
        self.logger = logger
        self.name = name
        self.database = database
        self.commitMultiStore = makeCommitMultiStore(database: database)
        self.storeLoader =  BaseApp.defaultStoreLoader
        self.router = Router()
        self.queryRouter = QueryRouter()
        self.transactionDecoder = transactionDecoder
        self.fauxMerkleMode = fauxMerkleMode
        self.trace = trace
        
        self.voteInfos = []
        self.consensusParams = nil
        self.sealed = false
        self.haltHeight = 0
        self.haltTime = 0
        self.appVersion = ""

        // TODO: Make sure we add this code to interBlockCache setter.
//        if app.interBlockCache != nil {
//            app.commitMultiStore.interBlockCache = app.interBlockCache
//        }
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
    
    // initializes the remaining logic from app.cms
    func initFromMainStore(baseKey: KeyValueStoreKey) throws {
        let mainStore = commitMultiStore.keyValueStore(key: baseKey)
//        guard let mainStore = commitMultiStore.keyValueStore(key: baseKey) else {
//            throw Cosmos.Error.keyNotFound(key: "baseapp expects MultiStore with 'main' KVStore")
//        }

        // memoize baseKey
        if self.baseKey != nil {
            fatalError("app.baseKey expected to be nil; duplicate init?")
        }
        
        self.baseKey = baseKey

        // Load the consensus params from the main store. If the consensus params are
        // nil, it will be saved later during InitChain.
        //
        // TODO: assert that InitChain hasn't yet been called.
        if let consensusParamsData = mainStore.get(key: mainConsensusParamsKey) {
            do {
                // TODO: Check this protobuf decoding.
//                let consensusParams: ConsensusParams = try proto.unmarshal(data: consensusParamsData)
                // TODO: If JSONDecoder is enough, we need to make ConsensusParams Codable
//                let consensusParams = try JSONDecoder().decode(ConsensusParams.self, from: consensusParamsData)
//                self.consensusParams = consensusParams
            } catch {
                fatalError("\(error)")
            }
        }

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
        var request = Request(multiStore: multiStore, header: header, isCheckTransaction: true, logger: logger)
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
}
