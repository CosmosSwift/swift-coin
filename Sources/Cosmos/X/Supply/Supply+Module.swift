import ABCI

// AppModuleBasic defines the basic application module used by the supply module.
public class SupplyAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public let name: String = SupplyKeys.moduleName
    
    public func register(codec: Codec) {
        // TODO: Implement
        fatalError()
    }
    
    public func defaultGenesis() -> RawMessage {
        // TODO: Implement
        fatalError()
    }
    
    public func validateGenesis(rawMessage: RawMessage) throws {
        // TODO: Implement
        fatalError()
    }
}

//____________________________________________________________________________
// AppModule implements an application module for the supply module.
public final class SupplyAppModule: SupplyAppModuleBasic, AppModule {
    let keeper: SupplyKeeper
    let accountKeeper: AccountKeeper
    
    public init(
        keeper: SupplyKeeper,
        accountKeeper: AccountKeeper
    ) {
        self.keeper = keeper
        self.accountKeeper = accountKeeper
    }
    
    // RegisterInvariants registers the supply module invariants.
    public func registerInvariants(in invariantRegistry: InvariantRegistry) {
        keeper.registerInvariants(in: invariantRegistry)
    }

    // Route returns the message routing key for the supply module.
    public var route: String {
        SupplyKeys.routerKey
    }
    
    // NewHandler returns an sdk.Handler for the supply module.
    public func makeHandler() -> Handler? { nil }
    
    // QuerierRoute returns the supply module's querier route name.
    public var querierRoute: String {
        SupplyKeys.querierRoute
    }
    
    // NewQuerierHandler returns the supply module sdk.Querier.
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

