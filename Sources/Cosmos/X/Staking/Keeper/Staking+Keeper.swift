import ABCI

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
    
    public func initGenesis(request: Request, state: StakingGenesisState) -> [ValidatorUpdate] {
        fatalError()
        //        func InitGenesis(ctx sdk.Context, keeper Keeper, accountKeeper types.AccountKeeper,
        //            supplyKeeper types.SupplyKeeper, data types.GenesisState) (res []abci.ValidatorUpdate) {
        //
        //            bondedTokens := sdk.ZeroInt()
        //            notBondedTokens := sdk.ZeroInt()
        //
        //            // We need to pretend to be "n blocks before genesis", where "n" is the
        //            // validator update delay, so that e.g. slashing periods are correctly
        //            // initialized for the validator set e.g. with a one-block offset - the
        //            // first TM block is at height 1, so state updates applied from
        //            // genesis.json are in block 0.
        //            ctx = ctx.WithBlockHeight(1 - sdk.ValidatorUpdateDelay)
        //
        //            keeper.SetParams(ctx, data.Params)
        //            keeper.SetLastTotalPower(ctx, data.LastTotalPower)
        //
        //            for _, validator := range data.Validators {
        //                keeper.SetValidator(ctx, validator)
        //
        //                // Manually set indices for the first time
        //                keeper.SetValidatorByConsAddr(ctx, validator)
        //                keeper.SetValidatorByPowerIndex(ctx, validator)
        //
        //                // Call the creation hook if not exported
        //                if !data.Exported {
        //                    keeper.AfterValidatorCreated(ctx, validator.OperatorAddress)
        //                }
        //
        //                // update timeslice if necessary
        //                if validator.IsUnbonding() {
        //                    keeper.InsertValidatorQueue(ctx, validator)
        //                }
        //
        //                switch validator.GetStatus() {
        //                case sdk.Bonded:
        //                    bondedTokens = bondedTokens.Add(validator.GetTokens())
        //                case sdk.Unbonding, sdk.Unbonded:
        //                    notBondedTokens = notBondedTokens.Add(validator.GetTokens())
        //                default:
        //                    panic("invalid validator status")
        //                }
        //            }
        //
        //            for _, delegation := range data.Delegations {
        //                // Call the before-creation hook if not exported
        //                if !data.Exported {
        //                    keeper.BeforeDelegationCreated(ctx, delegation.DelegatorAddress, delegation.ValidatorAddress)
        //                }
        //                keeper.SetDelegation(ctx, delegation)
        //
        //                // Call the after-modification hook if not exported
        //                if !data.Exported {
        //                    keeper.AfterDelegationModified(ctx, delegation.DelegatorAddress, delegation.ValidatorAddress)
        //                }
        //            }
        //
        //            for _, ubd := range data.UnbondingDelegations {
        //                keeper.SetUnbondingDelegation(ctx, ubd)
        //                for _, entry := range ubd.Entries {
        //                    keeper.InsertUBDQueue(ctx, ubd, entry.CompletionTime)
        //                    notBondedTokens = notBondedTokens.Add(entry.Balance)
        //                }
        //            }
        //
        //            for _, red := range data.Redelegations {
        //                keeper.SetRedelegation(ctx, red)
        //                for _, entry := range red.Entries {
        //                    keeper.InsertRedelegationQueue(ctx, red, entry.CompletionTime)
        //                }
        //            }
        //
        //            bondedCoins := sdk.NewCoins(sdk.NewCoin(data.Params.BondDenom, bondedTokens))
        //            notBondedCoins := sdk.NewCoins(sdk.NewCoin(data.Params.BondDenom, notBondedTokens))
        //
        //            // check if the unbonded and bonded pools accounts exists
        //            bondedPool := keeper.GetBondedPool(ctx)
        //            if bondedPool == nil {
        //                panic(fmt.Sprintf("%s module account has not been set", types.BondedPoolName))
        //            }
        //
        //            // TODO remove with genesis 2-phases refactor https://github.com/cosmos/cosmos-sdk/issues/2862
        //            // add coins if not provided on genesis
        //            if bondedPool.GetCoins().IsZero() {
        //                if err := bondedPool.SetCoins(bondedCoins); err != nil {
        //                    panic(err)
        //                }
        //                supplyKeeper.SetModuleAccount(ctx, bondedPool)
        //            }
        //
        //            notBondedPool := keeper.GetNotBondedPool(ctx)
        //            if notBondedPool == nil {
        //                panic(fmt.Sprintf("%s module account has not been set", types.NotBondedPoolName))
        //            }
        //
        //            if notBondedPool.GetCoins().IsZero() {
        //                if err := notBondedPool.SetCoins(notBondedCoins); err != nil {
        //                    panic(err)
        //                }
        //                supplyKeeper.SetModuleAccount(ctx, notBondedPool)
        //            }
        //
        //            // don't need to run Tendermint updates if we exported
        //            if data.Exported {
        //                for _, lv := range data.LastValidatorPowers {
        //                    keeper.SetLastValidatorPower(ctx, lv.Address, lv.Power)
        //                    validator, found := keeper.GetValidator(ctx, lv.Address)
        //                    if !found {
        //                        panic(fmt.Sprintf("validator %s not found", lv.Address))
        //                    }
        //                    update := validator.ABCIValidatorUpdate()
        //                    update.Power = lv.Power // keep the next-val-set offset, use the last power for the first block
        //                    res = append(res, update)
        //                }
        //            } else {
        //                res = keeper.ApplyAndReturnValidatorSetUpdates(ctx)
        //            }
        //
        //            return res
        //        }

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
