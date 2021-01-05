import ABCI

extension CosmosError {
    // SuccessABCICode declares an ABCI response use 0 to signal that the
    // processing was successful and no error is returned.
    static let successABCICode = 0

    // All unclassified errors that do not provide an ABCI code are clubbed
    // under an internal error code and a generic message instead of
    // detailed error string.
    static let internalABCICodespace = undefinedCodespace
    static let internalABCICode: UInt32 = 1
}

// ABCIInfo returns the ABCI error information as consumed by the tendermint
// client. Returned codespace, code, and log message should be used as a ABCI response.
// Any error that does not provide ABCICode information is categorized as error
// with code 1, codespace UndefinedCodespace
// When not running in a debug mode all messages of errors that do not provide
// ABCICode information are replaced with generic "internal error". Errors
// without an ABCICode information as considered internal.
func abciInfo(error: Swift.Error, debug: Bool) -> (codespace: String, code: UInt32, log: String) {
    // TODO: Check if we really need this
//    if errIsNil(err) {
//        return "", SuccessABCICode, ""
//    }

    let encode: (Swift.Error) -> String
    
    if debug {
        encode = debugErrorEncoder
    } else {
        encode = defaultErrorEncoder
    }

    return (abciCodespace(error: error), abciCode(error: error), encode(error))
}


// ResponseCheckTx returns an ABCI ResponseCheckTx object with fields filled in
// from the given error and gas values.
extension ResponseCheckTx {
    init(
        error: Swift.Error,
        gasWanted: UInt64,
        gasUsed: UInt64,
        debug: Bool
    ) {
        let (codespace, code, log) = abciInfo(error: error, debug: debug)
        
        self.init(
            code: code,
            log: log,
            gasWanted: Int64(gasWanted),
            gasUsed: Int64(gasUsed),
            codespace: codespace
        )
    }
}

extension ResponseDeliverTx {
    // ResponseDeliverTx returns an ABCI ResponseDeliverTx object with fields filled in
    // from the given error and gas values.
    init(
        error: Swift.Error,
        gasWanted: UInt64,
        gasUsed: UInt64,
        debug: Bool
    ) {
        let (space, code, log) = abciInfo(error: error, debug: debug)
        
        self.init(
            code:      code,
            log:       log,
            gasWanted: Int64(gasWanted),
            gasUsed:   Int64(gasUsed),
            codespace: space
        )
    }
}

extension ResponseQuery {
    // QueryResult returns a ResponseQuery from an error. It will try to parse ABCI
    // info from the error.
    init(error: Swift.Error) {
        let (space, code, log) = abciInfo(error: error, debug: false)
        
        self.init(
            code: code,
            log: log,
            codespace: space
        )
    }
}



// The debugErrEncoder encodes the error with a stacktrace.
func debugErrorEncoder(error: Swift.Error) -> String {
    "\(error)"
}

// The defaultErrEncoder applies Redact on the error before encoding it with its internal error message.
func defaultErrorEncoder(error: Swift.Error) -> String {
    redact(error: error).localizedDescription
}

protocol ABCICoder {
    var abciCode: UInt32 { get }
}

// abciCode test if given error contains an ABCI code and returns the value of
// it if available. This function is testing for the causer interface as well
// and unwraps the error.
func abciCode(error: Swift.Error) -> UInt32 {
    // TODO: Check if it makes sense for us
//    if errIsNil(err) {
//        return SuccessABCICode
//    }
    var error = error
    
    while true {
        if let coder = error as? ABCICoder {
            return coder.abciCode
        }

        if let causer = error as? Causer {
            error = causer.cause
        } else {
            return CosmosError.internalABCICode
        }
    }
}

protocol Codespacer {
    var codespace: String { get }
}

// abciCodespace tests if given error contains a codespace and returns the value of
// it if available. This function is testing for the causer interface as well
// and unwraps the error.
func abciCodespace(error: Swift.Error) -> String {
    // TODO: Check if we need this
//    if errIsNil(err) {
//        return ""
//    }
    var error = error

    while true {
        if let codespacer = error as? Codespacer {
            return codespacer.codespace
        }
        
        if let causer = error as? Causer {
            error = causer.cause
        } else {
            return CosmosError.internalABCICodespace
        }
    }
}

// causer is an interface implemented by an error that supports wrapping. Use
// it to test if an error wraps another error instance.
protocol Causer {
    var cause: Swift.Error { get }
}

// Redact replace all errors that do not initialize with a weave error with a
// generic internal error instance. This function is supposed to hide
// implementation details errors and leave only those that weave framework
// originates.
func redact(error: Swift.Error) -> Swift.Error {
    // TODO: Check if this makes sense for us
//    if ErrPanic.Is(err) {
//        return ErrPanic
//    }
    
    if abciCode(error: error) == CosmosError.internalABCICode {
        return CosmosError.internal
    }
    
    return error
}

