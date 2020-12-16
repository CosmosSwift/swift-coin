import Foundation

public enum ParamsKeys {
    // StoreKey is the string store key for the param store
    public static let storeKey = "params"

    // TStoreKey is the string store key for the param transient store
    public static let transientStoreKey = "transient_" + storeKey
}

// Individual parameter store for each keeper
// Transient store persists for a block, so we use it for
// recording whether the parameter has been changed or not
public struct Subspace {
    let codec: Codec
    let key: StoreKey // []byte -> []byte, stores parameter
    let tkey: StoreKey // []byte -> bool, stores parameter change
    let name: Data
    var table: KeyTable
    
    // WithKeyTable initializes KeyTable and returns modified Subspace
    public func with(keyTable: KeyTable) -> Subspace {
        var copy = self
        // TODO: This used to be a nil check.
        // Maybe map really can be nil
        if keyTable.map.isEmpty {
            fatalError("SetKeyTable() called with nil KeyTable")
        }
        
        if !copy.table.map.isEmpty {
            fatalError("SetKeyTable() called on already initialized Subspace")
        }

        for (key, value) in table.map {
            copy.table.map[key] = value
        }

        return copy
    }

}
