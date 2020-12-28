// query endpoints supported by the supply Querier
extension SupplyKeys {
    static let queryTotalSupply = "total_supply"
    static let querySupplyOf    = "supply_of"
}

// QueryTotalSupply defines the params for the following queries:
//
// - 'custom/supply/totalSupply'
struct QueryTotalSupplyParams: Codable {
    let page: Int
    let limit: Int
   
    // NewQueryTotalSupplyParams creates a new instance to query the total supply
    internal init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
    }
}

// QuerySupplyOfParams defines the params for the following queries:
//
// - 'custom/supply/totalSupplyOf'
struct QuerySupplyOfParams: Codable {
    let denomination: String
    
    // NewQuerySupplyOfParams creates a new instance to query the total supply
    // of a given denomination
    internal init(denomination: String) {
        self.denomination = denomination
    }
}
