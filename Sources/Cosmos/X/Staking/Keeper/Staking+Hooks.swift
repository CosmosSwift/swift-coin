extension StakingKeeper {
    // AfterValidatorCreated - call hook if registered
    func afterValidatorCreated(request: Request, validatorAddress: ValidatorAddress) {
        if let hooks = self.hooks {
            hooks.afterValidatorCreated(request: request, validatorAddress: validatorAddress)
        }
    }
}
