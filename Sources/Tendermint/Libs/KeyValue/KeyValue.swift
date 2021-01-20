import Foundation

public struct KeyValuePair: Hashable {
    public let key: Data
    public let value: Data
    
    public init(key: Data, value: Data) {
        self.key = key
        self.value = value
    }
}

extension KeyValuePair: Comparable {
    public static func < (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        guard lhs.key != rhs.key else {
            return lhs.value.lexicographicallyPrecedes(rhs.value)
        }
        
        return lhs.key.lexicographicallyPrecedes(rhs.key)
    }
}
