// staking constants

// default bond denomination
let defaultBondDenomination = "stake"

// BondStatus is the status of a validator
enum BondStatus: Int, Codable {
    case unbonded = 0x00
    case unbonding = 0x01
    case bonded = 0x02
}
