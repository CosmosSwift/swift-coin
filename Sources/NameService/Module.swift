import ABCI
import Cosmos

// AppModuleBasic defines the basic application module used by the nameservice module.
public struct NameServiceAppModuleBasic: AppModuleBasic {
    // TODO: Probably all of AppModuleBasic requirements should be static
    public init() {}

    // Name returns the nameservice module's name.
    public var name: String {
        NameServiceKeys.moduleName
    }
    
    public func register(codec: Codec) {
        // TODO: Maybe store codec here
        Codec.register(codec: codec)
    }

    // DefaultGenesis returns default genesis state as raw bytes for the nameservice
    // module.
    public func defaultGenesis() -> RawMessage? {
        Codec.moduleCodec.mustMarshalJSON(value: GenesisState.default)
    }

    // ValidateGenesis performs genesis state validation for the nameservice module.
    public func validateGenesis(rawMessage: RawMessage) throws {
        let genesisState: GenesisState = try Codec.moduleCodec.unmarshalJSON(data: rawMessage)
        try genesisState.validate()
    }

//    // RegisterRESTRoutes registers the REST routes for the nameservice module.
//    func (AppModuleBasic) RegisterRESTRoutes(ctx context.CLIContext, rtr *mux.Router) {
//        rest.RegisterRoutes(ctx, rtr)
//    }
//
//    // GetTxCmd returns the root tx command for the nameservice module.
//    func (AppModuleBasic) GetTxCmd(cdc *codec.Codec) *cobra.Command {
//        return cli.GetTxCmd(cdc)
//    }
//
//    // GetQueryCmd returns no root query command for the nameservice module.
//    func (AppModuleBasic) GetQueryCmd(cdc *codec.Codec) *cobra.Command {
//        return cli.GetQueryCmd(types.StoreKey, cdc)
//    }
}

//____________________________________________________________________________

// AppModule implements an application module for the nameservice module.
public struct NameServiceAppModule: AppModule {
    let keeper: NameServiceKeeper
    let coinKeeper: BankKeeper
    
    // NewAppModule creates a new AppModule object
    public init(keeper: NameServiceKeeper, coinKeeper: BankKeeper) {
        self.keeper = keeper
        self.coinKeeper = coinKeeper
    }
    
    // Name returns the nameservice module's name.
    public var name: String {
        NameServiceKeys.moduleName
    }
    
    public func register(codec: Codec) {
        Codec.register(codec: codec)
    }

    // DefaultGenesis returns default genesis state as raw bytes for the nameservice
    // module.
    public func defaultGenesis() -> RawMessage? {
        Codec.moduleCodec.mustMarshalJSON(value: GenesisState.default)
    }

    // ValidateGenesis performs genesis state validation for the nameservice module.
    public func validateGenesis(rawMessage: RawMessage) throws {
        let genesisState: GenesisState = try Codec.moduleCodec.unmarshalJSON(data: rawMessage)
        try genesisState.validate()
    }
    
    // RegisterInvariants registers the nameservice module invariants.
    public func registerInvariants(in invariantRegistry: InvariantRegistry) {}

    // Route returns the message routing key for the nameservice module.
    public var route: String {
        NameServiceKeys.routerKey
    }
    
    // NewHandler returns an sdk.Handler for the nameservice module.
    public func makeHandler() -> Handler? {
        keeper.makeHandler()
    }
    
    // QuerierRoute returns the nameservice module's querier route name.
    public var querierRoute: String {
        NameServiceKeys.querierRoute
    }
    
    // NewQuerierHandler returns the nameservice module sdk.Querier.
    public func makeQuerier() -> Querier? {
        keeper.makeQuerier()
    }
    
    // InitGenesis performs genesis initialization for the nameservice module. It returns
    // no validator updates.
    public func initGenesis(request: Request, rawMessage: RawMessage) -> [ValidatorUpdate] {
        let genesisState: GenesisState = Codec.moduleCodec.mustUnmarshalJSON(data: rawMessage)
        GenesisState.initGenesis(request: request, keeper: keeper, data: genesisState)
        // TODO: Add default parameters to ValidatorUpdate and make the labels visible.
        return []
    }
    
    // ExportGenesis returns the exported genesis state as raw bytes for the nameservice
    // module.
    public func exportGenesis(request: Request) -> RawMessage {
        let genesisState = GenesisState.exportGenesis(request: request, keeper: keeper)
        return Codec.moduleCodec.mustMarshalJSON(value: genesisState)
    }
    
    // BeginBlock returns the begin blocker for the nameservice module.
    public func beginBlock(request: Request, beginBlockRequest: RequestBeginBlock) {}
    
    // EndBlock returns the end blocker for the nameservice module. It returns no validator
    // updates.
    public func endBlock(request: Request, endBlockRequest: RequestEndBlock) -> [ValidatorUpdate] {
        []
    }
}
