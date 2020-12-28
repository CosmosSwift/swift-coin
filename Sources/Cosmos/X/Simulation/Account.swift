import Tendermint

// Account contains a privkey, pubkey, address tuple
// eventually more useful data can be placed in here.
// (e.g. number of coins)
public struct SimulationAccount: Codable {
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
