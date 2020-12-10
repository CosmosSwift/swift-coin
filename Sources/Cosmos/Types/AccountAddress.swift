import Foundation

// `AccountAddress` is a wrapper around `Data` meant to represent an account address.
// When marshaled to a string or JSON, it uses Bech32.
public struct AccountAddress: Codable, Equatable {
    private let data: Data
    
    public init() {
        self.data = Data()
    }
    
    public var isEmpty: Bool {
        data.isEmpty
    }
    
    public func string() -> String {
        String(data: data, encoding: .utf8)!
    }
}
