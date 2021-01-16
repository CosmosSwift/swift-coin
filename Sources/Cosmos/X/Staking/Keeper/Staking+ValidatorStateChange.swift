import ABCI

extension StakingKeeper {
    // Apply and return accumulated updates to the bonded validator set. Also,
    // * Updates the active valset as keyed by LastValidatorPowerKey.
    // * Updates the total power as keyed by LastTotalPowerKey.
    // * Updates validator status' according to updated powers.
    // * Updates the fee pool bonded vs not-bonded tokens.
    // * Updates relevant indices.
    // It gets called once after genesis, another time maybe after genesis transactions,
    // then once at every EndBlock.
    //
    // CONTRACT: Only validators with non-zero power or zero-power that were bonded
    // at the previous block height or were removed from the validator set entirely
    // are returned to Tendermint.
    func applyAndReturnValidatorSetUpdates(request: Request) -> [ValidatorUpdate] {
        // TODO: Implement
        fatalError()
//        let maxValidators = self.parameters(request: request).maxValidators
//        var totalPower = 0
//        var amountFromBondedToNotBonded = 0
//        var amountFromNotBondedToBonded = 0
//
//        // Retrieve the last validator set.
//        // The persistent set is updated later in this function.
//        // (see LastValidatorPowerKey).
//        let last = lastValidatorsByAddress(request: request)
//
//        // Iterate over validators, highest power to lowest.
//        let iterator = validatorsPowerStoreIterator(request: request)
//
//        defer {
//            iterator.close()
//        }
//
//        for count := 0; iterator.Valid() && count < int(maxValidators); iterator.Next() {
//
//            // everything that is iterated in this loop is becoming or already a
//            // part of the bonded validator set
//
//            valAddr := sdk.ValAddress(iterator.Value())
//            validator := k.mustGetValidator(ctx, valAddr)
//
//            if validator.Jailed {
//                panic("should never retrieve a jailed validator from the power store")
//            }
//
//            // if we get to a zero-power validator (which we don't bond),
//            // there are no more possible bonded validators
//            if validator.PotentialConsensusPower() == 0 {
//                break
//            }
//
//            // apply the appropriate state change if necessary
//            switch {
//            case validator.IsUnbonded():
//                validator = k.unbondedToBonded(ctx, validator)
//                amtFromNotBondedToBonded = amtFromNotBondedToBonded.Add(validator.GetTokens())
//            case validator.IsUnbonding():
//                validator = k.unbondingToBonded(ctx, validator)
//                amtFromNotBondedToBonded = amtFromNotBondedToBonded.Add(validator.GetTokens())
//            case validator.IsBonded():
//                // no state change
//            default:
//                panic("unexpected validator status")
//            }
//
//            // fetch the old power bytes
//            var valAddrBytes [sdk.AddrLen]byte
//            copy(valAddrBytes[:], valAddr[:])
//            oldPowerBytes, found := last[valAddrBytes]
//
//            newPower := validator.ConsensusPower()
//            newPowerBytes := k.cdc.MustMarshalBinaryLengthPrefixed(newPower)
//
//            // update the validator set if power has changed
//            if !found || !bytes.Equal(oldPowerBytes, newPowerBytes) {
//                updates = append(updates, validator.ABCIValidatorUpdate())
//                k.SetLastValidatorPower(ctx, valAddr, newPower)
//            }
//
//            delete(last, valAddrBytes)
//
//            count++
//            totalPower = totalPower.Add(sdk.NewInt(newPower))
//        }
//
//        noLongerBonded := sortNoLongerBonded(last)
//        for _, valAddrBytes := range noLongerBonded {
//
//            validator := k.mustGetValidator(ctx, sdk.ValAddress(valAddrBytes))
//            validator = k.bondedToUnbonding(ctx, validator)
//            amtFromBondedToNotBonded = amtFromBondedToNotBonded.Add(validator.GetTokens())
//            k.DeleteLastValidatorPower(ctx, validator.GetOperator())
//            updates = append(updates, validator.ABCIValidatorUpdateZero())
//        }
//
//        // Update the pools based on the recent updates in the validator set:
//        // - The tokens from the non-bonded candidates that enter the new validator set need to be transferred
//        // to the Bonded pool.
//        // - The tokens from the bonded validators that are being kicked out from the validator set
//        // need to be transferred to the NotBonded pool.
//        switch {
//        // Compare and subtract the respective amounts to only perform one transfer.
//        // This is done in order to avoid doing multiple updates inside each iterator/loop.
//        case amtFromNotBondedToBonded.GT(amtFromBondedToNotBonded):
//            k.notBondedTokensToBonded(ctx, amtFromNotBondedToBonded.Sub(amtFromBondedToNotBonded))
//        case amtFromNotBondedToBonded.LT(amtFromBondedToNotBonded):
//            k.bondedTokensToNotBonded(ctx, amtFromBondedToNotBonded.Sub(amtFromNotBondedToBonded))
//        default:
//            // equal amounts of tokens; no update required
//        }
//
//        // set total power on lookup index if there are any updates
//        if len(updates) > 0 {
//            k.SetLastTotalPower(ctx, totalPower)
//        }
//
//        return updates
    }
}
