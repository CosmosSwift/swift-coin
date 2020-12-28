public enum Error: Swift.Error {
    case invalidAddress(address: String)
    case unknownRequest(reason: String)
    case unauthorized(reason: String)
    case jsonMarshal(error: Swift.Error)
    case jsonUnmarshal(error: Swift.Error)
    case decodingError(reason: String)
    case insufficientFunds(reason: String)
    case invalidDenomination(denomination: String)
    case keyNotFound(key: String)
    case invalidGenesis(reason: String)
    case transactionDecode(reason: String)
    case invalidRequest(reason: String)
    case noSignatures
    case generic(reason: String)
    case unknownAddress(reason: String)
    case invalidCoins(reason: String)
    case sendDisabled
    case noInputs
    case noOutputs
    case inputOutputMismatch
}
