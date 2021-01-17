// staking constants

// default bond denomination
let defaultBondDenomination = "stake"

// Delay, in blocks, between when validator updates are returned to the
// consensus-engine and when they are applied. For example, if
// ValidatorUpdateDelay is set to X, and if a validator set update is
// returned with new validators at the end of block 10, then the new
// validators are expected to sign blocks beginning at block 11+X.
//
// This value is constant as this should not change without a hard fork.
// For Tendermint this should be set to 1 block, for more details see:
// https://tendermint.com/docs/spec/abci/apps.html#endblock
let validatorUpdateDelay: Int64 = 1

// PowerReduction is the amount of staking tokens required for 1 unit of consensus-engine power
let powerReduction: UInt = 1_000_000

// TokensToConsensusPower - convert input tokens to potential consensus-engine power
func tokensToConsensusPower(tokens: UInt) -> Int64 {
    // TODO: Check if there's more to it than just Int division
    // (tokens.Quo(PowerReduction)).Int64()
    Int64(tokens / powerReduction)
}

// BondStatus is the status of a validator
enum BondStatus: Int, Codable {
    case unbonded = 0x00
    case unbonding = 0x01
    case bonded = 0x02
}
