import Foundation
import Tendermint

// Account is an interface used to store coins at a given address within state.
// It presumes a notion of sequence numbers for replay protection,
// a notion of account numbers for replay protection for previously pruned accounts,
// and a pubkey for authentication purposes.
//
// Many complex conditions can be used in the concrete struct which implements Account.
// TODO: Renamed from exported.Account to ExportedAccount investigate better name.
public protocol Account: Codable, CustomStringConvertible {
    var address: AccountAddress { get }
    // errors if already set.
    func set(address: AccountAddress) throws

    // can return nil.
    var publicKey: PublicKey? { get }
    func set(publicKey: PublicKey) throws

    var accountNumber: UInt64 { get }
    func set(accountNumber: UInt64) throws

    var sequence: UInt64 { get }
    func set(sequence: UInt64) throws

    var coins: Coins { get }
    func set(coins: Coins) throws

    // Calculates the amount of coins that can be sent to other accounts given
    // the current time.
    func spendableCoins(blockTime: TimeInterval) -> Coins
}
