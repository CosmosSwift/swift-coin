// query endpoints supported by the auth Querier
extension AuthKeys {
    static let queryAccount = "account"
}

// QueryAccountParams defines the params for querying accounts.
struct QueryAccountParams: Codable {
    let address: AccountAddress
    
    // NewQueryAccountParams creates a new instance of QueryAccountParams.
    internal init(address: AccountAddress) {
        self.address = address
    }
}
