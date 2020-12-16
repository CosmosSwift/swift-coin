import Foundation
import Logging
import ABCI
import Cosmos
import Database
import NameService

let home = ProcessInfo.processInfo.environment["HOME"] ?? ""
let defaultCLIHome = "\(home)/.nameservicecli"
let defaultNodeHome = "\(home)/.nameserviced"

func makeCodec() -> Codec {
    let codec = Codec()

//    ModuleBasics.registerCodec(codec)
//    registerCodec(codec)
//    codec.registerCrypto(codec)

//    return codec.seal()
    return codec
}

final class NewApp: BaseApp {
    static let appName = "nameservice"
    let codec: Codec = makeCodec()
    
    static let moduleBasics = BasicManager.make(with:
    //    genutil.AppModuleBasic{},
    //    auth.AppModuleBasic{},
    //    bank.AppModuleBasic{},
    //    staking.AppModuleBasic{},
    //    params.AppModuleBasic{},
    //    supply.AppModuleBasic{},
        NameServiceAppModuleBasic()
    //// this line is used by starport scaffolding # 2
    )
    
    static let moduleAccountPermissions: [String: [String]] = [:
    //    Auth.FeeCollectorName: [],
        // this line is used by starport scaffolding # 2.1
    //    Staking.BondedPoolName:    [supply.Burner, supply.Staking],
    //    Staking.NotBondedPoolName: [supply.Burner, supply.Staking],
    ]
   
    let invCheckPeriod: UInt
    
    let keys:  [String: KeyValueStoreKey]
    let transientKeys: [String: TransientStoreKey]

    let subspaces: [String: Subspace]
//
    let accountKeeper: AccountKeeper
    let bankKeeper: BankKeeper
//    stakingKeeper  staking.Keeper
//    supplyKeeper   supply.Keeper
//    paramsKeeper   params.Keeper
    let nameserviceKeeper: NameServiceKeeper
//  // this line is used by starport scaffolding # 3
    let moduleManager: Manager

    let simulationManager: SimulationManager? = nil
    
