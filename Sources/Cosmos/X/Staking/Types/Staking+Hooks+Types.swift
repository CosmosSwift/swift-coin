import Foundation

// combine multiple staking hooks, all hook functions are run in array sequence
public typealias MultiStakingHooks = [StakingHooks]

extension MultiStakingHooks {
    public init(_ hooks: StakingHooks...) {
        self = hooks
    }
}

extension MultiStakingHooks: StakingHooks {
    public func afterValidatorCreated(request: Request, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.afterValidatorCreated(request: request, validatorAddress: validatorAddress)
        }
    }
    
    public func beforeValidatorModified(request: Request, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.beforeValidatorModified(request: request, validatorAddress: validatorAddress)
        }
    }
    
    public func afterValidatorRemoved(request: Request, consensusAddress: ConsensusAddress, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.afterValidatorRemoved(request: request, consensusAddress: consensusAddress, validatorAddress: validatorAddress)
        }
    }
    
    public func afterValidatorBonded(request: Request, consensusAddress: ConsensusAddress, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.afterValidatorBonded(request: request, consensusAddress: consensusAddress, validatorAddress: validatorAddress)
        }
    }
    
    public func afterValidatorBeginUnbonding(request: Request, consensusAddress: ConsensusAddress, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.afterValidatorBeginUnbonding(request: request, consensusAddress: consensusAddress, validatorAddress: validatorAddress)
        }
    }
    
    public func beforeDelegationCreated(request: Request, delegationAddress: AccountAddress, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.beforeDelegationCreated(request: request, delegationAddress: delegationAddress, validatorAddress: validatorAddress)
        }
    }
    
    public func beforeDelegationSharesModified(request: Request, delegationAddress: AccountAddress, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.beforeDelegationSharesModified(request: request, delegationAddress: delegationAddress, validatorAddress: validatorAddress)
        }
    }
    
    public func beforeDelegationRemoved(request: Request, delegationAddress: AccountAddress, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.beforeDelegationRemoved(request: request, delegationAddress: delegationAddress, validatorAddress: validatorAddress)
        }
    }
    
    public func afterDelegationModified(request: Request, delegationAddress: AccountAddress, validatorAddress: ValidatorAddress) {
        for hook in self {
            hook.afterDelegationModified(request: request, delegationAddress: delegationAddress, validatorAddress: validatorAddress)
        }
    }
    
    public func beforeValidatorSlashed(request: Request, validatorAddress: ValidatorAddress, fraction: Decimal) {
        for hook in self {
            hook.beforeValidatorSlashed(request: request, validatorAddress: validatorAddress, fraction: fraction)
        }
    }
}
