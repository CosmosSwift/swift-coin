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
    // NewBaseKeeper returns a new BaseKeeper
    public override init(
        accountKeeper: AccountKeeperProtocol,
        paramSpace: Subspace,
        blacklistedAddresses: [String: Bool]
    ) {
        let paramSpace = paramSpace.with(keyTable: .paramKeyTable())
        
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
    
    public func getSendEnabled(request: Request) -> Bool {
        // TODO: Implement
        fatalError()
    }
    
    public func setSendEnabled(request: Request, enabled: Bool) {
        // TODO: Implement
        fatalError()
    }
    
    public func blacklistedAddress(address: AccountAddress) -> Bool {
        // TODO: Implement
        fatalError()
    }
    
    public func getCoins(request: Request, address: AccountAddress) -> Coins {
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
        accountKeeper: AccountKeeperProtocol,
        paramSpace: Subspace,
        blacklistedAddresses: [String: Bool]
    ) {
        self.paramSpace = paramSpace
        self.blacklistedAddresses = blacklistedAddresses
        super.init(accountKeeper: accountKeeper)
    }
}

// BaseViewKeeper implements a read only keeper implementation of ViewKeeper.
public class BaseViewKeeper {
    let accountKeeper: AccountKeeperProtocol
    
    init(accountKeeper: AccountKeeperProtocol) {
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

    func getSendEnabled(request: Request) -> Bool
    func setSendEnabled(request: Request, enabled: Bool)

    func blacklistedAddress(address: AccountAddress) -> Bool
}

// ViewKeeper defines a module interface that facilitates read only access to
// account balances.
public protocol ViewKeeper {
    func getCoins(request: Request, address: AccountAddress) -> Coins
    func hasCoins(request: Request, address: AccountAddress, amount: Coins) -> Bool
}
