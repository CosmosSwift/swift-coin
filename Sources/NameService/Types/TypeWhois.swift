import Cosmos

// MinNamePrice is Initial Starting Price for a name that was never previously owned
let minNamePrice = [Coin(denomination: "nametoken", amount: 1)]

struct Whois: Codable {
    var value: String
    var owner: AccountAddress
    var price: [Coin]
    
    init() {
        self.value = ""
        self.owner = AccountAddress()
        self.price = minNamePrice
    }
}
