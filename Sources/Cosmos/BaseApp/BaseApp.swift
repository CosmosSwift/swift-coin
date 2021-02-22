import Foundation
import Logging
import Crypto
import ABCIMessages
import Database
import DataConvertible

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
    enum RunTransactionMode {
        case check
        case recheck
        case deliver
        case simulate
    }

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
    var voteInfo: [VoteInfo] = []

    // consensus params
    // TODO: Move this in the future to baseapp param store on main store.
    var consensusParams: ConsensusParams?

    // The minimum gas prices a validator is willing to accept for processing a
    // transaction. This is mainly used for DoS and spam prevention.
    // TODO: Maybe make minGasPrices start with empty coins
    // instead of being nil
    var minGasPrices: [DecimalCoin]? = nil

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
//             TODO: Check this protobuf decoding.
//            let consensusParams: ConsensusParams = try! proto.unmarshal(data: consensusParamsData)
//             TODO: If JSONDecoder is enough, we need to make ConsensusParams Codable
//            let consensusParams = try! JSONDecoder().decode(ConsensusParams.self, from: consensusParamsData)
//            self.consensusParams = consensusParams
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
        
        let request = Request(
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
        // TODO: Protobuf was used here.
        // Maybe just JSON takes care of it
        let consensusParamsData = try! JSONEncoder().encode(consensusParams)

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
        guard
            let consensusParams = self.consensusParams,
            consensusParams.block != nil
        else {
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
    
    // validateBasicTxMsgs executes basic validator calls for messages.
    func validateBasic(transactionMessages: [Message]) throws {
        guard !transactionMessages.isEmpty else {
            throw CosmosError.wrap(
                error: CosmosError.invalidRequest,
                description: "must contain at least one message"
            )
        }

        for message in transactionMessages {
            try message.validateBasic()
        }
    }

    
    // Returns the applications's deliverState if app is in runTxModeDeliver,
    // otherwise it returns the application's checkstate.
    func state(mode: RunTransactionMode) -> State? {
        if mode == .deliver {
            return deliverState
        }

        return checkState
    }


    // retrieve the context for the tx w/ txBytes and other memoized values.
    func contextForTransaction(mode: RunTransactionMode, transactionData: Data) -> Request {
        guard let state = self.state(mode: mode) else {
            fatalError("state should be set by now")
        }
        
        let request = state.request
        request.transactionData = transactionData
        request.voteInfo = voteInfo
        request.consensusParams = consensusParams

        if mode == .recheck {
            request.recheckTransaction = true
        }
        
        if mode == .simulate {
            request.cacheContext()
        }

        return request
    }
    
    // cacheTxContext returns a new context based off of the provided context with
    // a cache wrapped multi-store.
    func cache(transactionRequest: Request, transactionData: Data) -> (Request, CacheMultiStore) {
        let request = transactionRequest
        let multiStore = request.multiStore
        
        // TODO: https://github.com/cosmos/cosmos-sdk/issues/2824
        let multiStoreCache = multiStore.cacheMultiStore
        
        if multiStoreCache.isTracingEnabled {
            multiStoreCache.set(tracingContext: [
                "txHash": "\(SHA256.hash(data: transactionData))"
            ])
        }
        
        request.multiStore = multiStoreCache
        return (request, multiStoreCache)
    }


    // runTx processes a transaction within a given execution mode, encoded transaction
    // bytes, and the decoded transaction itself. All state transitions occur through
    // a cached Context depending on the mode provided. State only gets persisted
    // if all messages get executed successfully and the execution mode is DeliverTx.
    // Note, gas execution info is always returned. A reference to a Result is
    // returned if the tx does not run out of gas and if all the messages are valid
    // and execute successfully. An error is returned otherwise.
    func runTransaction(
        mode: RunTransactionMode,
        transactionData: Data,
        transaction: Transaction
    ) -> (gasInfo: GasInfo, result: Swift.Result<Result, Swift.Error>) {
        // NOTE: GasWanted should be returned by the AnteHandler. GasUsed is
        // determined by the GasMeter. We need access to the context to get the gas
        // meter so we initialize upfront.
        var gasWanted: UInt64 = 0

        var request = contextForTransaction(mode: mode, transactionData: transactionData)
        let multiStore = request.multiStore
        
        guard var blockGasMeter = request.blockGasMeter else {
            fatalError("blockGasMeter should be set by now.")
        }

        // only run the tx if there is block gas remaining
        if
            mode == .deliver,
            blockGasMeter.isOutOfGas == true
        {
            let gasInfo = GasInfo(gasUsed: blockGasMeter.gasConsumed)
           
            let error = CosmosError.wrap(
                error: CosmosError.outOfGas,
                description: "no block gas left to run tx"
            )
            
            return (gasInfo, .failure(error))
        }

        var startingGas: UInt64 = 0

        if mode == .deliver {
            startingGas = blockGasMeter.gasConsumed
        }
        
        do {
            // If `consumeGas` throws it will be caught by the catch below and will
            // return an error - in any case BlockGasMeter will consume gas past the limit.
            // TODO: Check how to mimic defer here
            func deferred() throws {
                if mode == .deliver {
                    try blockGasMeter.consumeGas(
                        amount: request.gasMeter.gasConsumedToLimit, descriptor: "block gas meter"
                    )

                    if blockGasMeter.gasConsumed < startingGas {
                        throw GasOverflowError(descriptor: "tx gas summation")
                    }
                }
            }
            
            let messages = transaction.messages

            do {
                try validateBasic(transactionMessages: messages)
            } catch {
                try deferred()
                return (GasInfo(), .failure(error))
            }

            if let anteHandler = self.anteHandler {
                // Cache wrap context before AnteHandler call in case it aborts.
                // This is required for both CheckTx and DeliverTx.
                // Ref: https://github.com/cosmos/cosmos-sdk/issues/2772
                //
                // NOTE: Alternatively, we could require that AnteHandler ensures that
                // writes do not happen if aborted/failed.  This may have some
                // performance benefits, but it'll be more difficult to get right.
                let (anteRequest, multiStoreCache) = cache(
                    transactionRequest: request,
                    transactionData: transactionData
                )

                anteRequest.eventManager = EventManager()

                do {
                    if let newRequest = try anteHandler(anteRequest, transaction, mode == .simulate) {
                        // At this point, newCtx.MultiStore() is cache-wrapped, or something else
                        // replaced by the AnteHandler. We want the original multistore, not one
                        // which was cache-wrapped for the AnteHandler.
                        //
                        // Also, in the case of the tx aborting, we need to track gas consumed via
                        // the instantiated gas meter in the AnteHandler, so we update the context
                        // prior to returning.
                        request = newRequest
                        request.multiStore = multiStore
                    }

                    // GasMeter expected to be set in AnteHandler
                    gasWanted = request.gasMeter.limit
                } catch {
                    try deferred()
                    return (GasInfo(), .failure(error))
                }

                multiStoreCache.write()
            }

            // Create a new Context based off of the existing Context with a cache-wrapped
            // MultiStore in case message processing fails. At this point, the MultiStore
            // is doubly cached-wrapped.
            let (runMessageRequest, multiStoreCache) = cache(
                transactionRequest: request,
                transactionData: transactionData
            )

            do {
                // Attempt to execute all messages and only update state if all messages pass
                // and we're in DeliverTx. Note, runMsgs will never return a reference to a
                // Result if any single message fails or does not have a registered Handler.
                let result = try runMessages(
                    request: runMessageRequest,
                    messages: messages,
                    mode: mode
                )

                if mode == .deliver {
                    multiStoreCache.write()
                }

                return (GasInfo(), .success(result))
            } catch {
                try deferred()
                return (GasInfo(), .failure(error))
            }

            // TODO: Check if this works as expect.
            // The original implementation called recover
            // We don't have panic in Swift so we use regular catch
        } catch {
            let cosmosError: Swift.Error
            
            // TODO: Use ErrOutOfGas instead of ErrorOutOfGas which would allow us
            // to keep the stracktrace.
             
            // TODO: We should probably make CosmosError a protocol and have structs
            // that implement the protocol
            if let error = error as? CosmosError, error == CosmosError.outOfGas {
                cosmosError = CosmosError.wrap(
                    error: CosmosError.outOfGas,
                    description: "out of gas in location: \(error); gasWanted: \(gasWanted), gasUsed: \(request.gasMeter.gasConsumed)"
                )
            } else {
                cosmosError = CosmosError.wrap(
                    error: CosmosError.panic,
                    // TODO: Print stack trace
//                    description: "recovered: \(error)\nstack:\n\(debug.stack)"
                    description: "recovered: \(error)\n"
                )
            }

            let gasInfo = GasInfo(
                gasWanted: gasWanted,
                gasUsed: request.gasMeter.gasConsumed
            )
        
            return (gasInfo, .failure(cosmosError))
        }
    }
    
    // runMsgs iterates through a list of messages and executes them with the provided
    // Context and execution mode. Messages will only be executed during simulation
    // and DeliverTx. An error is returned if any single message fails or if a
    // Handler does not exist for a given message route. Otherwise, a reference to a
    // Result is returned. The caller must not commit state if an error is returned.
    func runMessages(request: Request, messages: [Message], mode: RunTransactionMode) throws -> Result {
        var messageLogs: [ABCIMessageLog] = []
        var data = Data()
        var events: [Event] = []

        // NOTE: GasWanted is determined by the AnteHandler and GasUsed by the GasMeter.
        for (i, message) in messages.enumerated() {
            // skip actual execution for (Re)CheckTx mode
            if mode == .check || mode == .recheck {
                break
            }

            let messageRoute = message.route
            
            guard let handler = router.route(request: request, path: messageRoute) else {
                throw CosmosError.wrap(
                    error: CosmosError.unknownRequest,
                    description: "unrecognized message route: \(messageRoute); message index: \(i)"
                )
            }

            let messageResult: Result
            
            do {
                messageResult = try handler(request, message)
            } catch {
                throw CosmosError.wrap(
                    error: error,
                    description: "failed to execute message; message index: \(i)"
                )
            }
            
            var messageEvents: Events = [
                Event(
                    type: EventType.message,
                    attributes: [
                        Attribute(
                            key: AttributeKey.action,
                            value: message.type
                        )
                    ]
                )
            ]
            
            messageEvents.append(contentsOf: messageResult.events)

            // append message events, data and logs
            //
            // Note: Each message result's data must be length-prefixed in order to
            // separate each result.
            events.append(contentsOf: messageEvents)
            data.append(contentsOf: messageResult.data)
            
            let log = ABCIMessageLog(
                messageIndex: UInt16(i),
                log: messageResult.log,
                events: messageEvents
            )
            
            messageLogs.append(log)
        }

        return Result(
            data: data,
            log: messageLogs.description.trimmingCharacters(in: .whitespaces),
            events: events
        )
    }
}
