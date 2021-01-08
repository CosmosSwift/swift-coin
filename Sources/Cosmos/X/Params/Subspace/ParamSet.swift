import Foundation

public typealias ValueValidatorFunction = (_ value: Any) throws -> Void

// ParamSetPair is used for associating paramsubspace key and field of param
// structs.
public struct ParameterSetPair {
    let key: Data
    let value: Any
    let validatorFunction: ValueValidatorFunction
    
    public init(
        key: Data,
        value: Any,
        validatorFunction: @escaping ValueValidatorFunction
    ) {
        self.key = key
        self.value = value
        self.validatorFunction = validatorFunction
    }
}

// ParamSetPairs Slice of KeyFieldPair
typealias ParameterSetPairs = [ParameterSetPair]

// ParamSet defines an interface for structs containing parameters for a module
protocol ParameterSet {
    var parameterSetPairs: ParameterSetPairs { get }
}
