// combine multiple staking hooks, all hook functions are run in array sequence
public typealias MultiStakingHooks = [StakingHooks]

extension MultiStakingHooks {
    public init(_ hooks: StakingHooks...) {
        self = hooks
    }
}

extension MultiStakingHooks: StakingHooks {}
