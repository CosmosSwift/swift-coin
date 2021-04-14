import Cosmos

// MinNamePrice is Initial Starting Price for a name that was never previously owned
let minNamePrice = [Coin(denomination: "nametoken", amount: 1)]

struct Whois: Codable {
    var value: String
    var owner: AccountAddress
    var price: [Coin]
    
    init(value: String, owner: AccountAddress, price: [Coin] = minNamePrice) {
        self.value = value
        self.owner = owner
        self.price = price
    }
}
