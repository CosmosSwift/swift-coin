struct KeyTableAttribute {
    let type: Any.Type
    let valueValidatorFunction: ValueValidatorFunction
}

// KeyTable subspaces appropriate type for each parameter key
public struct KeyTable {
    var map: [String: KeyTableAttribute]
    
    init(map: [String: KeyTableAttribute]) {
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
        // TODO: Implement
        fatalError()
//        if len(psp.Key) == 0 {
//            panic("cannot register ParamSetPair with an parameter empty key")
//        }
//        if !sdk.IsAlphaNumeric(string(psp.Key)) {
//            panic("cannot register ParamSetPair with a non-alphanumeric parameter key")
//        }
//        if psp.ValidatorFn == nil {
//            panic("cannot register ParamSetPair without a value validation function")
//        }
//
//        keystr := string(psp.Key)
//        if _, ok := t.m[keystr]; ok {
//            panic("duplicate parameter key")
//        }
//
//        rty := reflect.TypeOf(psp.Value)
//
//        // indirect rty if it is a pointer
//        if rty.Kind() == reflect.Ptr {
//            rty = rty.Elem()
//        }
//
//        t.m[keystr] = attribute{
//            vfn: psp.ValidatorFn,
//            ty:  rty,
//        }
//
//        return t
    }


}
