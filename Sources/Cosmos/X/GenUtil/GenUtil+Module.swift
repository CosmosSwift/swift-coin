import JSON
import ABCI

// AppModuleBasic defines the basic application module used by the genutil module.
public class GenUtilAppModuleBasic: AppModuleBasic {
    public init() {}
    
    public let name: String = GenUtilKeys.moduleName
    
    public func register(codec: Codec) {}
    
    public func defaultGenesis() -> JSON? {
        let data = Codec.genUtilCodec.mustMarshalJSON(value: GenUtilGenesisState.default)
        return Codec.genUtilCodec.mustUnmarshalJSON(data: data)
    }
    
    public func validateGenesis(json: JSON) throws {
        // TODO: Implement
        fatalError()
    }
}

//____________________________________________________________________________

// AppModule implements an application module for the genutil module.
public final class GenUtilAppModule: GenUtilAppModuleBasic, AppModule {
    let accountKeeper: AccountKeeper
    let stakingKeeper: StakingKeeper
//    let deliverTx: DeliverTxFunction
    
    public init(
        accountKeeper: AccountKeeper,
        stakingKeeper: StakingKeeper
//        deliverTx: @escaping DeliverTxFunction
    ) {
        self.accountKeeper = accountKeeper
        self.stakingKeeper = stakingKeeper
//        self.deliverTx = deliverTx
        super.init()
    }

    // InitGenesis performs genesis initialization for the genutil module. It returns
    // no validator updates.
    public func initGenesis(request: Request, json: JSON) -> [ValidatorUpdate] {
        // TODO: Implement
        fatalError()
//        var genesisState GenesisState
//        ModuleCdc.MustUnmarshalJSON(data, &genesisState)
//        return InitGenesis(ctx, ModuleCdc, am.stakingKeeper, am.deliverTx, genesisState)
    }

    // ExportGenesis returns the exported genesis state as raw bytes for the genutil
    // module.
    public func exportGenesis(request: Request) -> JSON {
        // TODO: Implement
        fatalError()
//        return am.DefaultGenesis()
    }
}

