import Foundation

extension UInt {
    // MarshalJSON defines custom encoding scheme
    public func marshalJSON() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
