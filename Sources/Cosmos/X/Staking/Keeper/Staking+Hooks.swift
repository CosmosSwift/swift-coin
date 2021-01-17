extension StakingKeeper {
    // AfterValidatorCreated - call hook if registered
    func afterValidatorCreated(request: Request, validatorAddress: ValidatorAddress) {
        if let hooks = self.hooks {
            hooks.afterValidatorCreated(request: request, validatorAddress: validatorAddress)
        }
    }
    
    // AfterValidatorBeginUnbonding - call hook if registered
    func afterValidatorBeginUnbonding(
        request: Request,
        consensusAddress: ConsensusAddress,
        validatorAddress: ValidatorAddress
    ) {
        if let hooks = hooks {
            hooks.afterValidatorBeginUnbonding(
                request: request,
                consensusAddress: consensusAddress,
                validatorAddress: validatorAddress
            )
        }
    }
}
