// TODO: Create this in the proper module, if needed.
public struct KeyValuePair {}

// StoreDecoderRegistry defines each of the modules store decoders. Used for ImportExport
// simulation.
public typealias StoreDecoderRegistry = [String: (_ codec: Codec, _ keyValuePairA: KeyValuePair, _ keyValuePairB: KeyValuePair) -> String]
