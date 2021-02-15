import Cosmos

// query endpoints supported by the auth Querier
extension AuthKeys {
    static let queryAccount = "account"
}

// QueryAccountParams defines the params for querying accounts.
struct QueryAccountParameters: Codable {
    let address: AccountAddress
    
    enum CodingKeys: String, CodingKey {
        case address = "Address"
    }
    
    // NewQueryAccountParams creates a new instance of QueryAccountParams.
    internal init(address: AccountAddress) {
        self.address = address
    }
}