    init(
        logger: Logger,
        database: Database,
        commitMultiStoreTracer: TextOutputStream,
        loadLatest: Bool,
        invCheckPeriod: UInt,
        options: ((BaseApp) -> Void)...
    ) {
        self.invCheckPeriod = invCheckPeriod

        self.keys = KeyValueStoreKeys(
            BaseAppKeys.mainStoreKey,
            AuthKeys.storeKey,
            StakingKeys.storeKey,
            SupplyKeys.storeKey,
            ParamsKeys.storeKey,
            NameServiceKeys.storeKey
        // this line is used by starport scaffolding # 5
        )

        self.transientKeys = TransientStoreKeys(
            StakingKeys.transientStoreKey,
            ParamsKeys.transientStoreKey
        )
        
        self.subspaces = [:]
//        app.paramsKeeper = params.NewKeeper(app.cdc, keys[params.StoreKey], tKeys[params.TStoreKey])
//        app.subspaces[auth.ModuleName] = app.paramsKeeper.Subspace(auth.DefaultParamspace)
//        app.subspaces[bank.ModuleName] = app.paramsKeeper.Subspace(bank.DefaultParamspace)
//        app.subspaces[staking.ModuleName] = app.paramsKeeper.Subspace(staking.DefaultParamspace)
        
        self.accountKeeper = AccountKeeper(
            codec: self.codec,
            // TODO: Deal with force unwrap.
            key: self.keys[AuthKeys.storeKey]!,
            // TODO: Deal with force unwrap.
            paramstore: self.subspaces[AuthKeys.moduleName]!,
            proto: protoBaseAccount
        )

        self.bankKeeper = BaseKeeper(
            accountKeeper: self.accountKeeper,
            // TODO: Deal with force unwrap.
            paramSpace: self.subspaces[BankKeys.moduleName]!,
            blacklistedAddresses: Self.moduleAccountAddresses()
        )

        self.nameserviceKeeper = NameServiceKeeper(
            coinKeeper: self.bankKeeper,
            codec: self.codec,
            // TODO: Deal with force unwrap.
            storeKey: keys[NameServiceKeys.storeKey]!
        )

        // this line is used by starport scaffolding # 4

        self.moduleManager = Manager(
//            genutil.NewAppModule(app.accountKeeper, app.stakingKeeper, app.BaseApp.DeliverTx),
//            auth.NewAppModule(app.accountKeeper),
//            bank.NewAppModule(app.bankKeeper, app.accountKeeper),
//            supply.NewAppModule(app.supplyKeeper, app.accountKeeper),
            NameServiceAppModule(keeper: nameserviceKeeper, coinKeeper: self.bankKeeper)
//            staking.NewAppModule(app.stakingKeeper, app.accountKeeper, app.supplyKeeper),
          // this line is used by starport scaffolding # 6
        )

        super.init(
            name: Self.appName,
            logger: logger,
            database: database,
            transactionDecoder: Auth.defaultTransactionDecoder(codec: codec),
            options: options
        )
      
        self.setCommitMultiStoreTracer(tracer: commitMultiStoreTracer)

        moduleManager.setOrderEndBlockers(
//            StakingKeys.moduleName
            // this line is used by starport scaffolding # 6.1
        )

        moduleManager.setOrderInitGenesis(
            // this line is used by starport scaffolding # 6.2
            StakingKeys.moduleName,
            AuthKeys.moduleName,
            BankKeys.moduleName,
            NameServiceKeys.moduleName,
            SupplyKeys.moduleName,
            GenUtilKeys.moduleName
        // this line is used by starport scaffolding # 7
        )

//        moduleManager.registerRoutes(self.router(), self.queryRouter())
        self.setInitChainer(self.initChainer)
        self.setBeginBlocker(self.beginBlocker)
        self.setEndBlocker(self.endBlocker)

//        self.SetAnteHandler(
//            auth.NewAnteHandler(
//                app.accountKeeper,
//                app.supplyKeeper,
//                auth.DefaultSigVerificationGasConsumer,
//            ),
//        )

//        self.mountKVStores(keys)
//        self.mountTransientStores(tKeys)

//        if loadLatest {
//            do {
//                try self.loadLatestVersion(self.keys[BaseAppKeys.mainStoreKey]!)
//            } catch {
//                // TODO: Probably don't need to fatalError here
//                // Maybe just throwing and let the error flow through
//                // the call stack might be enough
//               fatalError("\(error)")
//            }
//        }
        

        fatalError()
    
//        baseApp.appVersion = version.Version
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
    }
}
//
//var _ simapp.App = (*NewApp)(nil)

typealias GenesisState = [String: RawMessage]

extension NewApp {
    static func newDefaultGenesisState() -> GenesisState {
        return moduleBasics.defaultGenesis()
    }
    
    func initChainer(request: Request, initChainRequest: RequestInitChain) -> ResponseInitChain {
        let genesisState: GenesisState = codec.mustUnmarshalJSON(data: initChainRequest.appStateBytes)
        return moduleManager.initGenesis(request: request, genesisState: genesisState)
    }

    func beginBlocker(request: Request, beginBlockRequest: RequestBeginBlock) -> ResponseBeginBlock {
         moduleManager.beginBlock(request: request, beginBlockRequest: beginBlockRequest)
    }
    
    func endBlocker(request: Request, endBlockRequest: RequestEndBlock) -> ResponseEndBlock {
        moduleManager.endBlock(request: request, endBlockRequest: endBlockRequest)
    }
    
    func load(height: Int64) throws {
        let baseKey = BaseAppKeys.mainStoreKey
        // TODO: Check what's the best way to deal with optionality here.
        try load(version: height, baseKey: keys[baseKey]!)
    }
    
    static func moduleAccountAddresses() -> [String: Bool] {
        var moduleAccountAddresses: [String: Bool] = [:]
        
        for (permission, _) in moduleAccountPermissions {
            moduleAccountAddresses[Supply.moduleAddress(name: permission).string()] = true
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
