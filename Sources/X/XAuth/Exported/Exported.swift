import Foundation
import Tendermint
import Cosmos

// Account is an interface used to store coins at a given address within state.
// It presumes a notion of sequence numbers for replay protection,
// a notion of account numbers for replay protection for previously pruned accounts,
// and a pubkey for authentication purposes.
//
// Many complex conditions can be used in the concrete struct which implements Account.
public protocol Account: ProtocolCodable, CustomStringConvertible {
    var address: AccountAddress { get }
    // errors if already set.
    mutating func set(address: AccountAddress) throws

    // can return nil.
    var publicKey: PublicKey? { get }
    mutating func set(publicKey: PublicKey) throws

    var accountNumber: UInt64 { get }
    mutating func set(accountNumber: UInt64) throws

    var sequence: UInt64 { get }
    mutating func set(sequence: UInt64) throws

    var coins: Coins { get }
    mutating func set(coins: Coins) throws

    // Calculates the amount of coins that can be sent to other accounts given
    // the current time.
    func spendableCoins(blockTime: TimeInterval) -> Coins
}

// GenesisAccounts defines a slice of GenesisAccount objects
public typealias GenesisAccounts = [GenesisAccount]

extension GenesisAccounts {
    // Contains returns true if the given address exists in a slice of GenesisAccount
    // objects.
    func contains(address: Cosmos.Address) -> Bool {
        for account in self {
            if account.address.equals(address) {
                return true
            }
        }

        return false
    }
}

// GenesisAccount defines a genesis account that embeds an Account with validation capabilities.
public protocol GenesisAccount: Account {
    func validate() throws
}

