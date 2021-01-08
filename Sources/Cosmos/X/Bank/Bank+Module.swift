import ABCI

// AppModuleBasic defines the basic application module used by the bank module.
public class BankAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public let name: String = BankKeys.moduleName
    
    public func register(codec: Codec) {
         // TODO: Implement
        fatalError()
    }
    
    public func defaultGenesis() -> RawMessage? {
        // TODO: Implement
        fatalError()
    }
    
    public func validateGenesis(rawMessage: RawMessage) throws {
        // TODO: Implement
        fatalError()
    }
}

//____________________________________________________________________________
// AppModule implements an application module for the bank module.
public final class BankAppModule: BankAppModuleBasic, AppModule {
    let keeper: BankKeeper
    let accountKeeper: AccountKeeper
    
    public init(
        keeper: BankKeeper,
        accountKeeper: AccountKeeper
    ) {
        self.keeper = keeper
        self.accountKeeper = accountKeeper
    }
    
    // RegisterInvariants registers the bank module invariants.
    public func registerInvariants(in invariantRegistry: InvariantRegistry) {}

    // Route returns the message routing key for the bank module.
    public var route: String {
        BankKeys.routerKey
    }

    // NewHandler returns an sdk.Handler for the bank module.
    public func makeHandler() -> Handler? {
        keeper.makeHandler()
    }
    
    // QuerierRoute returns the bank module's querier route name.
    public var querierRoute: String {
        BankKeys.routerKey
    }
    
    public func makeQuerier() -> Querier? {
        keeper.makeQuerier()
    }

    // ABCI
    public func beginBlock(request: Request, beginBlockRequest: RequestBeginBlock) {
        fatalError()
    }
    
    public func endBlock(request: Request, endBlockRequest: RequestEndBlock) -> [ValidatorUpdate] {
        fatalError()
    }
   
    // Genesis
    public func initGenesis(request: Request, rawMessage: RawMessage) -> [ValidatorUpdate] {
        fatalError()
    }
    
    public func exportGenesis(request: Request) -> RawMessage {
        fatalError()
    }
}
