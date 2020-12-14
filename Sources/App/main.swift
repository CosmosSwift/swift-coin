import Logging
import ABCI
import Cosmos
import Database
import NameService

let appName = "nameservice"

//let defaultCLIHome = os.ExpandEnv("$HOME/.nameservicecli")
//let defaultNodeHome = os.ExpandEnv("$HOME/.nameserviced")

let moduleBasics = BasicManager.make(with:
//    genutil.AppModuleBasic{},
//    auth.AppModuleBasic{},
//    bank.AppModuleBasic{},
//    staking.AppModuleBasic{},
//    params.AppModuleBasic{},
//    supply.AppModuleBasic{},
    NameService.AppModuleBasic()
//// this line is used by starport scaffolding # 2
)

let moduleAccountPermissions: [String: [String]] = [:
//    Auth.FeeCollectorName: [],
    // this line is used by starport scaffolding # 2.1
//    Staking.BondedPoolName:    [supply.Burner, supply.Staking],
//    Staking.NotBondedPoolName: [supply.Burner, supply.Staking],
]

func makeCodec() -> Codec {
    let codec = Codec()
//
//    ModuleBasics.RegisterCodec(cdc)
//    sdk.RegisterCodec(cdc)
//    codec.RegisterCrypto(cdc)
//
//    return cdc.Seal()
    return codec
}

final class NewApp: BaseApp {
    let codec: Codec
   
    let invCheckPeriod: UInt
    
    let keys:  [String: KeyValueStoreKey]
//    tKeys map[string]*sdk.TransientStoreKey
//
//    subspaces map[string]params.Subspace
//
//    accountKeeper  auth.AccountKeeper
//    bankKeeper     bank.Keeper
//    stakingKeeper  staking.Keeper
//    supplyKeeper   supply.Keeper
//    paramsKeeper   params.Keeper
//    nameserviceKeeper nameservicekeeper.Keeper
//  // this line is used by starport scaffolding # 3
    let moduleManager: Manager
//
//    sm *module.SimulationManager
    init(
        logger: Logger,
        database: Database,
//        traceStore: Writer,
        loadLatest: Bool,
        invCheckPeriod: UInt
//        baseAppOptions ...func(*bam.BaseApp)
    ) {
        _ = makeCodec()
    
//        let baseApp = super.init(
//            name: appName,
//            logger: logger,
//            database: database,
//            transactionDecoder: auth.DefaultTxDecoder(cdc),
//            baseAppOptions...
//        )
//
//        baseApp.setCommitMultiStoreTracer(traceStore)
//        baseApp.appVersion = version.Version
//
//        let keys = KeyValueStoreKeys(
//            bam.MainStoreKey,
//            auth.StoreKey,
//            staking.StoreKey,
//            supply.StoreKey,
//            params.StoreKey,
//            NameService.Key.StoreKey
        // this line is used by starport scaffolding # 5
//      )

//        tKeys := sdk.NewTransientStoreKeys(staking.TStoreKey, params.TStoreKey)
//
//        var app = &NewApp{
//            BaseApp:        bApp,
//            cdc:            cdc,
//            invCheckPeriod: invCheckPeriod,
//            keys:           keys,
//            tKeys:          tKeys,
//            subspaces:      make(map[string]params.Subspace),
//        }
//
//        app.paramsKeeper = params.NewKeeper(app.cdc, keys[params.StoreKey], tKeys[params.TStoreKey])
//        app.subspaces[auth.ModuleName] = app.paramsKeeper.Subspace(auth.DefaultParamspace)
//        app.subspaces[bank.ModuleName] = app.paramsKeeper.Subspace(bank.DefaultParamspace)
//        app.subspaces[staking.ModuleName] = app.paramsKeeper.Subspace(staking.DefaultParamspace)
//        // this line is used by starport scaffolding # 5.1
//
//        app.accountKeeper = auth.NewAccountKeeper(
//            app.cdc,
//            keys[auth.StoreKey],
//            app.subspaces[auth.ModuleName],
//            auth.ProtoBaseAccount,
//        )
//
//        app.bankKeeper = bank.NewBaseKeeper(
//            app.accountKeeper,
//            app.subspaces[bank.ModuleName],
//            app.ModuleAccountAddrs(),
//        )
//
//        app.supplyKeeper = supply.NewKeeper(
//            app.cdc,
//            keys[supply.StoreKey],
//            app.accountKeeper,
//            app.bankKeeper,
//            maccPerms,
//        )
//
//        stakingKeeper := staking.NewKeeper(
//            app.cdc,
//            keys[staking.StoreKey],
//            app.supplyKeeper,
//            app.subspaces[staking.ModuleName],
//        )
//
//        // this line is used by starport scaffolding # 5.2
//
//        app.stakingKeeper = *stakingKeeper.SetHooks(
//            staking.NewMultiStakingHooks(
//                // this line is used by starport scaffolding # 5.3
//            ),
//        )
//
//        app.nameserviceKeeper = nameservicekeeper.NewKeeper(
//            app.bankKeeper,
//            app.cdc,
//            keys[nameservicetypes.StoreKey],
//        )
//
//      // this line is used by starport scaffolding # 4
//
//        app.mm = module.NewManager(
//            genutil.NewAppModule(app.accountKeeper, app.stakingKeeper, app.BaseApp.DeliverTx),
//            auth.NewAppModule(app.accountKeeper),
//            bank.NewAppModule(app.bankKeeper, app.accountKeeper),
//            supply.NewAppModule(app.supplyKeeper, app.accountKeeper),
//            nameservice.NewAppModule(app.nameserviceKeeper, app.bankKeeper),
//            staking.NewAppModule(app.stakingKeeper, app.accountKeeper, app.supplyKeeper),
//        // this line is used by starport scaffolding # 6
//        )
//
//        app.mm.SetOrderEndBlockers(
//            staking.ModuleName,
//            // this line is used by starport scaffolding # 6.1
//        )
//
//        app.mm.SetOrderInitGenesis(
//            // this line is used by starport scaffolding # 6.2
//            staking.ModuleName,
//            auth.ModuleName,
//            bank.ModuleName,
//            nameservicetypes.ModuleName,
//            supply.ModuleName,
//            genutil.ModuleName,
//        // this line is used by starport scaffolding # 7
//        )
//
//        app.mm.RegisterRoutes(app.Router(), app.QueryRouter())
//
//        app.SetInitChainer(app.InitChainer)
//        app.SetBeginBlocker(app.BeginBlocker)
//        app.SetEndBlocker(app.EndBlocker)
//
//        app.SetAnteHandler(
//            auth.NewAnteHandler(
//                app.accountKeeper,
//                app.supplyKeeper,
//                auth.DefaultSigVerificationGasConsumer,
//            ),
//        )
//
//        app.MountKVStores(keys)
//        app.MountTransientStores(tKeys)
//
//        if loadLatest {
//            err := app.LoadLatestVersion(app.keys[bam.MainStoreKey])
//            if err != nil {
//                tmos.Exit(err.Error())
//            }
//        }
//
//        return app
        fatalError()
    }
}
//
//var _ simapp.App = (*NewApp)(nil)

