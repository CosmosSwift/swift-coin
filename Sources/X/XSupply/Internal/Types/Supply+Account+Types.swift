import Foundation
import Tendermint
import Cosmos
import XAuth

// ModuleAccount defines an account for modules that holds coins on a pool
public struct ModuleAccount: GenesisAccount {
    public static var metaType: MetaType = Self.metaType(
        key: "cosmos-sdk/ModuleAccount"
    )
    
    // base account
    private var baseAccount: BaseAccount
    // name of the module
    let name: String
    // permissions of module account
    let permissions: [String]
    
    public var address: AccountAddress {
        baseAccount.address
    }
    
    public var coins: Coins {
        baseAccount.coins
    }
    
    public var publicKey: PublicKey? {
        baseAccount.publicKey
    }
    
    public var accountNumber: UInt64 {
        baseAccount.accountNumber
    }
    
    public var sequence: UInt64 {
        baseAccount.sequence
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case permissions
    }

    // NewEmptyModuleAccount creates a empty ModuleAccount from a string
    public init(name: String, permissions: [String]) {
        let moduleAddress = ModuleAccount.moduleAddress(name: name)
        try! SupplyPermissions.validate(permissions: permissions)

        self.baseAccount = BaseAccount(address: moduleAddress)
        self.name = name
        self.permissions = permissions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.permissions = try container.decode([String].self, forKey: .permissions)
        self.baseAccount = try BaseAccount(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(permissions, forKey: .permissions)
        try baseAccount.encode(to: encoder)
    }
    
    public mutating func set(address: AccountAddress) throws {
        try baseAccount.set(address: address)
    }

    public mutating func set(publicKey: PublicKey) throws {
        try baseAccount.set(publicKey: publicKey)
    }
    
    public mutating func set(accountNumber: UInt64) throws {
        try baseAccount.set(accountNumber: accountNumber)
    }
    
    public mutating func set(sequence: UInt64) throws {
        try baseAccount.set(sequence: sequence)
    }
    
    public mutating func set(coins: Coins) throws {
        try baseAccount.set(coins: coins)
    }
    
    public func validate() throws {
        try baseAccount.validate()
    }

    public func spendableCoins(blockTime: TimeInterval) -> Coins {
        baseAccount.spendableCoins(blockTime: blockTime)
    }
    
    public var description: String {
        baseAccount.description
    }
}


// TODO: Rethink where best to put this function
extension ModuleAccount {
    // NewModuleAddress creates an AccAddress from the hash of the module's name
    public static func moduleAddress(name: String) -> AccountAddress {
        AccountAddress(data: Crypto.addressHash(data: name.data).rawValue)
    }
}
