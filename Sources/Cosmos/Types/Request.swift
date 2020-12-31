import Foundation
import Logging
import ABCI

/// Request is an immutable object contains all information needed to
/// process a request.
public final class Request {
    var multiStore: MultiStore
    var header: Header
    let chainID: String
    var transactionData: Data = Data()
    let logger: Logger
    var voteInfo: [VoteInfo] = []
    let gasMeter: GasMeter
    var blockGasMeter: GasMeter? = nil
    var checkTransaction: Bool
    
    var recheckTransaction: Bool = false {
        // if recheckTx == true, then checkTx must also be true
        didSet {
            if recheckTransaction {
                checkTransaction = true
            }
        }
    }
    
    var minGasPrices: DecimalCoins
    var consensusParams: ConsensusParams? = nil
    public var eventManager:  EventManager
    
    // create a new context
    init(
        multiStore: MultiStore,
        header: Header,
        isCheckTransaction: Bool,
        logger: Logger
    ) {
        self.multiStore = multiStore
        self.header = header
        self.chainID = header.chainID
        self.checkTransaction = isCheckTransaction
        self.logger = logger
        self.gasMeter = InfiniteGasMeter()
        self.minGasPrices = DecimalCoins()
        self.eventManager = EventManager()
    }

}

extension Request {
    public func keyValueStore(key: StoreKey) -> KeyValueStore {
        GasKeyValueStore(
            parent: multiStore.keyValueStore(key: key),
            gasMeter: gasMeter,
            gasConfiguration: .keyValue
        )
    }
    
    // CacheContext returns a new Context with the multi-store cached and a new
    // EventManager. The cached context is written to the context when writeCache
    // is called.
    @discardableResult
    func cacheContext() -> () -> Void {
        let commitMultiStore = multiStore.cacheMultiStore
        multiStore = commitMultiStore
        eventManager = EventManager()
        return commitMultiStore.write
    }

}
