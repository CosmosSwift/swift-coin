import ABCIMessages
import Tendermint
import Cosmos

// GenesisState - all staking state that must be provided at genesis
public struct StakingGenesisState: Codable, AppState {
    static public var metatype: String { "staking" }

    let parameters: StakingParameters
    let lastTotalPower: Int = 0
    let lastValidatorPowers: [LastValidatorPower] = []
    let validators: [Validator]?
//    let delegations: Delegations
//    let unbondingDelegations: [UnbondingDelegation]
//    let redelegations: [Redelegation]
    let exported: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case parameters = "params"
        case lastTotalPower = "last_total_power"
        case lastValidatorPowers = "last_validator_powers"
        case validators
//        case delegations
//        case unbondingDelegations = "unbonding_delegations"
//        case redelegations
        case exported
    }
    
    // NewGenesisState creates a new GenesisState instance
    init(
        parameters: StakingParameters,
        validators: [Validator] = []
//        delegations: [Delegation] = []
    ) {
        self.parameters = parameters
        self.validators = validators
//        self.delegations = delegations
    }
}

// LastValidatorPower required for validator set update logic
public struct LastValidatorPower: Codable {
    let address: ValidatorAddress
    let power: Int64
}

extension StakingGenesisState {
    // DefaultGenesisState gets the raw genesis raw message for testing
    static var `default`: StakingGenesisState {
        StakingGenesisState(parameters: .default)
    }
    
    public init(default:Void) {
        self.init(parameters: .default)
    }
}
