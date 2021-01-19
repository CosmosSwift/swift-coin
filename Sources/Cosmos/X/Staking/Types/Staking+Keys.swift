import Foundation

public enum StakingKeys {
    // ModuleName is the name of the staking module
    public static let moduleName = "staking"

    // StoreKey is the string store representation
    public static let storeKey = moduleName

    // TStoreKey is the string transient store representation
    public static let transientStoreKey = "transient_" + moduleName

    // QuerierRoute is the querier route for the staking module
    public static let querierRoute = moduleName

    // RouterKey is the msg router key for the staking module
    public static let routerKey = moduleName
}

// Keys for store prefixes
// Last* values are constant during a block.
let lastValidatorPowerKey = Data([0x11]) // prefix for each key to a validator index, for bonded validators
let lastTotalPowerKey = Data([0x12]) // prefix for the total power

let validatorsKey = Data([0x21]) // prefix for each key to a validator
let validatorsByConsensusAddressKey = Data([0x22]) // prefix for each key to a validator index, by pubkey
let validatorsByPowerIndexKey = Data([0x23]) // prefix for each key to a validator index, sorted by power

let delegationKey = Data([0x31]) // key for a delegation
let unbondingDelegationKey = Data([0x32]) // key for an unbonding-delegation
let unbondingDelegationByValIndexKey = Data([0x33]) // prefix for each key for an unbonding-delegation, by validator operator
let redelegationKey = Data([0x34]) // key for a redelegation
let redelegationByValSrcIndexKey = Data([0x35]) // prefix for each key for an redelegation, by source validator operator
let redelegationByValDstIndexKey = Data([0x36]) // prefix for each key for an redelegation, by destination validator operator

let unbondingQueueKey = Data([0x41]) // prefix for the timestamps in unbonding queue
let redelegationQueueKey = Data([0x42]) // prefix for the timestamps in redelegations queue
let validatorQueueKey = Data([0x43]) // prefix for the timestamps in validator queue

let historicalInfoKey = Data([0x50]) // prefix for the historical info

// gets the key for the validator with address
// VALUE: staking/Validator
func validatorKey(operatorAddress: ValidatorAddress) -> Data {
    validatorsKey + operatorAddress.data
}

// gets the key for the validator with pubkey
// VALUE: validator operator address ([]byte)
func validatorByConsensusAddressKey(consensusAddress: ConsensusAddress) -> Data {
    validatorsByConsensusAddressKey + consensusAddress.data
}

// get the validator by power index.
// Power index is the key used in the power-store, and represents the relative
// power ranking of the validator.
// VALUE: validator operator address ([]byte)
func validatorsByPowerIndexKey(validator: Validator) -> Data {
    // NOTE the address doesn't need to be stored because counter bytes must always be different
    validatorPowerRank(validator: validator)
}

// get the bonded validator index key for an operator address
func lastValidatorPowerKey(operator: ValidatorAddress) -> Data {
    lastValidatorPowerKey + `operator`.data
}


// get the power ranking of a validator
// NOTE the larger values are of higher value
func validatorPowerRank(validator: Validator) -> Data {
    // TODO: Implement
    fatalError()
//    let consensusPower = TokensToConsensusPower(validator.Tokens)
//    let consensusPowerBytes = Data(capacity: 8)
//    binary.BigEndian.PutUint64(consensusPowerBytes, uint64(consensusPower))
//
//    powerBytes := consensusPowerBytes
//    powerBytesLen := len(powerBytes) // 8
//
//    // key is of format prefix || powerbytes || addrBytes
//    key := make([]byte, 1+powerBytesLen+sdk.AddrLen)
//
//    key[0] = ValidatorsByPowerIndexKey[0]
//    copy(key[1:powerBytesLen+1], powerBytes)
//    operAddrInvr := sdk.CopyBytes(validator.OperatorAddress)
//    for i, b := range operAddrInvr {
//        operAddrInvr[i] = ^b
//    }
//    copy(key[powerBytesLen+1:], operAddrInvr)
//
//    return key
}

// gets the prefix for all unbonding delegations from a delegator
func validatorQueueTimeKey(timestamp: Date) -> Data {
    let data = formatDateData(date: timestamp)
    return validatorQueueKey + data
}

///vgets the key for the historical info
func historicalInfoKey(height: Int64) -> Data {
    let data =  "\(height)".data // []byte(strconv.FormatInt(height, 10))
    return historicalInfoKey + data
}
