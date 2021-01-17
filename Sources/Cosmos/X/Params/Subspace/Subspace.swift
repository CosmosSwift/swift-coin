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
    // []byte -> []byte, stores parameter
    let key: StoreKey
    // []byte -> bool, stores parameter change
    let transientKey: StoreKey
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

        for (key, value) in keyTable.map {
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
    
    // Returns a transient store for modification
    func transientStore(request: Request) -> KeyValueStore {
        // append here is safe, appends within a function won't cause
        // weird side effects when its singlethreaded
        PrefixStore(
            parent: request.transientStore(key: transientKey),
            prefix: name + "/".data
        )
    }

    // Get queries for a parameter by key from the Subspace's KVStore and sets the
    // value to the provided pointer. If the value does not exist, it will panic.
    func get<T: Decodable>(request: Request, key: Data) -> T {
        let store = keyValueStore(request: request)
        // TODO: Check this force unwrap!
        let data = store.get(key: key)!

        return try! codec.unmarshalJSON(data: data)
    }
    
    // checkType verifies that the provided key and value are compatible and registered.
    func checkType(key: Data, value: Any) {
        guard let attribute = table.map[key.string] else {
            fatalError("parameter \(key.string) not registered")
        }

        let registeredType = attribute.type
        let valueType: Any.Type
        
        if let encodable = value as? AnyEncodable {
            valueType = Swift.type(of: encodable.value)
        } else {
            valueType = Swift.type(of: value)
        }

        if registeredType != valueType {
            fatalError("type mismatch with registered table")
        }
    }

    
    // Set stores a value for given a parameter key assuming the parameter type has
    // been registered. It will panic if the parameter type has not been registered
    // or if the value cannot be encoded. A change record is also set in the Subspace's
    // transient KVStore to mark the parameter as modified.
    func set<T: Encodable>(request: Request, key: Data, value: T) {
        checkType(key: key, value: value)
        let store = keyValueStore(request: request)

        let data = try! codec.marshalJSON(value: value)
        store.set(key: key, value: data)

        let transientStore = self.transientStore(request: request)
        transientStore.set(key: key, value: Data())
    }

    // SetParamSet iterates through each ParamSetPair and sets the value with the
    // corresponding parameter key in the Subspace's KVStore.
    func setParameterSet(request: Request, parameterSet: ParameterSet) {
        for pair in parameterSet.parameterSetPairs {
            // pair.Field is a pointer to the field, so indirecting the ptr.
            // go-amino automatically handles it but just for sure,
            // since SetStruct is meant to be used in InitGenesis
            // so this method will not be called frequently
            let value = pair.value

            do {
                try pair.validatorFunction(value)
            } catch {
                fatalError("value from ParamSetPair is invalid: \(error)")
            }
            
            set(request: request, key: pair.key, value: value)
        }
    }
}
