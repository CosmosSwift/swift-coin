/// Request is an immutable object contains all information needed to
/// process a request.
public struct Request {
    let multiStore: MultiStore
//    let header: Header
//    chainID       string
//    txBytes       []byte
//    logger        log.Logger
//    voteInfo      []abci.VoteInfo
    let gasMeter: GasMeter
//    blockGasMeter GasMeter
//    checkTx       bool
//    recheckTx     bool // if recheckTx == true, then checkTx must also be true
//    minGasPrice   DecCoins
//    consParams    *abci.ConsensusParams
    public var eventManager:  EventManager
}

extension Request {
    public func keyValueStore(key: StoreKey) -> KeyValueStore {
        GasKeyValueStore(
            parent: multiStore.getKeyValueStore(key: key),
            gasMeter: gasMeter,
            gasConfiguration: .keyValue
        )
    }
}
