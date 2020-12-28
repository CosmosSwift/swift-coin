import Foundation
import Tendermint

// BaseAccount - a base account structure.
// This can be extended by embedding within in your AppAccount.
// However one doesn't have to use BaseAccount as long as your struct
// implements Account.
public class BaseAccount {
    var address: AccountAddress
    var coins: Coins
    var publicKey: PublicKey?
    var accountNumber: UInt64
    var sequence: UInt64
    
    // NewBaseAccount creates a new BaseAccount object
    init(
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
    
    func set(address: AccountAddress) throws {
        guard address.isEmpty else {
            throw Cosmos.Error.generic(reason: "cannot override BaseAccount address")
        }
        
        self.address = address
    }

    func set(publicKey: PublicKey) throws {
        self.publicKey = publicKey
    }
    
    func set(accountNumber: UInt64) throws {
        self.accountNumber = accountNumber
    }
    
    func set(sequence: UInt64) throws {
        self.sequence = sequence
    }
    
    func set(coins: Coins) throws {
        self.coins = coins
    }
    
    // SpendableCoins returns the total set of spendable coins. For a base account,
    // this is simply the base coins.
    func spendableCoins(blockTime: TimeInterval) -> Coins {
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

    var description: String {
        // TODO: Deal with force try and force unwrap.
        let data = try! encodeYAML()
        return String(data: data, encoding: .utf8)!
    }

    // MarshalYAML returns the YAML representation of an account.
    func encodeYAML() throws -> Data {
        // TODO: Implement
        Data()
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
