extension BankKeys {
    // DefaultParamspace for params keeper
    public static let defaultParamspace = moduleName
    // DefaultSendEnabled enabled
    public static var defaultSendEnabled = true
}

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
         KeyTable(pairs: ParameterSetPair(
            key: paramStoreKeySendEnabled,
            value: false,
            validatorFunction: validateSendEnabled
         ))
    }
}
