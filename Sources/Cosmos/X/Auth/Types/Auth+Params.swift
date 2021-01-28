extension AuthKeys {
    // DefaultParamspace defines the default auth module parameter subspace
    public static let defaultParamspace = moduleName
}

// Default parameter values
extension AuthParameters {
    static let defaultMaximumMemoCharacters: UInt64 = 256
    static let defaultTransactionSignatureLimit: UInt64 = 7
    static let defaultTransactionSizeCostPerByte: UInt64 = 10
    static let defaultSignatureVerifyCostEd25519: UInt64 = 590
    static let defaultSignatureVerifyCostSecp256k1: UInt64 = 1000
}

// Parameter keys
// TODO: Create a proper ParameterKey type
extension AuthKeys {
    static let maximumMemoCharacters = "MaxMemoCharacters".data
    static let transactionSignatureLimit = "TxSigLimit".data
    static let transactionSizeCostPerByte = "TxSizeCostPerByte".data
    static let signatureVerifyCostEd25519 = "SigVerifyCostED25519".data
    static let signatureVerifyCostSecp256k1 = "SigVerifyCostSecp256k1".data
}

// Params defines the parameters for the auth module.
public struct AuthParameters: ParameterSet, Codable {
    let maximumMemoCharacters: UInt64
    let transactionSignatureLimit: UInt64
    let transactionSizeCostPerByte: UInt64
    let signatureVerifyCostEd25519: UInt64
    let signatureVerifyCostSecp256k1: UInt64
    
    private enum CodingKeys: String, CodingKey {
        case maximumMemoCharacters = "max_memo_characters"
        case transactionSignatureLimit = "tx_sig_limit"
        case transactionSizeCostPerByte = "tx_size_cost_per_byte"
        case signatureVerifyCostEd25519 = "sig_verify_cost_ed25519"
        case signatureVerifyCostSecp256k1 = "sig_verify_cost_secp256k1"
    }
    
    // NewParams creates a new Params object
    init(
        maximumMemoCharacters: UInt64,
        transactionSignatureLimit: UInt64,
        transactionSizeCostPerByte: UInt64,
        signatureVerifyCostEd25519: UInt64,
        signatureVerifyCostSecp256k1: UInt64
    ) {
        self.maximumMemoCharacters = maximumMemoCharacters
        self.transactionSignatureLimit = transactionSignatureLimit
        self.transactionSizeCostPerByte = transactionSizeCostPerByte
        self.signatureVerifyCostEd25519 = signatureVerifyCostEd25519
        self.signatureVerifyCostSecp256k1 = signatureVerifyCostSecp256k1
    }
}

extension AuthParameters {
    // ParamSetPairs implements the ParamSet interface and returns all the key/value pairs
    // pairs of auth module's parameters.
    // nolint
    
    // TODO: remove Validate. we already have the correct type as part of the decoding.
   var parameterSetPairs: ParameterSetPairs {
        [
            ParameterSetPair(key: AuthKeys.maximumMemoCharacters, value: maximumMemoCharacters, validatorFunction: validateMaximumMemoCharacters),
            ParameterSetPair(key: AuthKeys.transactionSignatureLimit, value: transactionSignatureLimit, validatorFunction: validateTransactionSignatureLimit),
            ParameterSetPair(key: AuthKeys.transactionSizeCostPerByte, value: transactionSizeCostPerByte, validatorFunction: validateTransactionSizeCostPerByte),
            ParameterSetPair(key: AuthKeys.signatureVerifyCostEd25519, value: signatureVerifyCostEd25519, validatorFunction: validateSignatureVerifyCostED25519),
            ParameterSetPair(key: AuthKeys.signatureVerifyCostSecp256k1, value: signatureVerifyCostSecp256k1, validatorFunction: validateSignatureVerifyCostSecp256k1),
        ]
    }
}

extension AuthParameters {
    // DefaultParams returns a default set of parameters.
    static var `default`: AuthParameters {
        AuthParameters(
            maximumMemoCharacters: defaultMaximumMemoCharacters,
            transactionSignatureLimit: defaultTransactionSignatureLimit,
            transactionSizeCostPerByte: defaultTransactionSizeCostPerByte,
            signatureVerifyCostEd25519: defaultSignatureVerifyCostEd25519,
            signatureVerifyCostSecp256k1: defaultSignatureVerifyCostSecp256k1
        )
    }
}

func validateTransactionSignatureLimit(i: AnyEncodable) throws {
    
    guard let uint64 = i.value as? UInt64 else {
        fatalError("Invalid parameter type: \(i)")
    }
    
    if uint64 == 0 {
        fatalError("Invalid tx signature limit: \(uint64)")
    }
//    v, ok := i.(uint64)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v == 0 {
//        return fmt.Errorf("invalid tx signature limit: %d", v)
//    }
//
//    return nil
}

func validateSignatureVerifyCostED25519(i: AnyEncodable) throws {
    guard let uint64 = i.value as? UInt64 else {
        fatalError("Invalid parameter type: \(i)")
    }
    
    if uint64 == 0 {
        fatalError("Invalid ED25519 signature verification cost: \(uint64)")
    }
    //    v, ok := i.(uint64)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v == 0 {
//        return fmt.Errorf("invalid ED25519 signature verification cost: %d", v)
//    }
//
//    return nil
}

func validateSignatureVerifyCostSecp256k1(i: AnyEncodable) throws {
    guard let uint64 = i.value as? UInt64 else {
        fatalError("Invalid parameter type: \(i)")
    }
    
    if uint64 == 0 {
        fatalError("Invalid SECK256k1 signature verification cost: \(uint64)")
    }
//    v, ok := i.(uint64)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v == 0 {
//        return fmt.Errorf("invalid SECK256k1 signature verification cost: %d", v)
//    }
//
//    return nil
}

func validateMaximumMemoCharacters(i: AnyEncodable) throws {
    guard let uint64 = i.value as? UInt64 else {
        fatalError("Invalid parameter type: \(i)")
    }
    
    if uint64 == 0 {
        fatalError("Invalid max memo characters: \(uint64)")
    }
//    v, ok := i.(uint64)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v == 0 {
//        return fmt.Errorf("invalid max memo characters: %d", v)
//    }
//
//    return nil
}

func validateTransactionSizeCostPerByte(i: AnyEncodable) throws {
    guard let uint64 = i.value as? UInt64 else {
        fatalError("Invalid parameter type: \(i)")
    }
    
    if uint64 == 0 {
        fatalError("Invalid tx size cost per byte: \(uint64)")
    }
//    v, ok := i.(uint64)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v == 0 {
//        return fmt.Errorf("invalid tx size cost per byte: %d", v)
//    }
//
//    return nil
}
