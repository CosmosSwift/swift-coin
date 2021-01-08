// GenesisState - all staking state that must be provided at genesis
struct StakingGenesisState: Codable {
    let parameters: StakingParameters
    let lastTotalPower: Int = 0
    let lastValidatorPowers: [LastValidatorPower] = []
//    let validators: Validators
//    let delegations: Delegations
//    let unbondingDelegations: [UnbondingDelegation]
//    let redelegations: [Redelegation]
    let exported: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case parameters = "params"
        case lastTotalPower = "last_total_power"
        case lastValidatorPowers = "last_validator_powers"
//        case validators
//        case delegations
//        case unbondingDelegations = "unbonding_delegations"
//        case redelegations
        case exported
    }
    
    // NewGenesisState creates a new GenesisState instanc e
    init(
        parameters: StakingParameters
//        validators: [Validator] = [],
//        delegations: [Delegation] = []
    ) {
        self.parameters = parameters
//        self.validators = validators
//        self.delegations = delegations
    }
}

// LastValidatorPower required for validator set update logic
struct LastValidatorPower: Codable {
    let address: ValidatorAddress
    let power: Int64
}

extension StakingGenesisState {
    // DefaultGenesisState gets the raw genesis raw message for testing
    static var `default`: StakingGenesisState {
        StakingGenesisState(parameters: .default)
    }
}
