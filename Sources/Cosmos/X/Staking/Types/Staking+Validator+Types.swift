import Foundation
import Tendermint
import ABCI

// Validator defines the total amount of bond shares and their exchange rate to
// coins. Slashing results in a decrease in the exchange rate, allowing correct
// calculation of future undelegations without iterating over delegators.
// When coins are delegated to this validator, the validator is credited with a
// delegation whose number of bond shares is based on the amount of coins delegated
// divided by the current exchange rate. Voting power can be calculated as total
// bonded shares multiplied by exchange rate.
struct Validator: Codable  {
    // address of the validator's operator; bech encoded in JSON
    let operatorAddress: ValidatorAddress
    // the consensus public key of the validator; bech encoded in JSON
    let consensusPublicKey: Tendermint.PublicKey
    // has the validator been jailed from bonded status?
    let jailed: Bool
    // validator status (bonded/unbonding/unbonded)
    let status: BondStatus
    // delegated tokens (incl. self-delegation)
    let tokens: Int
    // total shares issued to a validator's delegators
    let delegatorShares: Decimal
    // description terms for the validator
    // TODO: Implment
//    let description: Description
    // if unbonding, height at which this validator has begun unbonding
    let unbondingHeight: Int64
    // if unbonding, min time for the validator to complete unbonding
    let unbondingCompletionTime: Date
    // commission parameters
    // TODO: Implement
//    let commission: Commission
    // validator's self declared minimum self delegation
    let minSelfDelegation: Int
}


extension Validator {
    // IsBonded checks if the validator status equals Bonded
    var isBonded: Bool {
        status == .bonded
    }

    // IsUnbonded checks if the validator status equals Unbonded
    var isUnbonded: Bool {
        status == .unbonded
    }

    // IsUnbonding checks if the validator status equals Unbonding
    var isUnbonding: Bool {
        status == .unbonding
    }
}

extension Validator {
    // ABCIValidatorUpdate returns an abci.ValidatorUpdate from a staking validator type
    // with the full validator power
    var abciValidatorUpdate: ValidatorUpdate {
        ValidatorUpdate(
            publicKey: ABCI.PublicKey(consensusPublicKey),
            power: consensusPower
        )
    }
    
    // get the consensus-engine power
    // a reduction of 10^6 from validator tokens is applied
    var consensusPower: Int64 {
        if isBonded {
            return potentialConsensusPower
        }
        
        return 0
    }

    // potential consensus-engine power
    var potentialConsensusPower: Int64 {
        tokensToConsensusPower(tokens: tokens)
    }
}
