import ABCI

// AppModuleBasic defines the basic application module used by the auth module.
public class AuthAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public let name: String = AuthKeys.moduleName
    
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

// AppModule implements an application module for the auth module.
public class AuthAppModule: AuthAppModuleBasic, AppModule {
    let accountKeeper: AccountKeeper
    
    public init(accountKeeper: AccountKeeper) {
        self.accountKeeper = accountKeeper
    }
    
    // RegisterInvariants performs a no-op.
    public func registerInvariants(in invariantRegistry: InvariantRegistry) {}

    // Route returns the message routing key for the auth module.
    public var route: String { "" }
    
    // NewHandler returns an sdk.Handler for the auth module.
    public func makeHandler() -> Handler? { nil }
    
    // QuerierRoute returns the auth module's querier route name.
    public var querierRoute: String { AuthKeys.querierRoute }
    
    // NewQuerierHandler returns the auth module sdk.Querier.
    public func makeQuerier() -> Querier? {
        accountKeeper.makeQuerier()
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

