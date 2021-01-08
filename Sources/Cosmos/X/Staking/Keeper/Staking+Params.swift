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
