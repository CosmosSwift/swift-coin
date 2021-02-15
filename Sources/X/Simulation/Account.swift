import Tendermint
import Cosmos

// Account contains a privkey, pubkey, address tuple
// eventually more useful data can be placed in here.
// (e.g. number of coins)
public struct Account: Codable {
    let privateKey: PrivateKey
    let publicKey: PublicKey
    let address: AccountAddress
    
    public init(from decoder: Decoder) throws {
        fatalError()
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError()
    }
}
