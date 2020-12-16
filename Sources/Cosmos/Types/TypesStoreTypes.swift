// TODO: Create this in the proper module, if needed.
public struct KeyValuePair {}

// StoreDecoderRegistry defines each of the modules store decoders. Used for ImportExport
// simulation.
public typealias StoreDecoderRegistry = [String: (_ codec: Codec, _ keyValuePairA: KeyValuePair, _ keyValuePairB: KeyValuePair) -> String]

// TODO: Maybe a typealias is not the best option for this.
public typealias KeyValueStoreKeys = [String: KeyValueStoreKey]

// NewKVStoreKeys returns a map of new  pointers to KVStoreKey's.
// Uses pointers so keys don't collide.
extension KeyValueStoreKeys {
    public init(_ names: String...) {
        self.init(uniqueKeysWithValues: names.map({ ($0, KeyValueStoreKey(name: $0)) }))
    }
}


// TODO: Maybe a typealias is not the best option for this.
public typealias TransientStoreKeys = [String: TransientStoreKey]

// NewTransientStoreKeys constructs a new map of TransientStoreKey's
// Must return pointers according to the ocap principle
extension TransientStoreKeys {
    public init(_ names: String...) {
        self.init(uniqueKeysWithValues: names.map({ ($0, TransientStoreKey(name: $0)) }))
    }
}
