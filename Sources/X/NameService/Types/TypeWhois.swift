import Cosmos

// MinNamePrice is Initial Starting Price for a name that was never previously owned
let minNamePrice = [Coin(denomination: "nametoken", amount: 1)]

public struct Whois: Codable {
    var value: String
    var owner: AccountAddress
    var price: [Coin]
    
    init(value: String, owner: AccountAddress, price: [Coin] = minNamePrice) {
        self.value = value
        self.owner = owner
        self.price = price
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(String.self, forKey: .value)
        self.owner = try container.decode(AccountAddress.self, forKey: .owner)
        self.price = try container.decode([Coin].self, forKey: .price)
    }
}
