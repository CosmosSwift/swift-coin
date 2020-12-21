
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
    
    public init(pairs: ParamSetPair...) {
        var keyTable = KeyTable(map: [:])

        for paramSetPair in pairs {
            keyTable.registerType(paramSetPair: paramSetPair)
        }

        self = keyTable
    }
    
    // RegisterType registers a single ParamSetPair (key-type pair) in a KeyTable.
    mutating func registerType(paramSetPair: ParamSetPair) {
        guard !paramSetPair.key.isEmpty else {
            fatalError("cannot register ParamSetPair with an parameter empty key")
        }
        
        guard paramSetPair.key.string.isAlphaNumeric else {
            fatalError("cannot register ParamSetPair with a non-alphanumeric parameter key")
        }
       
        let key = paramSetPair.key.string
        
        guard map[key] == nil else {
            fatalError("duplicate parameter key")
        }

        let type = Swift.type(of: paramSetPair.value)

        map[key] = Attribute(type: type, valueValidatorFunction: paramSetPair.validatorFunction)
    }
}
