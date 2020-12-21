// Keeper of the global paramstore
public final class ParamsKeeper {
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
        guard spaces[subspace] == nil else {
            fatalError("subspace already occupied")
        }
        
        guard !subspace.isEmpty else {
            fatalError("cannot use empty string for subspace")
        }
        
        let space = Subspace(
            codec: codec,
            key: key,
            transientKey: transientKey,
            name: subspace
        )
        
        spaces[subspace] = space
        return space
    }

}
