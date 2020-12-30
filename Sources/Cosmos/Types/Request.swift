import Foundation
import Logging
import ABCI

/// Request is an immutable object contains all information needed to
/// process a request.
public final class Request {
    let multiStore: MultiStore
    var header: Header
    let chainID: String
    let transactionData: Data = Data()
    let logger: Logger
    let voteInfo: [VoteInfo] = []
    let gasMeter: GasMeter
    var blockGasMeter: GasMeter? = nil
    let checkTransaction: Bool
    // if recheckTx == true, then checkTx must also be true
    let recheckTransaction: Bool = false
    var minGasPrices: DecimalCoins
    let consensusParams: ConsensusParams? = nil
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
}
