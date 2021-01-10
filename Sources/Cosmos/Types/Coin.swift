import Foundation

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
    
    var isZero: Bool {
        amount == 0
    }

    
    // Adds amounts of two coins with same denom. If the coins differ in denom then
    // it panics.
    static func + (lhs: Coin, rhs: Coin) -> Coin {
        if lhs.denomination != rhs.denomination {
            fatalError("invalid coin denominations; \(lhs.denomination), \(rhs.denomination)")
        }
        
        return Coin(
            denomination: lhs.denomination,
            amount: lhs.amount + rhs.amount
        )
    }
}

extension Coin: Comparable {
    public static func < (lhs: Coin, rhs: Coin) -> Bool {
        lhs.amount < rhs.amount
    }
}

public struct Coins: Codable {
    public let coins: [Coin]
    
    public init(coins: [Coin] = []) {
        self.coins = coins
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.coins = try container.decode([Coin].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(coins)
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

extension Coins: Equatable {
    // IsEqual returns true if the two sets of Coins have the same value
    public static func == (lhs: Coins, rhs: Coins) -> Bool {
        if lhs.count != rhs.count {
            return false
        }

        let coinsA = lhs.coins.sorted()
        let coinsB = rhs.coins.sorted()

        for i in 0 ..< coinsA.count {
            if coinsA[i] != coinsB[i] {
                return false
            }
        }

        return true
    }
}

extension Coins {
    // TODO: Implement this correctly
    // MarshalJSON implements a custom JSON marshaller for the Coins type to allow
    // nil Coins to be encoded as an empty array.
    func marshalJSON() throws -> Data {
        let encoder = JSONEncoder()

        if coins.isEmpty {
            return try encoder.encode(Coins())
        }

        return try encoder.encode(coins)
    }

    // isAllPositive returns true if there is at least one coin.
    public var isAllPositive: Bool {
        if isEmpty {
            return false
        }

        return true
    }
    
    // IsValid asserts the Coins are sorted, have positive amount,
    // and Denom does not contain upper case characters.
    var isValid: Bool {
        switch coins.count {
        case 0:
            return true
        case 1:
            do {
                try Self.validate(denomination: coins[0].denomination)
                return true
            } catch {
                return false
            }
        default:
            // check single coin case
            if !Coins(coins: [coins[0]]).isValid {
                return false
            }

            var lowDenomination = coins[0].denomination
            
            for coin in coins.suffix(1) {
                if coin.denomination.lowercased() != coin.denomination {
                    return false
                }
                
                if coin.denomination <= lowDenomination {
                    return false
                }

                // we compare each coin against the last denom
                lowDenomination = coin.denomination
            }

            return true
        }
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
    
    // Add adds two sets of coins.
    //
    // e.g.
    // {2A} + {A, 2B} = {3A, 2B}
    // {2A} + {0B} = {2A}
    //
    // NOTE: Add operates under the invariant that coins are sorted by
    // denominations.
    //
    // CONTRACT: Add will never return Coins where one Coin has a non-positive
    // amount. In otherwords, IsValid will always return true.
    static func + (lhs: Coins, rhs: Coins) -> Coins {
        lhs.safeAdd(other: rhs)
    }

    // safeAdd will perform addition of two coins sets. If both coin sets are
    // empty, then an empty set is returned. If only a single set is empty, the
    // other set is returned. Otherwise, the coins are compared in order of their
    // denomination and addition only occurs when the denominations match, otherwise
    // the coin is simply added to the sum assuming it's not zero.
    func safeAdd(other coinsB: Coins) -> Coins {
        var sum: [Coin] = []
        var indexA = 0
        var indexB = 0
        let lenA = self.count
        let lenB = coinsB.count

        while true {
            if indexA == lenA {
                if indexB == lenB {
                    // return nil coins if both sets are empty
                    return Coins()
                }

                // return set B (excluding zero coins) if set A is empty
                return Coins(coins: sum) + (coinsB.suffix(from: indexB).removingZeroCoins())
            } else if indexB == lenB {
                // return set A (excluding zero coins) if set B is empty
                return Coins(coins: sum) + (self.suffix(from: indexA).removingZeroCoins())
            }

            let coinA = coins[indexA]
            let coinB = coinsB.coins[indexB]

            let result = coinA.denomination.compare(coinB.denomination)

            switch result {
            // coin A denom < coin B denom
            case .orderedAscending:
                if !coinA.isZero {
                    sum.append(coinA)
                }

                indexA += 1
            // coin A denom == coin B denom
            case .orderedSame:
                let result = coinA + coinB
                
                if result.isZero {
                    sum.append(result)
                }

                indexA += 1
                indexB += 1
                
            // coin A denom > coin B denom
            case .orderedDescending:
                if !coinB.isZero {
                    sum.append(coinB)
                }

                indexB += 1
            }
        }
    }
    
    // removeZeroCoins removes all zero coins from the given coin set
    func removingZeroCoins() -> Coins {
        Coins(coins: coins.filter({ !$0.isZero }))
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
