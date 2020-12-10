// Coin hold some amount of one currency.
//
// CONTRACT: A coin will never hold a negative amount of any denomination.
public struct Coin: Codable {
    let denomination: String
    let amount: UInt
    
    public init(denomination: String, amount: UInt) {
        self.denomination = denomination
        self.amount = amount
    }
}

public struct Coins: Codable {
    public let coins: [Coin]
    
    public init(coins: [Coin]) {
        self.coins = coins
    }
     
    var count: Int {
        coins.count
    }
    
    var isEmpty: Bool {
        coins.isEmpty
    }
    
    func prefix(_ maxLength: Int) -> Coins {
        Coins(coins: Array(coins.prefix(maxLength)))
    }
    
    func suffix(from start: Int) -> Coins {
        Coins(coins: Array(coins.suffix(from: start)))
    }
}

//extension Coins: Sequence {
//}

extension Coins {
    // isAllPositive returns true if there is at least one coin.
    public var isAllPositive: Bool {
        if isEmpty {
            return false
        }

        return true
    }
    
    // IsAllGT returns true if for every denom in coinsB,
    // the denom is present at a greater amount in coins.
    public func isAllGreaterThan(coins: Coins) -> Bool {
        if isEmpty {
            return false
        }

        if coins.isEmpty {
            return true
        }

        if !coins.denominationIsSubset(of: self) {
            return false
        }

        // TODO: Make Coins a sequence
        for coin in coins.coins {
            let amountA = amountOf(denomination: coin.denomination)
            let amountB = coin.amount
            
            if !(amountA > amountB) {
                return false
            }
        }

        return true
    }
    
    // DenomsSubsetOf returns true if receiver's denom set
    // is subset of coinsB's denoms.
    func denominationIsSubset(of coins: Coins) -> Bool {
        // more denoms in B than in receiver
        if count > coins.count {
            return false
        }

        // TODO: Make Coins a sequence
        for coin in self.coins {
            if coins.amountOf(denomination: coin.denomination) == 0 {
                return false
            }
        }

        return true
    }
     
    // Returns the amount of a denom from coins
    func amountOf(denomination: String) -> UInt {
        Coins.mustValidate(denomination: denomination)

        switch count {
        case 0:
            return 0

        case 1:
            let coin = coins[0]
            
            if denomination == coin.denomination {
                return coin.amount
            }
            
            return 0

        default:
            let midIdx = count / 2 // 2:1, 3:1, 4:2
            let coin = coins[midIdx]
            
            if denomination < coin.denomination {
                return prefix(midIdx).amountOf(denomination: denomination)
            } else if denomination == coin.denomination {
                return coin.amount
            } else {
                return suffix(from: midIdx + 1).amountOf(denomination: denomination)
            }
        }
    }
    
    static let denominationRegex = "[a-z][a-z0-9]{2,15}"

    // ValidateDenom validates a denomination string returning an error if it is
    // invalid.
    static func validate(denomination: String) throws {
        if denomination.range(of: denominationRegex, options: .regularExpression) == nil {
            throw Cosmos.Error.invalidDenomination(denomination: denomination)
        }
    }

    static func mustValidate(denomination: String) {
        do {
            try validate(denomination: denomination)
        } catch {
            fatalError("\(error)")
        }
    }
}
