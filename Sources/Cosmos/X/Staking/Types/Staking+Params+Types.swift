import Foundation

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

func validateUnbondingTime(i: Any) throws {
    // TODO: Implement
    fatalError()
//    v, ok := i.(time.Duration)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v <= 0 {
//        return fmt.Errorf("unbonding time must be positive: %d", v)
//    }
//
//    return nil
}

func validateMaxValidators(i: Any) throws {
    // TODO: Implement
    fatalError()
//    v, ok := i.(uint16)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v == 0 {
//        return fmt.Errorf("max validators must be positive: %d", v)
//    }
//
//    return nil
}

func validateMaxEntries(i: Any) throws {
    // TODO: Implement
    fatalError()
//    v, ok := i.(uint16)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if v == 0 {
//        return fmt.Errorf("max entries must be positive: %d", v)
//    }
//
//    return nil
}

func validateHistoricalEntries(i: Any) throws {
    // TODO: Implement
    fatalError()
//    _, ok := i.(uint16)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    return nil
}

func validateBondDenomination(i: Any) throws {
    // TODO: Implement
    fatalError()
//    v, ok := i.(string)
//    if !ok {
//        return fmt.Errorf("invalid parameter type: %T", i)
//    }
//
//    if strings.TrimSpace(v) == "" {
//        return errors.New("bond denom cannot be blank")
//    }
//    if err := sdk.ValidateDenom(v); err != nil {
//        return err
//    }
//
//    return nil
}
