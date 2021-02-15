import Cosmos

extension StakingKeeper {
    // RegisterInvariants registers all staking invariants
    func registerInvariants(in invariantRegistry: InvariantRegistry) {
        invariantRegistry.registerRoute(
            moduleName: StakingKeys.moduleName,
            route: "module-accounts",
            invariant: moduleAccountInvariants
        )
        
        invariantRegistry.registerRoute(
            moduleName: StakingKeys.moduleName,
            route: "nonnegative-power",
            invariant: nonNegativePowerInvariant
        )
        
        invariantRegistry.registerRoute(
            moduleName: StakingKeys.moduleName,
            route: "positive-delegation",
            invariant: positiveDelegationInvariant
        )
        
        invariantRegistry.registerRoute(
            moduleName: StakingKeys.moduleName,
            route: "delegator-shares",
            invariant: delegatorSharesInvariant
        )
    }

    // ModuleAccountInvariants checks that the bonded and notBonded ModuleAccounts pools
    // reflects the tokens actively bonded and not bonded
    func moduleAccountInvariants(_ request: Request) -> (String, Bool) {
        // TODO: Implement
        fatalError()
//        var bonded = 0
//        var notBonded = 0
//        var bondedPool = self.bondedPool(request: request)
//        var notBondedPool = self.notBondedPool(request: request)
//        var bondDenominations = self.bondDenomination(request: request)
//
//        iterateValidators(request: request) { _, validator in
//            switch validator.status {
//            case .bonded:
//                bonded = bonded + validator.tokens
//            case .unbonding, .unbonded:
//                notBonded = notBonded + validator.tokens
//            default:
//                fatalError("invalid validator status")
//            }
//            return false
//        }
//
//        iterateUnbondingDelegations(request: request) { _, unbondingDelegations in
//            for entry in unbondingDelegations.entries {
//                notBonded = notBonded + entry.balance
//            }
//
//            return false
//        }
//
//        let poolBonded = bondedPool.coins.amount(of: bondDenomination)
//        let poolNotBonded = notBondedPool.coins.amount(of: bondDenomination)
//        let broken = poolBonded != bonded) || poolNotBonded != notBonded
//
//        // Bonded tokens should equal sum of tokens with bonded validators
//        // Not-bonded tokens should equal unbonding delegations    plus tokens on unbonded validators
//        return formatInvariant(
//            types.ModuleName,
//            "bonded and not bonded module account coins",
//            fmt.Sprintf(
//            "\tPool's bonded tokens: %v\n"+
//                "\tsum of bonded tokens: %v\n"+
//                "not bonded token invariance:\n"+
//                "\tPool's not bonded tokens: %v\n"+
//                "\tsum of not bonded tokens: %v\n"+
//                "module accounts total (bonded + not bonded):\n"+
//                "\tModule Accounts' tokens: %v\n"+
//                "\tsum tokens:              %v\n",
//            poolBonded, bonded, poolNotBonded, notBonded, poolBonded.Add(poolNotBonded), bonded.Add(notBonded))),
//            broken
    }

    // NonNegativePowerInvariant checks that all stored validators have >= 0 power.
    func nonNegativePowerInvariant(_ request: Request) -> (String, Bool) {
        // TODO: Implement
        fatalError()
//        return func(ctx sdk.Context) (string, bool) {
//            var msg string
//            var broken bool
//
//            iterator := k.ValidatorsPowerStoreIterator(ctx)
//
//            for ; iterator.Valid(); iterator.Next() {
//                validator, found := k.GetValidator(ctx, iterator.Value())
//                if !found {
//                    panic(fmt.Sprintf("validator record not found for address: %X\n", iterator.Value()))
//                }
//
//                powerKey := types.GetValidatorsByPowerIndexKey(validator)
//
//                if !bytes.Equal(iterator.Key(), powerKey) {
//                    broken = true
//                    msg += fmt.Sprintf("power store invariance:\n\tvalidator.Power: %v"+
//                        "\n\tkey should be: %v\n\tkey in store: %v\n",
//                        validator.GetConsensusPower(), powerKey, iterator.Key())
//                }
//
//                if validator.Tokens.IsNegative() {
//                    broken = true
//                    msg += fmt.Sprintf("\tnegative tokens for validator: %v\n", validator)
//                }
//            }
//            iterator.Close()
//            return sdk.FormatInvariant(types.ModuleName, "nonnegative power", fmt.Sprintf("found invalid validator powers\n%s", msg)), broken
//        }
    }

    // PositiveDelegationInvariant checks that all stored delegations have > 0 shares.
    func positiveDelegationInvariant(_ request: Request) -> (String, Bool) {
        // TODO: Implement
        fatalError()
//        return func(ctx sdk.Context) (string, bool) {
//            var msg string
//            var count int
//
//            delegations := k.GetAllDelegations(ctx)
//            for _, delegation := range delegations {
//                if delegation.Shares.IsNegative() {
//                    count++
//                    msg += fmt.Sprintf("\tdelegation with negative shares: %+v\n", delegation)
//                }
//                if delegation.Shares.IsZero() {
//                    count++
//                    msg += fmt.Sprintf("\tdelegation with zero shares: %+v\n", delegation)
//                }
//            }
//            broken := count != 0
//
//            return sdk.FormatInvariant(types.ModuleName, "positive delegations", fmt.Sprintf(
//                "%d invalid delegations found\n%s", count, msg)), broken
//        }
    }

    // DelegatorSharesInvariant checks whether all the delegator shares which persist
    // in the delegator object add up to the correct total delegator shares
    // amount stored in each validator.
    func delegatorSharesInvariant(_ request: Request) -> (String, Bool) {
        // TODO: Implement
        fatalError()
//        return func(ctx sdk.Context) (string, bool) {
//            var msg string
//            var broken bool
//
//            validators := k.GetAllValidators(ctx)
//            for _, validator := range validators {
//
//                valTotalDelShares := validator.GetDelegatorShares()
//
//                totalDelShares := sdk.ZeroDec()
//                delegations := k.GetValidatorDelegations(ctx, validator.GetOperator())
//                for _, delegation := range delegations {
//                    totalDelShares = totalDelShares.Add(delegation.Shares)
//                }
//
//                if !valTotalDelShares.Equal(totalDelShares) {
//                    broken = true
//                    msg += fmt.Sprintf("broken delegator shares invariance:\n"+
//                        "\tvalidator.DelegatorShares: %v\n"+
//                        "\tsum of Delegator.Shares: %v\n", valTotalDelShares, totalDelShares)
//                }
//            }
//            return sdk.FormatInvariant(types.ModuleName, "delegator shares", msg), broken
//        }
    }
}
