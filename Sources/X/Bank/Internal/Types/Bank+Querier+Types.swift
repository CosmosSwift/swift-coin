import Cosmos

// QueryBalanceParams defines the params for querying an account balance.
struct QueryBalanceParams: Codable {
    let address: AccountAddress
    
    // NewQueryBalanceParams creates a new instance of QueryBalanceParams.
    init(address: AccountAddress) {
        self.address = address
    }
}
