import Foundation
import Tendermint
import Cosmos

// BaseAccount - a base account structure.
// This can be extended by embedding within in your AppAccount.
// However one doesn't have to use BaseAccount as long as your struct
// implements Account.
public struct BaseAccount: Account, GenesisAccount {
    public static let metaType: MetaType = Self.metaType(
        key: "cosmos-sdk/Account"
    )
    
    public private(set) var address: AccountAddress
    public private(set) var coins: Coins
    public private(set) var publicKey: PublicKey?
    public private(set) var accountNumber: UInt64
    public private(set) var sequence: UInt64
    
    // NewBaseAccount creates a new BaseAccount object
    public init(
        address: AccountAddress,
        coins: Coins = Coins(),
        publicKey: PublicKey? = nil,
        accountNumber: UInt64 = 0,
        sequence: UInt64 = 0
    ) {
        self.address = address
        self.coins = coins
        self.publicKey = publicKey
        self.accountNumber = accountNumber
        self.sequence = sequence
    }
    
    enum CodingKeys: String, CodingKey {
        case address, coins, publicKey, accountNumber, sequence
    }
    
    // This si required because Tendermint 0.33.9 ser/deser UInt64 as strings
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(AccountAddress.self, forKey: .address)
        self.coins = try container.decode(Coins.self, forKey: .coins)
        self.publicKey = try container.decodeIfPresent(PublicKey.self, forKey: .publicKey)
        let accountNumberStr = try container.decode(String.self, forKey: .accountNumber)
        guard let accountNumber = UInt64(accountNumberStr) else {
            throw Cosmos.Error.generic(reason: "Decoding: Invalid accountNumber: \(accountNumberStr)")
        }
        self.accountNumber = accountNumber
        
        let sequenceStr = try container.decode(String.self, forKey: .sequence)
        guard let sequence = UInt64(sequenceStr) else {
            throw Cosmos.Error.generic(reason: "Decoding: Invalid sequence: \(sequenceStr)")
        }
        self.sequence = sequence
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(coins, forKey: .coins)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode("\(accountNumber)", forKey: .accountNumber)
        try container.encode("\(sequence)", forKey: .sequence)

    }
    
    public mutating func set(address: AccountAddress) throws {
        guard address.isEmpty else {
            throw Cosmos.Error.generic(reason: "cannot override BaseAccount address")
        }
        
        self.address = address
    }

    public mutating func set(publicKey: PublicKey) throws {
        self.publicKey = publicKey
    }
    
    public mutating func set(accountNumber: UInt64) throws {
        self.accountNumber = accountNumber
    }
    
    public mutating func set(sequence: UInt64) throws {
        self.sequence = sequence
    }
    
    public mutating func set(coins: Coins) throws {
        self.coins = coins
    }
    
    // Validate checks for errors on the account fields
    public func validate() throws {
        struct ValidationError: Swift.Error, CustomStringConvertible {
            let description: String
        }
        
        if
            let publicKey = self.publicKey,
            publicKey.address.rawValue != address.data
        {
            throw ValidationError(description: "pubkey and address pair is invalid")
        }
    }

    
    // SpendableCoins returns the total set of spendable coins. For a base account,
    // this is simply the base coins.
    public func spendableCoins(blockTime: TimeInterval) -> Coins {
        coins
    }
    
    struct BaseAccountPretty: Codable {
        let address: AccountAddress
        let coins: Coins
        let publicKey: String
        let accountNumber: UInt64
        let sequence: UInt64
        
        private enum CodingKeys: String, CodingKey {
            case address
            case coins
            case publicKey = "public_key"
            case accountNumber = "account_number"
            case sequence
        }
    }

    // TODO: Check if this just used as description or
    // if it's used to output to files or something
    public var description: String {
        // TODO: Deal with force try and force unwrap.
        let data = try! encodeYAML()
        return String(data: data, encoding: .utf8)!
    }

    // MarshalYAML returns the YAML representation of an account.
    func encodeYAML() throws -> Data {
        // TODO: Implement
        fatalError()
//        alias := baseAccountPretty{
//            Address:       acc.Address,
//            Coins:         acc.Coins,
//            AccountNumber: acc.AccountNumber,
//            Sequence:      acc.Sequence,
//        }
//
//        if acc.PubKey != nil {
//            pks, err := sdk.Bech32ifyPubKey(sdk.Bech32PubKeyTypeAccPub, acc.PubKey)
//            if err != nil {
//                return nil, err
//            }
//
//            alias.PubKey = pks
//        }
//
//        bz, err := yaml.Marshal(alias)
//        if err != nil {
//            return nil, err
//        }
//
//        return string(bz), err
    }
}

// ProtoBaseAccount - a prototype function for BaseAccount
public func protoBaseAccount() -> Account {
    fatalError()
    // TODO: BaseAccount is returned here with no parameters in the original codebase
    // Check what exactly that would mean
//    BaseAccount()
}
