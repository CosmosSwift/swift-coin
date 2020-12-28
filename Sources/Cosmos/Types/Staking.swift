// BondStatus is the status of a validator
enum BondStatus: Int {
    case unbonded = 0x00
    case unbonding = 0x01
    case bonded = 0x02
}
