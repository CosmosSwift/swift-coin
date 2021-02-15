import Cosmos
import Auth
import Params

// Keeper defines a module interface that facilitates the transfer of coins
// between accounts.
public protocol BankKeeper: SendKeeper {
    func delegateCoins(
        request: Request,
        delegatorAddress: AccountAddress,
        moduleAccountAddress: AccountAddress,
        amount: Coins
    ) throws
    
    func undelegateCoins(
        request: Request,
        moduleAccountAddress: AccountAddress,
        delegatorAddress: AccountAddress,
        amount: Coins
    ) throws
}

// BaseKeeper manages transfers between accounts. It implements the Keeper interface.
public final class BaseKeeper: BaseSendKeeper, BankKeeper  {
    /// InitGenesis initializes the bank module's state from a given genesis state.
    public func initGenesis(request: Request, state: BankGenesisState) {
        // TODO: Implement
        fatalError()
    }

    // NewBaseKeeper returns a new BaseKeeper
    public override init(
        accountKeeper: AccountKeeper,
        paramSpace: Subspace,
        blacklistedAddresses: [String: Bool]
    ) {
        let paramSpace = paramSpace.with(keyTable: .paramKeyTable)
        
        super.init(
            accountKeeper: accountKeeper,
            paramSpace: paramSpace,
            blacklistedAddresses: blacklistedAddresses
        )
    }
    
    // DelegateCoins performs delegation by deducting amt coins from an account with
    // address addr. For vesting accounts, delegations amounts are tracked for both
    // vesting and vested coins.
    // The coins are then transferred from the delegator address to a ModuleAccount address.
    // If any of the delegation amounts are negative, an error is returned.
    public func delegateCoins(request: Request, delegatorAddress: AccountAddress, moduleAccountAddress: AccountAddress, amount: Coins) throws {
        // TODO: Implement
        fatalError()
//        guard let delegatorAccount = accountKeeper.account(request: request, address: delegatorAddress) else {
//            throw Cosmos.Error.unknownAddress(reason: "account \(delegatorAddress) does not exist")
//        }
//
//        guard let moduleAccount = accountKeeper.account(request: request, address: moduleAccountAddress) else {
//            throw Cosmos.Error.unknownAddress(reason: "module account \(moduleAccountAddress) does not exist")
//        }

        // TODO: Implement isValid
//        if !amount.isValid {
//            throw Cosmos.Error.invalidCoins(reason: "\(amount)")
//        }

//        let oldCoins = delegatorAccount.coins

        // TODO: Implement safeSubtract
//        let (_, hasNegative) = oldCoins.safeSubtract(amount)
      
//        if hasNegative {
//            throw Cosmos.Error.insufficientFunds(reason: "insufficient account funds; \(oldCoins) < \(amount)")
//        }

        // TODO: Implement trackDelegation
//        try trackDelegation(delegatorAccount, request.blockHeader().time, amount)

//        accountKeeper.setAccount(request: request, account: delegatorAccount)

//        try addCoins(request: request, address: moduleAccountAddress, amount: amount)
    }
    
    public func undelegateCoins(request: Request, moduleAccountAddress: AccountAddress, delegatorAddress: AccountAddress, amount: Coins) throws {
        // TODO: Implement
        fatalError()
    }
    
    public func inputOutputCoins(request: Request, inputs: [Input], outputs: [Output]) throws {
        // TODO: Implement
        fatalError()
    }
    
    public func sendCoins(request: Request, fromAddress: AccountAddress, toAddress: AccountAddress, amount: Coins) throws {
        // TODO: Implement
        fatalError()
    }
    
    public func subtractCoins(requet: Request, address: AccountAddress, amount: Coins) throws -> Coins {
        // TODO: Implement
        fatalError()

    }
    
    // TODO: Check if it's OK to discard the result
    @discardableResult
    public func addCoins(request: Request, address: AccountAddress, amount: Coins) throws -> Coins {
        // TODO: Implement
        fatalError()
    }
    
    public func setCoins(request: Request, address: AccountAddress, amount: Coins) throws {
        // TODO: Implement
        fatalError()
    }
    
    // GetSendEnabled returns the current SendEnabled
    public func isSendEnabled(request: Request) -> Bool {
        guard let res: Bool = paramSpace.get(
            request: request,
            key: KeyTable.paramStoreKeySendEnabled
        ) else {
            fatalError("send_enabled parameter not set in Bank store")
        }
        return res
    }
    
    // SetSendEnabled sets the send enabled
    public func setSendEnabled(request: Request, enabled: Bool) {
        paramSpace.set(
            request: request,
            key: KeyTable.paramStoreKeySendEnabled,
            value: enabled
        )
    }
    
    public func isBlacklisted(address: AccountAddress) -> Bool {
        blacklistedAddresses[address.description] != nil
    }
    
    public func coins(request: Request, address: AccountAddress) -> Coins? {
        // TODO: Implement
        fatalError()
    }
    
    public func hasCoins(request: Request, address: AccountAddress, amount: Coins) -> Bool {
        // TODO: Implement
        fatalError()
    }
}

// BaseSendKeeper only allows transfers between accounts without the possibility of
// creating coins. It implements the SendKeeper interface.
public class BaseSendKeeper: BaseViewKeeper {
    let paramSpace: Subspace
    // list of addresses that are restricted from receiving transactions
    let blacklistedAddresses: [String: Bool]
    
    init(
        accountKeeper: AccountKeeper,
        paramSpace: Subspace,
        blacklistedAddresses: [String: Bool]
    ) {
        self.paramSpace = paramSpace
        self.blacklistedAddresses = blacklistedAddresses
        super.init(accountKeeper: accountKeeper)
    }
}

extension BaseSendKeeper {
}

// BaseViewKeeper implements a read only keeper implementation of ViewKeeper.
public class BaseViewKeeper {
    let accountKeeper: AccountKeeper
    
    init(accountKeeper: AccountKeeper) {
        self.accountKeeper = accountKeeper
    }
}

// SendKeeper defines a module interface that facilitates the transfer of coins
// between accounts without the possibility of creating coins.
public protocol SendKeeper: ViewKeeper {
    func inputOutputCoins(request: Request, inputs: [Input], outputs: [Output]) throws
    func sendCoins(request: Request, fromAddress: AccountAddress, toAddress: AccountAddress, amount: Coins) throws

    // TODO: Check if it's OK to discard the result
    @discardableResult
    func subtractCoins(requet: Request, address: AccountAddress, amount: Coins) throws -> Coins
    // TODO: Check if it's OK to discard the result
    @discardableResult
    func addCoins(request: Request, address: AccountAddress, amount: Coins) throws -> Coins
    func setCoins(request: Request, address: AccountAddress, amount: Coins) throws

    func isSendEnabled(request: Request) -> Bool
    func setSendEnabled(request: Request, enabled: Bool)

    func isBlacklisted(address: AccountAddress) -> Bool
}

// ViewKeeper defines a module interface that facilitates read only access to
// account balances.
public protocol ViewKeeper {
    func coins(request: Request, address: AccountAddress) -> Coins?
    func hasCoins(request: Request, address: AccountAddress, amount: Coins) -> Bool
}
