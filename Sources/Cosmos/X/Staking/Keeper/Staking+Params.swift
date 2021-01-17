extension StakingKeys {
    // Default parameter namespace
    public static let defaultParamspace = moduleName
}

extension StakingKeeper {
    // BondDenom - Bondable coin denomination
    func bondDenomination(request: Request) -> String {
        paramstore.get(request: request, key: StakingKeys.keyBondDenomination)
    }

}

// set the params
extension StakingKeeper {
    func setParameters(request: Request, parameters: StakingParameters) {
        paramstore.setParameterSet(request: request, parameterSet: parameters)
    }
}
