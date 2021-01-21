import Foundation

extension StakingKeys {
    // Default parameter namespace
    public static let defaultParamspace = moduleName
}

extension StakingKeeper {
    // UnbondingTime
    func unbondingTime(request: Request) -> TimeInterval {
        guard
            let unbondingTime: TimeInterval = paramstore.get(
                request: request,
                key: StakingKeys.keyUnbondingTime
            )
        else {
            fatalError("unbonding time not set in Staking store")
        }
        
        return unbondingTime
    }

    // MaxValidators - Maximum number of validators
    func maxValidators(request: Request) -> UInt16 {
        guard
            let maxValidators: UInt16 = paramstore.get(
                request: request,
                key: StakingKeys.keyMaxValidators
            )
        else {
            fatalError("max validators not set in Staking store")
        }
        
        return maxValidators
    }

    // MaxEntries - Maximum number of simultaneous unbonding
    // delegations or redelegations (per pair/trio)
    func maxEntries(request: Request) -> UInt16 {
        guard
            let maxEntries: UInt16 = paramstore.get(
                request: request,
                key: StakingKeys.keyMaxEntries
            )
        else {
            fatalError("max entries not set in Staking store")
        }
        
        
        return maxEntries
    }

    // HistoricalEntries = number of historical info entries
    // to persist in store
    func historicalEntries(request: Request) -> UInt16 {
        guard
            let historicalEntries: UInt16 = paramstore.get(
                request: request,
                key: StakingKeys.keyHistoricalEntries
            )
        else {
            fatalError("historical entries not set in Staking store")
        }
        
        return historicalEntries
    }

    // BondDenom - Bondable coin denomination
    func bondDenomination(request: Request) -> String {
        guard
            let bondDenomination: String = paramstore.get(
                request: request,
                key: StakingKeys.keyBondDenomination
            )
        else {
            fatalError("bond denom not set in Staking store")
        }
        
        return bondDenomination
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
