import Foundation
import Tendermint
import ABCIMessages
import Cosmos

// Validator defines the total amount of bond shares and their exchange rate to
// coins. Slashing results in a decrease in the exchange rate, allowing correct
// calculation of future undelegations without iterating over delegators.
// When coins are delegated to this validator, the validator is credited with a
// delegation whose number of bond shares is based on the amount of coins delegated
// divided by the current exchange rate. Voting power can be calculated as total
// bonded shares multiplied by exchange rate.
struct Validator: Codable {
    // address of the validator's operator; bech encoded in JSON
    let operatorAddress: ValidatorAddress
    // the consensus public key of the validator; bech encoded in JSON
    let consensusPublicKey: Tendermint.PublicKey
    // has the validator been jailed from bonded status?
    let jailed: Bool
    // validator status (bonded/unbonding/unbonded)
    var status: BondStatus
    // delegated tokens (incl. self-delegation)
    let tokens: UInt
    // total shares issued to a validator's delegators
    let delegatorShares: Decimal
    // description terms for the validator
    // TODO: Implment
//    let description: Description
    // if unbonding, height at which this validator has begun unbonding
    var unbondingHeight: Int64
    // if unbonding, min time for the validator to complete unbonding
    var unbondingCompletionTime: Date
    // commission parameters
    // TODO: Implement
//    let commission: Commission
    // validator's self declared minimum self delegation
    let minSelfDelegation: Int
    
    private enum CodingKeys: String, CodingKey {
        case operatorAddress
        case consensusPublicKey
        case jailed
        case status
        case tokens
        case delegatorShares
        case unbondingHeight
        case unbondingCompletionTime
        case minSelfDelegation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operatorAddress = try container.decode(ValidatorAddress.self, forKey: .operatorAddress)
        
        let publicKeyCodable = try container.decode(AnyProtocolCodable.self, forKey: .consensusPublicKey)
        
        guard let publicKey = publicKeyCodable.value as? Tendermint.PublicKey else {
            throw DecodingError.dataCorruptedError(
                forKey: .consensusPublicKey,
                in: container,
                debugDescription: "Invalid public key type"
            )
        }
        
        self.consensusPublicKey = publicKey
        self.jailed = try container.decode(Bool.self, forKey: .jailed)
        self.status = try container.decode(BondStatus.self, forKey: .status)
        self.tokens = try container.decode(UInt.self, forKey: .tokens)
        self.delegatorShares = try container.decode(Decimal.self, forKey: .delegatorShares)
        self.unbondingHeight = try container.decode(Int64.self, forKey: .unbondingHeight)
        self.unbondingCompletionTime = try container.decode(Date.self, forKey: .unbondingCompletionTime)
        self.minSelfDelegation = try container.decode(Int.self, forKey: .minSelfDelegation)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(operatorAddress, forKey: .operatorAddress)
        try container.encode(AnyProtocolCodable(consensusPublicKey), forKey: .consensusPublicKey)
        try container.encode(jailed, forKey: .jailed)
        try container.encode(status, forKey: .status)
        try container.encode(tokens, forKey: .tokens)
        try container.encode(delegatorShares, forKey: .delegatorShares)
        try container.encode(unbondingHeight, forKey: .unbondingHeight)
        try container.encode(unbondingCompletionTime, forKey: .unbondingCompletionTime)
        try container.encode(minSelfDelegation, forKey: .minSelfDelegation)
    }
}


extension Validator {
    // return the TM validator address
    var consensusAddress: ConsensusAddress {
        ConsensusAddress(data: consensusPublicKey.address.rawValue)
    }

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
            publicKey: ABCIMessages.PublicKey(consensusPublicKey),
            power: consensusPower
        )
    }
    
    // ABCIValidatorUpdateZero returns an abci.ValidatorUpdate from a staking validator type
    // with zero power used for validator updates.
    var abciValidatorUpdateZero: ValidatorUpdate {
        ValidatorUpdate(
            publicKey: ABCIMessages.PublicKey(consensusPublicKey),
            power:  0
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