typealias GenesisState = [String: RawMessage]

func newDefaultGenesisState() -> GenesisState {
    return moduleBasics.defaultGenesis()
}

extension NewApp {
    func initChainer(request: Request, initChainRequest: RequestInitChain) -> ResponseInitChain {
        let genesisState: GenesisState = codec.mustUnmarshalJSON(data: initChainRequest.appStateBytes)
        return moduleManager.initGenesis(request: request, genesisState: genesisState)
    }

    func geginBlocker(request: Request, beginBlockRequest: RequestBeginBlock) -> ResponseBeginBlock {
         moduleManager.beginBlock(request: request, beginBlockRequest: beginBlockRequest)
    }
    
    func endBlocker(request: Request, endBlockRequest: RequestEndBlock) -> ResponseEndBlock {
        moduleManager.endBlock(request: request, endBlockRequest: endBlockRequest)
    }
    
    func load(height: Int64) throws {
        load(version: height, baseKey: keys[Cosmos.Keys.mainStoreKey])
    }
    
    func moduleAccountAddresses() -> [String: Bool] {
        let moduleAccountAddresses: [String: Bool] = [:]
        
        for permission in moduleAccountPermissions {
            moduleAccountAddresses[supply.NewModuleAddress(permission).string()] = true
        }
        
        return moduleAccountAddresses
    }
   
    // TODO: Check if this is required. Looks like these accessors are not quite required in Swiftland.
//    func codec() -> Codec {
//        codec
//    }
//
//    func simulationManager() -> SimulationManager {
//        simulationManager
//    }
}
