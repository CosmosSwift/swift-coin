import Foundation

extension StakingKeys {
    // Default parameter namespace
    public static let defaultParamspace = moduleName
}

extension StakingKeeper {
    // UnbondingTime
    func unbondingTime(request: Request) -> TimeInterval {
        guard let res: TimeInterval = paramstore.get(request: request, key: StakingKeys.keyUnbondingTime) else {
            fatalError("unbonding time not set in Staking store")
        }
        return res
    }

    // MaxValidators - Maximum number of validators
    func maxValidators(request: Request) -> UInt16 {
        guard let res: UInt16 = paramstore.get(request: request, key: StakingKeys.keyMaxValidators) else {
            fatalError("max validators not set in Staking store")
        }
        return res
    }

    // MaxEntries - Maximum number of simultaneous unbonding
    // delegations or redelegations (per pair/trio)
    func maxEntries(request: Request) -> UInt16 {
        guard let res: UInt16 = paramstore.get(request: request, key: StakingKeys.keyMaxEntries) else {
            fatalError("max entries not set in Staking store")
        }
        return res
    }

    // HistoricalEntries = number of historical info entries
    // to persist in store
    func historicalEntries(request: Request) -> UInt16 {
        guard let res: UInt16 = paramstore.get(request: request, key: StakingKeys.keyHistoricalEntries) else {
            fatalError("historical entries not set in Staking store")
        }
        return res
    }

    // BondDenom - Bondable coin denomination
    func bondDenomination(request: Request) -> String {
        guard let res: String = paramstore.get(request: request, key: StakingKeys.keyBondDenomination) else {
            fatalError("bond denom not set in Staking store")
        }
        return res
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
