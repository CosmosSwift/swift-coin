import Foundation

// ----------------------------------------------------------------------------
// Decimal Coin

// DecCoin defines a coin which can have additional decimal points
public struct DecimalCoin: Codable {
    public let denomination: String
    public let amount: Decimal
}

// ----------------------------------------------------------------------------
// Decimal Coins

// DecCoins defines a slice of coins with decimal values
public struct DecimalCoins {
    public let coins: [DecimalCoin]
    
    init() {
        self.coins = []
    }
}

