// AccountKeeper defines the account contract that must be fulfilled when
// creating a x/bank keeper.
public protocol AccountKeeperProtocol {
    func accountWithAddress(request: Request, address: AccountAddress) -> ExportedAccount?

    func account(request: Request, address: AccountAddress) -> ExportedAccount?
    func allAccounts(request: Request) -> [ExportedAccount]
    func setAccount(request: Request, account: ExportedAccount)

    func iterateAccounts(request: Request, process: (ExportedAccount) -> Bool)
}
