import JSON
import ABCI

// AppModuleBasic defines the basic application module used by the bank module.
public class BankAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public let name: String = BankKeys.moduleName
    
    public func register(codec: Codec) {
         // TODO: Implement
        fatalError()
    }
    
    public func defaultGenesis() -> JSON? {
        let data = Codec.bankCodec.mustMarshalJSON(value: BankGenesisState.default)
        return Codec.bankCodec.mustUnmarshalJSON(data: data)
    }
    
    public func validateGenesis(json: JSON) throws {
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

    // MARK: ABCI
    /// BeginBlock performs a no-op.
    public func beginBlock(request: Request, beginBlockRequest: RequestBeginBlock) {
    }
    
    /// EndBlock returns the end blocker for the bank module. It returns no validator
    /// updates.
    public func endBlock(request: Request, endBlockRequest: RequestEndBlock) -> [ValidatorUpdate] {
        []
    }
   
    // MARK: Genesis
    /// InitGenesis performs genesis initialization for the bank module. It returns
    /// no validator updates.
    public func initGenesis(request: Request, json: JSON) -> [ValidatorUpdate] {
        let data = Codec.bankCodec.mustMarshalJSON(value: json)
        let genesisState: BankGenesisState = Codec.bankCodec.mustUnmarshalJSON(data: data)
        keeper.initGenesis(request: request, state: genesisState)
        return []
//        func (am AppModule) InitGenesis(ctx sdk.Context, cdc codec.JSONMarshaler, data json.RawMessage) []abci.ValidatorUpdate {
//            start := time.Now()
//            var genesisState types.GenesisState
//            cdc.MustUnmarshalJSON(data, &genesisState)
//            telemetry.MeasureSince(start, "InitGenesis", "crisis", "unmarshal")
//
//            am.keeper.InitGenesis(ctx, &genesisState)
//            return []abci.ValidatorUpdate{}
//        }
    }
    
    /// ExportGenesis returns the exported genesis state as raw bytes for the bank
    /// module.
    public func exportGenesis(request: Request) -> JSON {
        fatalError()
//        func (am AppModule) ExportGenesis(ctx sdk.Context, cdc codec.JSONMarshaler) json.RawMessage {
//            gs := am.keeper.ExportGenesis(ctx)
//            return cdc.MustMarshalJSON(gs)
//        }
    }
}
