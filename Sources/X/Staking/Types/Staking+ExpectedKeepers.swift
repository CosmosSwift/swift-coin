import Foundation
import Cosmos

//// DistributionKeeper expected distribution keeper (noalias)
//protocol DistributionKeeper {
//    func feePoolCommunityCoins(request: Request) -> DecimalCoins
//    func validatorOutstandingRewardsCoins(request: Request, validator: ValidatorAddress) -> DecimalCoins
//}
//
//// AccountKeeper defines the expected account keeper (noalias)
//protocol AccountKeeper {
//    func iterateAccounts(request: Request, process: (ExportedAccount) -> Bool)
//    func account(request: Request, address: AccountAddress) -> ExportedAccount // only used for simulation
//}
//
//// SupplyKeeper defines the expected supply Keeper (noalias)
//protocol SupplyKeeper {
//    func supply(request: Request) -> ExportedSupply
//
//    func mduleAddress(name: String) -> AccountAddress
//    func moduleAccount(request: Request, moduleName: String) -> ExportedModuleAccount
//
//    // TODO remove with genesis 2-phases refactor https://github.com/cosmos/cosmos-sdk/issues/2862
//    func setModuleAccount(request: Request, moduleAccount: ExportedModuleAccount)
//
//    func sendCoinsFromModuleToModule(
//        request: Request,
//        senderPool: String,
//        recipientPool: String,
//        amount: Coins
//    ) throws
//  
//    func undelegateCoinsFromModuleToAccount(
//        request: Request,
//        senderModule: String,
//        recipientAddress: AccountAddress,
//        amount: Coins
//    ) throws
//   
//    func delegateCoinsFromAccountToModule(
//        request: Request,
//        senderAddress: AccountAddress,
//        recipientModule: String,
//        amount: Coins
//    ) throws
//
//    func burnCoins(request: Request, name: String, amount: Coins) throws
//}
//
//// ValidatorSet expected properties for the set of all validators (noalias)
//protocol ValidatorSet {
//    // iterate through validators by operator address, execute func for each validator
//    func iterateValidators(
//        request: Request,
//        body: (_ index: Int64, _ validator: ExportedValidator) -> Bool
//    )
//
//    // iterate through bonded validators by operator address, execute func for each validator
//    func iterateBondedValidatorsByPower(
//        request: Request,
//        body: (_ index: Int64, _ validator: ExportedValidator) -> Bool
//    )
//
//    // iterate through the consensus validator set of the last block by operator address, execute func for each validator
//    func iterateLastValidators(
//        request: Request,
//        body: (_ index: Int64, _ validator: ExportedValidator) -> Bool
//    )
//
//    // get a particular validator by operator address
//    func validator(request: Request, address: ValidatorAddress) -> ExportedValidator
//    // get a particular validator by consensus address
//    func validatorByConsAddr(request: Request, consensusAddress: ConsensusAddress) -> ExportedValidator
//    // total bonded tokens within the validator set
//    func totalBondedTokens(request: Request) -> Int
//    // total staking token supply
//    func stakingTokenSupply(request: Request) -> Int
//
//    // slash the validator and delegators of the validator, specifying offence height, offence power, and slash fraction
//    func slash(
//        request: Request,
//        consensusAddress: ConsensusAddress,
//        height: Int64,
//        offencePower: Int64,
//        slashFraction: Decimal
//    )
//    
//    // jail a validator
//    func jail(request: Request, consensusAddress: ConsensusAddress)
//    // unjail a validator
//    func unjail(request: Request, consensusAddress: ConsensusAddress)
//
//    // Delegation allows for getting a particular delegation for a given validator
//    // and delegator outside the scope of the staking module.
//    func delegation(
//        request: Request,
//        accountAddress: AccountAddress,
//        validatorAddress: ValidatorAddress
//    ) -> ExportedDelegation
//
//    // MaxValidators returns the maximum amount of bonded validators
//    func maxValidators(request: Request) -> UInt16
//}
//
//// DelegationSet expected properties for the set of all delegations for a particular (noalias)
//protocol DelegationSet {
//    func validatorSet() -> ValidatorSet // validator set for which delegation set is based upon
//
//    // iterate through all delegations from one delegator by validator-AccAddress,
//    //   execute func for each validator
//    func iterateDelegations(
//        request: Request,
//        delegator: AccountAddress,
//        body: (_ index: Int64, _ delegation: ExportedDelegation) -> Bool
//    )
//}

//_______________________________________________________________________________
// Event Hooks
// These can be utilized to communicate between a staking keeper and another
// keeper which must take particular actions when validators/delegators change
// state. The second keeper must implement this interface, which then the
// staking keeper can call.

// StakingHooks event hooks for staking validator object (noalias)
public protocol StakingHooks {
    // Must be called when a validator is created
    func afterValidatorCreated(
        request: Request,
        validatorAddress: ValidatorAddress
    )
    
    // Must be called when a validator's state changes
    func beforeValidatorModified(
        request: Request,
        validatorAddress: ValidatorAddress
    )
    
    // Must be called when a validator is deleted
    func afterValidatorRemoved(
        request: Request,
        consensusAddress: ConsensusAddress,
        validatorAddress: ValidatorAddress
    )

    // Must be called when a validator is bonded
    func afterValidatorBonded(
        request: Request,
        consensusAddress: ConsensusAddress,
        validatorAddress: ValidatorAddress
    )
    
    // Must be called when a validator begins unbonding
    func afterValidatorBeginUnbonding(
        request: Request,
        consensusAddress: ConsensusAddress,
        validatorAddress: ValidatorAddress
    )

    // Must be called when a delegation is created
    func beforeDelegationCreated(
        request: Request,
        delegationAddress: AccountAddress,
        validatorAddress: ValidatorAddress
    )
    
    // Must be called when a delegation's shares are modified
    func beforeDelegationSharesModified(
        request: Request,
        delegationAddress: AccountAddress,
        validatorAddress: ValidatorAddress
    )
    
    // Must be called when a delegation is removed
    func beforeDelegationRemoved(
        request: Request,
        delegationAddress: AccountAddress,
        validatorAddress: ValidatorAddress
    )
    
    func afterDelegationModified(
        request: Request,
        delegationAddress: AccountAddress,
        validatorAddress: ValidatorAddress
    )
    
    func beforeValidatorSlashed(
        request: Request,
        validatorAddress: ValidatorAddress,
        fraction: Decimal
    )
}
