import Foundation

// GenesisValidator is an initial validator.
public struct GenesisValidator {
    let address: Address
    let publicKey: PublicKey
    let power: Int64
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case address
        case publicKey = "pub_key"
        case power
        case name
    }
}
