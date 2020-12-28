extension StakingKeeper {
    // GetBondedPool returns the bonded tokens pool's module account
    func bondedPool(request: Request) -> ModuleAccount? {
        supplyKeeper.moduleAccount(
            request: request,
            moduleName: StakingKeys.bondedPoolName
        )
    }

    // GetNotBondedPool returns the not bonded tokens pool's module account
    func notBondedPool(request: Request) -> ModuleAccount? {
        supplyKeeper.moduleAccount(
            request: request,
            moduleName: StakingKeys.notBondedPoolName
        )
    }
//
//    // bondedTokensToNotBonded transfers coins from the bonded to the not bonded pool within staking
//    func bondedTokensToNotBonded(request: Request, tokens sdk.Int) {
//        coins := sdk.NewCoins(sdk.NewCoin(k.BondDenom(ctx), tokens))
//        err := k.supplyKeeper.SendCoinsFromModuleToModule(ctx, types.BondedPoolName, types.NotBondedPoolName, coins)
//        if err != nil {
//            panic(err)
//        }
//    }
//
//    // notBondedTokensToBonded transfers coins from the not bonded to the bonded pool within staking
//    func notBondedTokensToBonded(request: Request, tokens sdk.Int) {
//        coins := sdk.NewCoins(sdk.NewCoin(k.BondDenom(ctx), tokens))
//        err := k.supplyKeeper.SendCoinsFromModuleToModule(ctx, types.NotBondedPoolName, types.BondedPoolName, coins)
//        if err != nil {
//            panic(err)
//        }
//    }
//
//    // burnBondedTokens removes coins from the bonded pool module account
//    func burnBondedTokens(request: Request, amount: Int) error {
//        if !amt.IsPositive() {
//            // skip as no coins need to be burned
//            return nil
//        }
//        coins := sdk.NewCoins(sdk.NewCoin(k.BondDenom(ctx), amt))
//        return k.supplyKeeper.BurnCoins(ctx, types.BondedPoolName, coins)
//    }
//
//    // burnNotBondedTokens removes coins from the not bonded pool module account
//    func burnNotBondedTokens(request: Request, amount: Int) error {
//        if !amt.IsPositive() {
//            // skip as no coins need to be burned
//            return nil
//        }
//        coins := sdk.NewCoins(sdk.NewCoin(k.BondDenom(ctx), amt))
//        return k.supplyKeeper.BurnCoins(ctx, types.NotBondedPoolName, coins)
//    }
//
//    // TotalBondedTokens total staking tokens supply which is bonded
//    func TotalBondedTokens(request: Request) sdk.Int {
//        bondedPool := k.GetBondedPool(ctx)
//        return bondedPool.GetCoins().AmountOf(k.BondDenom(ctx))
//    }
//
//    // StakingTokenSupply staking tokens from the total supply
//    func StakingTokenSupply(request: Request) sdk.Int {
//        return k.supplyKeeper.GetSupply(ctx).GetTotal().AmountOf(k.BondDenom(ctx))
//    }
//
//    // BondedRatio the fraction of the staking tokens which are currently bonded
//    func BondedRatio(request: Request) sdk.Dec {
//        bondedPool := k.GetBondedPool(ctx)
//
//        stakeSupply := k.StakingTokenSupply(ctx)
//        if stakeSupply.IsPositive() {
//            return bondedPool.GetCoins().AmountOf(k.BondDenom(ctx)).ToDec().QuoInt(stakeSupply)
//        }
//        return sdk.ZeroDec()
//    }
}
