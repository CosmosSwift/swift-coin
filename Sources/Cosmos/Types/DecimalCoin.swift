import Foundation

// ----------------------------------------------------------------------------
// Decimal Coin

// DecCoin defines a coin which can have additional decimal points
struct DecimalCoin: Codable {
    let denomination: String
    let amount: Decimal
}

// ----------------------------------------------------------------------------
// Decimal Coins

// DecCoins defines a slice of coins with decimal values
struct DecimalCoins {
    let coins: [DecimalCoin]
    
    init() {
        self.coins = []
    }
}

