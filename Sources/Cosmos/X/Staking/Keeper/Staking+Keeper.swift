// keeper of the staking store
public class StakingKeeper { //: ValidatorSet, DelegationSet {
    // TODO: Implement
    let storeKey: StoreKey
    let codec: Codec
    let supplyKeeper: SupplyKeeper
    var hooks: StakingHooks?
    let paramstore: Subspace
//    private let validatorCache: [String: CachedValidator]
//    private let validatorCacheList: List
    
    public init(
        codec: Codec,
        key: StoreKey,
        supplyKeeper: SupplyKeeper,
        paramstore: Subspace
    ) {
        // ensure bonded and not bonded module accounts are set
        // TODO: Implement
//        if supplyKeeper.moduleAddress(StakingKeys.bondedPoolName) == nil {
//            fatalError("\(StakingKeys.bondedPoolName) module account has not been set")
//        }
//
//        if supplyKeeper.moduleAddress(StakingKeys.notBondedPoolName) == nil {
//            fatalError("\(StakingKeys.notBondedPoolName) module account has not been set")
//        }
        
        self.storeKey = key
        self.codec = codec
        self.supplyKeeper = supplyKeeper
        self.paramstore = paramstore
    }
    
    // Set the validator hooks
    // TODO: Check if we really need to retun self
    @discardableResult
    public func setHooks(_ hooks: StakingHooks) -> StakingKeeper {
        if self.hooks != nil {
            fatalError("cannot set validator hooks twice")
        }
    
        self.hooks = hooks
        return self
    }

}
