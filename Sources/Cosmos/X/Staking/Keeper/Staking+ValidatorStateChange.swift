import Foundation
import ABCI
import Database

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
        var validatorUpdates: [ValidatorUpdate] = []
        let maxValidators = self.parameters(request: request).maxValidators
        var totalPower = 0
        var amountFromBondedToNotBonded: UInt = 0
        var amountFromNotBondedToBonded: UInt = 0

        // Retrieve the last validator set.
        // The persistent set is updated later in this function.
        // (see LastValidatorPowerKey).
        var last = lastValidatorsByAddress(request: request)

        // Iterate over validators, highest power to lowest.
        var iterator = validatorsPowerStoreIterator(request: request)

        defer {
            iterator.close()
        }
        
        var count = 0

        while iterator.isValid && count < maxValidators {
            defer {
                iterator.next()
            }

            // everything that is iterated in this loop is becoming or already a
            // part of the bonded validator set

            let validatorAddress = ValidatorAddress(data: iterator.value)
            var validator = self.validator(request: request, address: validatorAddress)!

            if validator.jailed {
                fatalError("should never retrieve a jailed validator from the power store")
            }

            // if we get to a zero-power validator (which we don't bond),
            // there are no more possible bonded validators
            if validator.potentialConsensusPower == 0 {
                break
            }

            // apply the appropriate state change if necessary
            switch validator.status {
            case .unbonded:
                validator = unbondedToBonded(request: request, validator: validator)
                amountFromNotBondedToBonded += validator.tokens
            case .unbonding:
                validator = unbondingToBonded(request: request, validator: validator)
                amountFromNotBondedToBonded += validator.tokens
            case .bonded:
                // no state change
                break
            }

            // fetch the old power bytes
            var validatorAddressData = validatorAddress.data
            let oldPowerBytes = last[validatorAddressData]

            let newPower = validator.consensusPower
            let newPowerBytes = codec.mustMarshalBinaryLengthPrefixed(value: newPower)

            // update the validator set if power has changed
            if oldPowerBytes == nil || oldPowerBytes != newPowerBytes {
                validatorUpdates.append(validator.abciValidatorUpdate)
                
                setLastValidatorPower(
                    request: request,
                    operator: validatorAddress,
                    power: newPower
                )
            }

            last[validatorAddressData] = nil
            count += 1
            totalPower += Int(newPower)
        }

        let noLongerBonded = sortNoLongerBonded(last: last)
        
        for validatorAddressData in noLongerBonded {
            var validator = self.validator(
                request: request,
                address: ValidatorAddress(data: validatorAddressData)
            )!
            
            validator = bondedToUnbonding(request: request, validator: validator)
            amountFromBondedToNotBonded += validator.tokens
            deleteLastValidatorPower(request: request, operator: validator.operatorAddress)
            validatorUpdates.append(validator.abciValidatorUpdateZero)
        }

        // Update the pools based on the recent updates in the validator set:
        // - The tokens from the non-bonded candidates that enter the new validator set need to be transferred
        // to the Bonded pool.
        // - The tokens from the bonded validators that are being kicked out from the validator set
        // need to be transferred to the NotBonded pool.
        
        // Compare and subtract the respective amounts to only perform one transfer.
        // This is done in order to avoid doing multiple updates inside each iterator/loop.
        if amountFromNotBondedToBonded > amountFromBondedToNotBonded {
            notBondedTokensToBonded(
                request: request,
                tokens: amountFromNotBondedToBonded - amountFromBondedToNotBonded
            )
        } else if amountFromNotBondedToBonded < amountFromBondedToNotBonded {
            bondedTokensToNotBonded(
                request: request,
                tokens: amountFromBondedToNotBonded - amountFromNotBondedToBonded
            )
        } else {
            // equal amounts of tokens; no update required
        }

        // set total power on lookup index if there are any updates
        if !validatorUpdates.isEmpty {
            setLastTotalPower(request: request, power: totalPower)
        }

        return validatorUpdates
    }
    
    // Validator state transitions

    func bondedToUnbonding(request: Request, validator: Validator) -> Validator {
        guard validator.isBonded else {
            fatalError("bad state transition bondedToUnbonding, validator: \(validator)\n")
        }
        
        return beginUnbondingValidator(request: request, validator: validator)
    }

    func unbondingToBonded(request: Request, validator: Validator) -> Validator {
        guard validator.isUnbonding else {
            fatalError("bad state transition unbondingToBonded, validator: \(validator)\n")
        }
        
        // TODO: Implement
        fatalError()
//        return bondValidator(request: request, validator: validator)
    }

    func unbondedToBonded(request: Request, validator: Validator) -> Validator {
        guard validator.isUnbonded else {
            fatalError("bad state transition unbondedToBonded, validator: \(validator)\n")
        }
       
        // TODO: Implement
        fatalError()
//        return bondValidator(request: request, validator: validator)
    }

    // switches a validator from unbonding state to unbonded state
    func unbondingToUnbonded(request: Request, validator: Validator) -> Validator {
        guard validator.isUnbonding else {
            fatalError("bad state transition unbondingToBonded, validator: \(validator)\n")
        }
        
        // TODO: Implement
        fatalError()
//        return completeUnbondingValidator(request: request, validator: validator)
    }

    // returns an iterator for the consensus validators in the last block
    func lastValidatorsIterator(request: Request) -> Iterator {
        // TODO: Implement
        fatalError()
//        let store = request.keyValueStore(key: storeKey)
//        let iterator = KeyValueStorePrefixIterator(store, lastValidatorPowerKey)
//        return iterator
    }
    
    // perform all the store operations for when a validator begins unbonding
    func beginUnbondingValidator(request: Request, validator: Validator) -> Validator {
        let parameters = self.parameters(request: request)

        // delete the validator by power index, as the key will change
        deleteValidatorByPowerIndex(request: request, validator: validator)

        // sanity check
        if validator.status != .bonded {
            fatalError("should not already be unbonded or unbonding, validator: \(validator)\n")
        }

        var validator = validator
        validator.status = .unbonding

        // set the unbonding completion time and completion height appropriately
        validator.unbondingCompletionTime = request.header.time + parameters.unbondingTime
        validator.unbondingHeight = request.header.height

        // save the now unbonded validator record and power index
        setValidator(request: request, validator: validator)
        setValidatorByPowerIndex(request: request, validator: validator)

        // Adds to unbonding validator queue
        insertValidatorQueue(request: request, validator: validator)

        // trigger hook
        afterValidatorBeginUnbonding(
            request: request,
            consensusAddress: validator.consensusAddress,
            validatorAddress: validator.operatorAddress
        )
        
        return validator
    }


    // map of operator addresses to serialized power
    typealias ValidatorsByAddress = [Data: Data]

    // get the last validator set
    func lastValidatorsByAddress(request: Request) -> ValidatorsByAddress {
        var last: ValidatorsByAddress = [:]
        var iterator = lastValidatorsIterator(request: request)
        
        defer {
            iterator.close()
        }

        while iterator.isValid {
            defer {
                iterator.next()
            }
            
            // extract the validator address from the key (prefix is 1-byte)
            let validatorAddress = iterator.key.suffix(from: 1)
            last[validatorAddress] = iterator.value
        }
        
        return last
    }
    
    // given a map of remaining validators to previous bonded power
    // returns the list of validators to be unbonded, sorted by operator address
    func sortNoLongerBonded(last: ValidatorsByAddress) -> [Data] {
        // sort the map keys for determinism
        last.sorted { lhs, rhs in
            lhs.key.hexEncodedString() < rhs.key.hexEncodedString()
        }
        .map(\.value)
    }
}
