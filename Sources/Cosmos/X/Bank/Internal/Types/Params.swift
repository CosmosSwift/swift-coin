import Cosmos

extension KeyTable {
    // ParamStoreKeySendEnabled is store's key for SendEnabled
    static let paramStoreKeySendEnabled = "sendenabled".data
    
    static func validateSendEnabled(value: Any) throws {
        guard value is Bool else {
            throw Cosmos.Error.generic(reason: "invalid parameter type: \(value)")
        }
    }


    // ParamKeyTable type declaration for parameters
    public static func paramKeyTable() -> KeyTable {
         KeyTable(pairs: ParamSetPair(
            key: paramStoreKeySendEnabled,
            value: false,
            validatorFunction: validateSendEnabled
         ))
    }
}
