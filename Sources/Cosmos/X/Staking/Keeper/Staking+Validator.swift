import Foundation
import Database

extension StakingKeeper {
    // get a single validator
    func validator(request: Request, address: ValidatorAddress) -> Validator? {
        let store = request.keyValueStore(key: storeKey)
        
        guard let value = store.get(key: validatorKey(operatorAddress: address)) else {
            return nil
        }
        
        // TODO: Implement
        fatalError()
//        // If these amino encoded bytes are in the cache, return the cached validator
//        let stringValue := string(value)
//
//        if val, ok := k.validatorCache[strValue]; ok {
//            valToReturn := val.val
//            // Doesn't mutate the cache's value
//            valToReturn.OperatorAddress = addr
//            return valToReturn, true
//        }
//
//        // amino bytes weren't found in cache, so amino unmarshal and add it to the cache
//        validator = types.MustUnmarshalValidator(k.cdc, value)
//        cachedVal := newCachedValidator(validator, strValue)
//        k.validatorCache[strValue] = newCachedValidator(validator, strValue)
//        k.validatorCacheList.PushBack(cachedVal)
//
//        // if the cache is too big, pop off the last element from it
//        if k.validatorCacheList.Len() > aminoCacheSize {
//            valToRemove := k.validatorCacheList.Remove(k.validatorCacheList.Front()).(cachedValidator)
//            delete(k.validatorCache, valToRemove.marshalled)
//        }
//
//        validator = types.MustUnmarshalValidator(k.cdc, value)
//        return validator, true
    }

    // set the main record holding validator details
    func setValidator(request: Request, validator: Validator) {
        let store = request.keyValueStore(key: storeKey)
        let data = codec.mustMarshalBinaryLengthPrefixed(value: validator)
        
        store.set(
            key: validatorKey(operatorAddress: validator.operatorAddress),
            value: data
        )
    }
    
    // validator index
    func setValidatorByConsensusAddress(request: Request, validator: Validator) {
        let store = request.keyValueStore(key: storeKey)
        let consensusAddress = ConsensusAddress(data: validator.consensusPublicKey.address.rawValue)
        
        store.set(
            key: validatorByConsensusAddressKey(consensusAddress: consensusAddress),
            value: validator.operatorAddress.data
        )
    }
    
    // validator index
    func setValidatorByPowerIndex(request: Request, validator: Validator) {
        // jailed validators are not kept in the power index
        if validator.jailed {
            return
        }
        
        let store = request.keyValueStore(key: storeKey)
        store.set(
            key: validatorsByPowerIndexKey(validator: validator),
            value: validator.operatorAddress.data
        )
    }
    
    // validator index
    func deleteValidatorByPowerIndex(request: Request, validator: Validator) {
        let store = request.keyValueStore(key: storeKey)
        store.delete(key: validatorsByPowerIndexKey(validator: validator))
    }

    // returns an iterator for the current validator power store
    func validatorsPowerStoreIterator(request: Request) -> Iterator {
        // TODO: Implement
        //fatalError()
        let store = request.keyValueStore(key: storeKey)
        return store.reversePrefixIterator(prefix: validatorsByPowerIndexKey) //KeyValueStoreReversePrefixIterator(store, validatorsByPowerIndexKey)
    }

}

//_______________________________________________________________________
// Last Validator Index

extension StakingKeeper {
    // Set the last validator power.
    func setLastValidatorPower(request: Request, operator: ValidatorAddress, power: Int64) {
        let store = request.keyValueStore(key: storeKey)
        let data = codec.mustMarshalBinaryLengthPrefixed(value: power)
        
        store.set(
            key: lastValidatorPowerKey(operator: `operator`),
            value: data
        )
    }
    
    // Delete the last validator power.
    func deleteLastValidatorPower(request: Request, operator: ValidatorAddress) {
        let store = request.keyValueStore(key: storeKey)
        store.delete(key: lastValidatorPowerKey(operator: `operator`))
    }
}


    // get the group of the bonded validators
    func getLastValidators(request: Request) -> [Validator] {
            fatalError()
    //        store := ctx.KVStore(k.storeKey)
    //
    //        // add the actual validator power sorted store
    //        maxValidators := k.MaxValidators(ctx)
    //        validators = make([]types.Validator, maxValidators)
    //
    //        iterator := sdk.KVStorePrefixIterator(store, types.LastValidatorPowerKey)
    //        defer iterator.Close()
    //
    //        i := 0
    //        for ; iterator.Valid(); iterator.Next() {
    //
    //            // sanity check
    //            if i >= int(maxValidators) {
    //                panic("more validators than maxValidators found")
    //            }
    //            address := types.AddressFromLastValidatorPowerKey(iterator.Key())
    //            validator := k.mustGetValidator(ctx, address)
    //
    //            validators[i] = validator
    //            i++
    //        }
    //        return validators[:i] // trim
        }

//_______________________________________________________________________
// Validator Queue

extension StakingKeeper {
    // gets a specific validator queue timeslice. A timeslice is a slice of ValAddresses corresponding to unbonding validators
    // that expire at a certain time.
    func validatorQueueTimeSlice(request: Request, timestamp: Date) -> [ValidatorAddress] {
        let store = request.keyValueStore(key: storeKey)
        
        guard let data = store.get(key: validatorQueueTimeKey(timestamp: timestamp)) else {
            return []
        }
        
        return codec.mustUnmarshalBinaryLengthPrefixed(data: data)
    }

    // Sets a specific validator queue timeslice.
    func setValidatorQueueTimeSlice(request: Request, timestamp: Date, keys: [ValidatorAddress]) {
        let store = request.keyValueStore(key: storeKey)
        let data = codec.mustMarshalBinaryLengthPrefixed(value: keys)
        
        store.set(
            key: validatorQueueTimeKey(timestamp: timestamp),
            value: data
        )
    }

    // Insert an validator address to the appropriate timeslice in the validator queue
    func insertValidatorQueue(request: Request, validator: Validator) {
        var timeSlice = validatorQueueTimeSlice(request: request, timestamp: validator.unbondingCompletionTime)
        timeSlice.append(validator.operatorAddress)
        
        setValidatorQueueTimeSlice(
            request: request,
            timestamp: validator.unbondingCompletionTime,
            keys: timeSlice
        )
    }


}

