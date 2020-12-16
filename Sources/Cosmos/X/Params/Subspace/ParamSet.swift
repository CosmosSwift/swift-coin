import Foundation

public typealias ValueValidatorFunction = (_ value: Any) throws -> Void

// ParamSetPair is used for associating paramsubspace key and field of param
// structs.
public struct ParamSetPair {
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
