// Keeper of the global paramstore
public struct ParamsKeeper {
    // TODO: Implement
    let codec: Codec
    let key: StoreKey
    let transientKey: StoreKey
    var spaces: [String: Subspace] = [:]
    
    public init(
        codec: Codec,
        key: StoreKey,
        transientKey: StoreKey
    ) {
        self.codec = codec
        self.key = key
        self.transientKey = transientKey
    }
    
    // Allocate subspace used for keepers
    public func subspace(_ subspace: String) -> Subspace {
        // TODO: Implement
        fatalError()
//        _, ok := k.spaces[s]
//        if ok {
//            panic("subspace already occupied")
//        }
//
//        if s == "" {
//            panic("cannot use empty string for subspace")
//        }
//
//        space := subspace.NewSubspace(k.cdc, k.key, k.tkey, s)
//        k.spaces[s] = &space
//
//        return space
    }

}
