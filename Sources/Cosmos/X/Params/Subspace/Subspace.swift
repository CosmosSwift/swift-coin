import Foundation

public enum ParamsKeys {
    // StoreKey is the string store key for the param store
    public static let storeKey = "params"

    // TStoreKey is the string store key for the param transient store
    public static let transientStoreKey = "transient_" + storeKey
    
    // ModuleName defines the name of the module
    public static let moduleName = "params"

    // RouterKey defines the routing key for a ParameterChangeProposal
    public static let routerKey = "params"

    // ProposalTypeChange defines the type for a ParameterChangeProposal
    public static let proposalTypeChange = "ParameterChange"
}

// Individual parameter store for each keeper
// Transient store persists for a block, so we use it for
// recording whether the parameter has been changed or not
public struct Subspace {
    let codec: Codec
    let key: StoreKey // []byte -> []byte, stores parameter
    let transientKey: StoreKey // []byte -> bool, stores parameter change
    let name: Data
    var table: KeyTable
    
    init(
        codec: Codec,
        key: StoreKey,
        transientKey: StoreKey,
        name: String
    ) {
        self.codec = codec
        self.key = key
        self.transientKey = transientKey
        self.name = name.data
        self.table = KeyTable()
    }

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
    
    // Returns a KVStore identical with ctx.KVStore(s.key).Prefix()
    func keyValueStore(request: Request) -> KeyValueStore {
        // append here is safe, appends within a function won't cause
        // weird side effects when its singlethreaded
        PrefixStore(
            parent: request.keyValueStore(key: key),
            prefix: name + "/".data
        )
    }

    // Get queries for a parameter by key from the Subspace's KVStore and sets the
    // value to the provided pointer. If the value does not exist, it will panic.
    func get<T: Decodable>(request: Request, key: Data) -> T {
        let store = keyValueStore(request: request)
        // TODO: Check this force unwrap!
        let data = store.get(key: key)!

        do {
            return try codec.unmarshalJSON(data: data)
        } catch {
            fatalError("\(error)")
        }
    }
}