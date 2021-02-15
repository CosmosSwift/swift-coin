import Cosmos

// KeyTable subspaces appropriate type for each parameter key
public struct KeyTable {
    struct Attribute {
        let type: Any.Type
        let valueValidatorFunction: ValueValidatorFunction
    }
    
    var map: [String: Attribute]
    
    init(map: [String: Attribute]) {
        self.map = map
    }
    
    public init(pairs: ParameterSetPairs) {
        var keyTable = KeyTable(map: [:])

        for paramSetPair in pairs {
            keyTable.registerType(parameterSetPair: paramSetPair)
        }

        self = keyTable
    }
    
    public init(pairs: ParameterSetPair...) {
        self.init(pairs: pairs)
    }
    
    // RegisterType registers a single ParamSetPair (key-type pair) in a KeyTable.
    mutating func registerType(parameterSetPair: ParameterSetPair) {
        guard !parameterSetPair.key.isEmpty else {
            fatalError("cannot register ParamSetPair with an parameter empty key")
        }
        
        guard parameterSetPair.key.string.isAlphaNumeric else {
            fatalError("cannot register ParamSetPair with a non-alphanumeric parameter key")
        }
       
        let key = parameterSetPair.key.string
        
        guard map[key] == nil else {
            fatalError("duplicate parameter key")
        }

        let type = Swift.type(of: parameterSetPair.value.value)
        map[key] = Attribute(type: type, valueValidatorFunction: parameterSetPair.validatorFunction)
    }
}
