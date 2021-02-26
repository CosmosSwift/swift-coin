import Foundation

// ----------------------------------------------------------------------------
// Decimal Coin

// DecCoin defines a coin which can have additional decimal points
public struct DecimalCoin: Codable {
    public let denomination: String
    public let amount: Decimal
}
    
extension DecimalCoin {
    public init?(string: String) {
        // get the first char which is not number (or . when we handle DecCoin)
        // from there, it's the denom
        // the denom should be btw 3 and 16 char long, start with a lowercase letter, and the rest should be lowercase or number
        //
        let pattern = "[0-9.]+"
        guard let amountRange = string.range(of: pattern, options:.regularExpression) else {
            return nil
        }
        
        let amount = Decimal(string: String(string[amountRange])) ?? 0
        var denomination = string
        denomination.removeSubrange(amountRange)
        self.init(denomination: denomination, amount: amount)
    }
    
}

// ----------------------------------------------------------------------------
// Decimal Coins

// DecCoins defines a slice of coins with decimal values
// now implemented using [DecimalCoin]
/*public struct DecimalCoins {
    public let coins: [DecimalCoin]
    
    init() {
        self.coins = []
    }
}

*/
