import Foundation

extension StakingKeys {
    // Default parameter namespace
    public static let defaultParamspace = moduleName
}

extension StakingKeeper {
    // UnbondingTime
    func unbondingTime(request: Request) -> TimeInterval {
        paramstore.get(request: request, key: StakingKeys.keyUnbondingTime)
    }

    // MaxValidators - Maximum number of validators
    func maxValidators(request: Request) -> UInt16 {
        paramstore.get(request: request, key: StakingKeys.keyMaxValidators)
    }

    // MaxEntries - Maximum number of simultaneous unbonding
    // delegations or redelegations (per pair/trio)
    func maxEntries(request: Request) -> UInt16 {
        paramstore.get(request: request, key: StakingKeys.keyMaxEntries)
    }

    // HistoricalEntries = number of historical info entries
    // to persist in store
    func historicalEntries(request: Request) -> UInt16 {
        paramstore.get(request: request, key: StakingKeys.keyHistoricalEntries)
    }

    // BondDenom - Bondable coin denomination
    func bondDenomination(request: Request) -> String {
        paramstore.get(request: request, key: StakingKeys.keyBondDenomination)
    }

    // Get all parameters as types.Params
    func parameters(request: Request) -> StakingParameters {
        StakingParameters(
            unbondingTime: unbondingTime(request: request),
            maxValidators: maxValidators(request: request),
            maxEntries: maxEntries(request: request),
            historicalEntries: historicalEntries(request: request),
            bondDenomination: bondDenomination(request: request)
        )
    }

    // set the params
    func setParameters(request: Request, parameters: StakingParameters) {
        paramstore.setParameterSet(request: request, parameterSet: parameters)
    }
}
