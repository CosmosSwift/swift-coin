import Cosmos

// Supply represents a struct that passively keeps track of the total supply amounts in the network
struct Supply: Codable {
    // total supply of tokens registered on the chain
    var total: Coins
    
    // NewSupply creates a new Supply instance
    init(total: Coins) {
        self.total = total
    }
}

extension Supply {
    // DefaultSupply creates an empty Supply
    static var `default`: Supply {
        Supply(total: Coins())
    }
}
