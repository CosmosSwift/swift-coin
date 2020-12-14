import Foundation
import Logging
import ABCI

/// Request is an immutable object contains all information needed to
/// process a request.
public struct Request {
    let multiStore: MultiStore
    let header: Header
    let chainID: String
    let transactionData: Data = Data()
    let logger: Logger
    let voteInfo: [VoteInfo] = []
    let gasMeter: GasMeter
    let blockGasMeter: GasMeter? = nil
    let checkTransaction: Bool
    // if recheckTx == true, then checkTx must also be true
    let recheckTransaction: Bool = false
    let minGasPrice: DecimalCoins
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
        self.minGasPrice = DecimalCoins()
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
