import Foundation

// `AccountAddress` is a wrapper around `Data` meant to represent an account address.
// When marshaled to a string or JSON, it uses Bech32.
public struct AccountAddress: Codable, Equatable {
    private let data: Data
    
    public init(data: Data = Data()) {
        self.data = data
    }
    
    public var isEmpty: Bool {
        data.isEmpty
    }
    
    public var string: String {
        guard !data.isEmpty else {
            return ""
        }

        let bech32PrefixAccountAddress = Configuration.bech32AccountAddressPrefix

        do {
            // TODO: Implement
            fatalError()
//            return try Bech32.convertAndEncode(bech32PrefixAccountAddress, data)
        } catch {
           fatalError("\(error)")
        }
    }
}
