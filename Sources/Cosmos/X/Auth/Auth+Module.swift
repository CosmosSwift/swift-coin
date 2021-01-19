import JSON
import ABCI

// AppModuleBasic defines the basic application module used by the auth module.
public class AuthAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public let name: String = AuthKeys.moduleName
    
    public func register(codec: Codec) {
        // TODO: Implement
        fatalError()
    }
    
    /// DefaultGenesis returns default genesis state as raw bytes for the auth
    /// module.
    public func defaultGenesis() -> JSON? {
        let data = Codec.authCodec.mustMarshalJSON(value: AuthGenesisState.default)
        return Codec.authCodec.mustUnmarshalJSON(data: data)
    }
    
    /// ValidateGenesis performs genesis state validation for the auth module.
    public func validateGenesis(json: JSON) throws {
        // TODO: Implement
        fatalError()
//        func (AppModuleBasic) ValidateGenesis(cdc codec.JSONMarshaler, config client.TxEncodingConfig, bz json.RawMessage) error {
//            var data types.GenesisState
//            if err := cdc.UnmarshalJSON(bz, &data); err != nil {
//                return fmt.Errorf("failed to unmarshal %s genesis state: %w", types.ModuleName, err)
//            }
//
//            return types.ValidateGenesis(data)
//        }
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

    // MARK: ABCI
    /// BeginBlock returns the begin blocker for the auth module.
    public func beginBlock(request: Request, beginBlockRequest: RequestBeginBlock) {}
    
    /// EndBlock returns the end blocker for the auth module. It returns no validator
    /// updates.
    public func endBlock(request: Request, endBlockRequest: RequestEndBlock) -> [ValidatorUpdate] {
        []
    }
   
    // MARK: Genesis
    /// InitGenesis performs genesis initialization for the auth module. It returns
    /// no validator updates.
    public func initGenesis(request: Request, json: JSON) -> [ValidatorUpdate] {
        []
    }
    
    /// ExportGenesis returns the exported genesis state as raw bytes for the auth
    /// module.
    public func exportGenesis(request: Request) -> JSON {
        fatalError()

//        func (am AppModule) ExportGenesis(ctx sdk.Context, cdc codec.JSONMarshaler) json.RawMessage {
//            gs := ExportGenesis(ctx, am.accountKeeper)
//            return cdc.MustMarshalJSON(gs)
//        }
    }
}

