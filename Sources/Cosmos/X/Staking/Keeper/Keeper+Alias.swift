//_______________________________________________________________________
// Validator Set

extension StakingKeeper {
    // iterate through the validator set and perform the provided function
    func iterateValidators(request: Request, body: (_ index: Int64, _ validator: Validator) -> Bool) {
        // TODO: Implement
        fatalError()
//        let store = request.keyValueStore(key: storeKey)
//        let iterator = KeyValueStorePrefixIterator(store: store, key: ValidatorsKey)
//
//        defer {
//           iterator.close()
//        }
//
//        var i: Int64 = 0
//
//        while iterator.isValid {
//            defer {
//                iterator.next()
//            }
//
//            let validator = codec.mustUnmarshalValidator(iterator.value)
//
//            // XXX is this safe will the validator unexposed fields be able to get written to?
//            let stop = body(i, validator)
//
//            if stop {
//                break
//            }
//
//            i += 1
//        }
    }
}
