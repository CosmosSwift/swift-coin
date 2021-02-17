import ABCIMessages
import Cosmos
import Auth
import Supply

extension StakingKeeper {
    // InitGenesis sets the pool and parameters for the provided keeper.  For each
    // validator in data, it sets that validator in the keeper along with manually
    // setting the indexes. In addition, it also sets any delegations found in
    // data. Finally, it updates the bonded validators.
    // Returns final validator set after applying all declaration and delegations
    func initGenesis(
        request: Request,
        accountKeeper: AccountKeeper,
        supplyKeeper: SupplyKeeper,
        data: StakingGenesisState
    ) -> [ValidatorUpdate] {
        var validatorUpdates: [ValidatorUpdate] = []
        var bondedTokens: UInt = 0
        var notBondedTokens: UInt = 0

        // We need to pretend to be "n blocks before genesis", where "n" is the
        // validator update delay, so that e.g. slashing periods are correctly
        // initialized for the validator set e.g. with a one-block offset - the
        // first TM block is at height 1, so state updates applied from
        // genesis.json are in block 0.
        request.header.height = 1 - validatorUpdateDelay

        setParameters(request: request, parameters: data.parameters)
        setLastTotalPower(request: request, power: data.lastTotalPower)

        for validator in (data.validators ?? []) {
            setValidator(request: request, validator: validator)

            // Manually set indices for the first time
            setValidatorByConsensusAddress(request: request, validator: validator)
            setValidatorByPowerIndex(request: request, validator: validator)

            // Call the creation hook if not exported
            if !data.exported {
                afterValidatorCreated(request: request, validatorAddress: validator.operatorAddress)
            }

            // update timeslice if necessary
            if validator.isUnbonding {
                insertValidatorQueue(request: request, validator: validator)
            }

            switch validator.status {
            case .bonded:
                bondedTokens += validator.tokens
            case .unbonding, .unbonded:
                notBondedTokens += validator.tokens
            }
        }

        // TODO: Implement
//        for delegation in data.delegations {
//            // Call the before-creation hook if not exported
//            if !data.exported {
//                beforeDelegationCreated(
//                    request: request,
//                    deleggatorAddress: delegation.delegatorAddress,
//                    validatorAddress: delegation.validatorAddress
//                )
//            }
//
//            setDelegation(request: request, delegation: delegation)
//
//            // Call the after-modification hook if not exported
//            if !data.exported {
//                afterDelegationModified(
//                    request: request,
//                    delegatorAddress: delegation.delegatorAddress,
//                    validatorAddress: delegation.validatorAddress
//                )
//            }
//        }
//
//        for unbondingDelegation in data.unbondingDelegations {
//            setUnbondingDelegation(request: request, unbondingDelegation: unbondingDelegation)
//
//            for entry in unbondingDelegation.entries {
//                insertUnbondingDelegationQueue(
//                    request: request,
//                    unbondingDelegation,
//                    entry.completionTime
//                )
//
//                notBondedTokens = notBondedTokens + entry.balance
//            }
//        }
//
//        for redelegation in data.redelegations {
//            setRedelegation(request: request, redelegation: redelegation)
//
//            for entry in redelegation.entries {
//                insertRedelegationQueue(
//                    request: request,
//                    redelegation: redelegation,
//                    entry.completionTime
//                )
//            }
//        }

        let bondedCoins = Coins(coins: [Coin(denomination: data.parameters.bondDenomination, amount: UInt(bondedTokens))])
        let notBondedCoins = Coins(coins: [Coin(denomination: data.parameters.bondDenomination, amount: UInt(notBondedTokens))])

        // check if the unbonded and bonded pools accounts exists
        guard var bondedPool = self.bondedPool(request: request) else {
            fatalError("\(StakingKeys.bondedPoolName) module account has not been set")
        }

        // TODO remove with genesis 2-phases refactor https://github.com/cosmos/cosmos-sdk/issues/2862
        // add coins if not provided on genesis
        if bondedPool.coins.isEmpty {
            try! bondedPool.set(coins: bondedCoins)
            supplyKeeper.setModuleAccount(request: request, moduleAccount: bondedPool)
        }

        guard var notBondedPool = self.notBondedPool(request: request) else {
            fatalError("\(StakingKeys.notBondedPoolName) module account has not been set")
        }

        if notBondedPool.coins.isEmpty {
            try! notBondedPool.set(coins: notBondedCoins)
            supplyKeeper.setModuleAccount(request: request, moduleAccount: notBondedPool)
        }

        // don't need to run Tendermint updates if we exported
        if data.exported {
            for lastValidatorPower in data.lastValidatorPowers {
                setLastValidatorPower(
                    request: request,
                    operator: lastValidatorPower.address,
                    power: lastValidatorPower.power
                )
                
                guard let validator = self.validator(request: request, address: lastValidatorPower.address) else {
                    fatalError("validator \(lastValidatorPower.address) not found")
                }
                
                // keep the next-val-set offset, use the last power for the first block
                var update = ValidatorUpdate(publicKey: validator.abciValidatorUpdate.publicKey, power: lastValidatorPower.power)
                validatorUpdates.append(update)
            }
        } else {
            validatorUpdates = applyAndReturnValidatorSetUpdates(request: request)
        }

        return validatorUpdates
    }
}
