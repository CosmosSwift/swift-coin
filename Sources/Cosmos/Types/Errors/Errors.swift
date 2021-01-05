extension CosmosError {
    // RootCodespace is the codespace for all errors defined in this package
    static let rootCodespace = "sdk"

    // UndefinedCodespace when we explicitly declare no codespace
    static let undefinedCodespace = "undefined"
    
    // errInternal should never be exposed, but we reserve this code for non-specified errors
    //nolint
    static let `internal` = register(codespace: undefinedCodespace, code: 1, description: "internal")
    
    // ErrUnknownRequest to doc
    static let unknownRequest = register(codespace: rootCodespace, code: 6, description: "unknown request")

    // ErrOutOfGas to doc
    static let outOfGas = register(codespace: rootCodespace, code: 11, description: "out of gas")
    
    // ErrInvalidRequest defines an ABCI typed error where the request contains
    // invalid data.
    static let invalidRequest = register(codespace: rootCodespace, code: 18, description: "invalid request")

    // ErrPanic is only set when we recover from a panic, so we know to
    // redact potentially sensitive system info
    static let panic = register(codespace: undefinedCodespace, code: 111222, description: "panic")

}

struct CosmosError: Swift.Error, Equatable {
    let codespace: String
    let code: UInt32
    let description: String

    init(codespace: String, code: UInt32, description: String) {
        self.codespace = codespace
        self.code = code
        self.description = description
    }
    
    // usedCodes is keeping track of used codes to ensure their uniqueness. No two
    // error instances should share the same (codespace, code) tuple.
    static var usedCodes: [String: CosmosError] = [:]
    
    // Register returns an error instance that should be used as the base for
    // creating error instances during runtime.
    //
    // Popular root errors are declared in this package, but extensions may want to
    // declare custom codes. This function ensures that no error code is used
    // twice. Attempt to reuse an error code results in panic.
    //
    // Use this function only during a program startup phase.
    static func register(codespace: String, code: UInt32, description: String) -> CosmosError {
        if let error = getUsed(codespace: codespace, code: code) {
            fatalError("error with code \(code) is already registered: \(error.description)")
        }

        let error = CosmosError(codespace: codespace, code: code, description: description)
        setUsed(error: error)
        return error
    }

    static func errorID(codespace: String, code: UInt32) -> String {
        "\(codespace):\(code)"
    }

    static func getUsed(codespace: String, code: UInt32) -> CosmosError? {
        usedCodes[errorID(codespace: codespace, code: code)]
    }

    static func setUsed(error: CosmosError) {
        usedCodes[errorID(codespace: error.codespace, code: UInt32(error.code))] = error
    }
    
    // Wrap extends given error with an additional information.
    //
    // If the wrapped error does not provide ABCICode method (ie. stdlib errors),
    // it will be labeled as internal error.
    //
    // If err is nil, this returns nil, avoiding the need for an if statement when
    // wrapping a error returned at the end of a function
    static func wrap(error: Swift.Error, description: String) -> Swift.Error {
//        if err == nil {
//            return nil
//        }

        // TODO: Implement
//        // If this error does not carry the stacktrace information yet, attach
//        // one. This should be done only once per error at the lowest frame
//        // possible (most inner wrap).
//        if stackTrace(err) == nil {
//            err = errors.WithStack(err)
//        }

        return WrappedError(
            message: description,
            parent: error
        )
    }
    
    struct WrappedError: Swift.Error {
        // This error layer description.
        let message: String
        // The underlying error that triggered this one.
        let parent: Swift.Error
    }
}
