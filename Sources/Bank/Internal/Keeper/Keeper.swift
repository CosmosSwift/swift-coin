import Cosmos

// Keeper defines a module interface that facilitates the transfer of coins
// between accounts.
public protocol Keeper: SendKeeper {
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

// SendKeeper defines a module interface that facilitates the transfer of coins
// between accounts without the possibility of creating coins.
public protocol SendKeeper: ViewKeeper {
    func inputOutputCoins(request: Request, inputs: [Input], outputs: [Output]) throws
    func sendCoins(request: Request, fromAddress: AccountAddress, toAddress: AccountAddress, amount: Coins) throws

    @discardableResult
    func subtractCoins(requet: Request, address: AccountAddress, amount: Coins) throws -> Coins
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
