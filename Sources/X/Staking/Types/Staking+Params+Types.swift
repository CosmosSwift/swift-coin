import Foundation
import Params
import Cosmos

// Staking params default values
extension StakingParameters {
    // DefaultUnbondingTime reflects three weeks in seconds as the default
    // unbonding time.
    // TODO: Justify our choice of default here.
    static let defaultUnbondingTime: TimeInterval = 60 * 60 * 24 * 7 * 3

    // Default maximum number of bonded validators
    static let defaultMaxValidators: UInt16 = 100

    // Default maximum entries in a UBD/RED pair
    static let defaultMaxEntries: UInt16 = 7

    // DefaultHistorical entries is 0 since it must only be non-zero for
    // IBC connected chains
    static let defaultHistoricalEntries: UInt16 = 0
}

extension StakingKeys {
    static let keyUnbondingTime = "UnbondingTime".data
    static let keyMaxValidators = "MaxValidators".data
    static let keyMaxEntries = "KeyMaxEntries".data
    static let keyBondDenomination = "BondDenom".data
    static let keyHistoricalEntries = "HistoricalEntries".data
}

// Params defines the high level settings for staking
struct StakingParameters: ParameterSet, Codable  {
    // time duration of unbonding
    let unbondingTime: TimeInterval
    // maximum number of validators (max uint16 = 65535)
    let maxValidators: UInt16
    // max entries for either unbonding delegation or redelegation (per pair/trio)
    let maxEntries: UInt16
    // number of historical entries to persist
    let historicalEntries: UInt16
    // bondable coin denomination
    let bondDenomination: String
    
    private enum CodingKeys: String, CodingKey {
        case unbondingTime = "unbonding_time"
        case maxValidators = "max_validators"
        case maxEntries = "max_entries"
        case historicalEntries = "historical_entries"
        case bondDenomination = "bond_denom"
    }
}

extension StakingParameters {
    // Implements params.ParamSet
    var parameterSetPairs: ParameterSetPairs {
        return [
            ParameterSetPair(key: StakingKeys.keyUnbondingTime, value: unbondingTime, validatorFunction: validateUnbondingTime),
            ParameterSetPair(key: StakingKeys.keyMaxValidators, value: maxValidators, validatorFunction: validateMaxValidators),
            ParameterSetPair(key: StakingKeys.keyMaxEntries, value: maxEntries, validatorFunction: validateMaxEntries),
            ParameterSetPair(key: StakingKeys.keyHistoricalEntries, value: historicalEntries, validatorFunction: validateHistoricalEntries),
            ParameterSetPair(key: StakingKeys.keyBondDenomination, value: bondDenomination, validatorFunction: validateBondDenomination),
       ]
    }
}


extension StakingParameters {
    // DefaultParams returns a default set of parameters.
    static var `default`: StakingParameters {
        StakingParameters(
            unbondingTime: defaultUnbondingTime,
            maxValidators: defaultMaxValidators,
            maxEntries: defaultMaxEntries,
            historicalEntries: defaultHistoricalEntries,
            bondDenomination: defaultBondDenomination
        )
    }
}

struct ValidationError: Swift.Error, CustomStringConvertible {
    let description: String
}

func validateUnbondingTime(encodable: AnyEncodable) throws {
    guard let value = encodable.value as? TimeInterval else {
        throw ValidationError(description: "invalid parameter type: \(type(of: encodable.value))")
    }

    guard value > 0 else {
        throw ValidationError(description: "unbonding time must be positive: \(value)")
    }
}

func validateMaxValidators(encodable: AnyEncodable) throws {
    guard let value = encodable.value as? UInt16 else {
        throw ValidationError(description: "invalid parameter type: \(type(of: encodable.value))")
    }

    guard value != 0 else {
        throw ValidationError(description: "max validators must be positive: \(value)")
    }
}

func validateMaxEntries(encodable: AnyEncodable) throws {
    guard let value = encodable.value as? UInt16 else {
        throw ValidationError(description: "invalid parameter type: \(type(of: encodable.value))")
    }

    guard value != 0 else {
        throw ValidationError(description: "max entries must be positive: \(value)")
    }
}

func validateHistoricalEntries(encodable: AnyEncodable) throws {
    guard encodable.value is UInt16 else {
        throw ValidationError(description: "invalid parameter type: \(type(of: encodable.value))")
    }
}

func validateBondDenomination(encodable: AnyEncodable) throws {
    guard let value = encodable.value as? String else {
        throw ValidationError(description: "invalid parameter type: \(type(of: encodable.value))")
    }
    
    guard !value.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw ValidationError(description: "bond denom cannot be blank")
    }
    
    try Coins.validate(denomination: value)
}
