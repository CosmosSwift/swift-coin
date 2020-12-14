import Cosmos

// MinNamePrice is Initial Starting Price for a name that was never previously owned
let minNamePrice = Coins(coins: [Coin(denomination: "nametoken", amount: 1)])

struct Whois: Codable {
    var value: String
    var owner: AccountAddress
    var price: Coins
    
    init() {
        self.value = ""
        self.owner = AccountAddress()
        self.price = minNamePrice
    }
}
