import Foundation
import Logging
import ABCI
import Database
import Cosmos
import NameService


public final class NameServiceApp: BaseApp, App {
    private static let home = ProcessInfo.processInfo.environment["HOME"] ?? ""
    public static let defaultCLIHome = "\(home)/.nameservicecli"
    public static let defaultNodeHome = "\(home)/.nameserviced"
    
    private static let appName = "nameservice"
    public let codec: Codec = makeCodec()
    
    static let moduleBasics = BasicManager(
        GenUtilAppModuleBasic(),
        AuthAppModuleBasic(),
        BankAppModuleBasic(),
        StakingAppModuleBasic(),
        ParamsAppModuleBasic(),
        SupplyAppModuleBasic(),
        NameServiceAppModuleBasic()
    )
    
    static let moduleAccountPermissions: [String: [String]] = [
        AuthKeys.feeCollectorName: [],
        StakingKeys.bondedPoolName:    [SupplyPermissions.burner, SupplyPermissions.staking],
        StakingKeys.notBondedPoolName: [SupplyPermissions.burner, SupplyPermissions.staking],
    ]
   
    let invariantCheckPeriod: UInt
    
    let keys:  [String: KeyValueStoreKey]
    let transientKeys: [String: TransientStoreKey]

    var subspaces: [String: Subspace] = [:]

    let accountKeeper: AccountKeeper
    let bankKeeper: BankKeeper
    let stakingKeeper: StakingKeeper
    let supplyKeeper: SupplyKeeper
    let paramsKeeper: ParamsKeeper
    let nameserviceKeeper: NameServiceKeeper
    let moduleManager: ModuleManager

    public let simulationManager: SimulationManager? = nil
    
    public init(
        logger: Logger,
        database: Database,
        commitMultiStoreTracer:  Writer?,
        loadLatest: Bool,
        invariantCheckPeriod: UInt,
        options: ((BaseApp) -> Void)...
    ) throws {
        self.invariantCheckPeriod = invariantCheckPeriod

        self.keys = KeyValueStoreKeys(
            BaseAppKeys.mainStoreKey,
            AuthKeys.storeKey,
            StakingKeys.storeKey,
            SupplyKeys.storeKey,
            ParamsKeys.storeKey,
            NameServiceKeys.storeKey
        )

        self.transientKeys = TransientStoreKeys(
            StakingKeys.transientStoreKey,
            ParamsKeys.transientStoreKey
        )
        
        self.paramsKeeper = ParamsKeeper(
            codec: self.codec,
            // TODO: Deal with force unwrap.
            key: keys[ParamsKeys.storeKey]!,
            // TODO: Deal with force unwrap.
            transientKey: transientKeys[ParamsKeys.transientStoreKey]!
        )
        
        self.subspaces[AuthKeys.moduleName] = self.paramsKeeper.subspace(AuthKeys.defaultParamspace)
        self.subspaces[BankKeys.moduleName] = self.paramsKeeper.subspace(BankKeys.defaultParamspace)
        self.subspaces[StakingKeys.moduleName] = self.paramsKeeper.subspace(StakingKeys.defaultParamspace)
        
        self.accountKeeper = AccountKeeper(
            codec: self.codec,
            key: self.keys[AuthKeys.storeKey]!,
            paramstore: self.subspaces[AuthKeys.moduleName]!,
            proto: protoBaseAccount
        )

        self.bankKeeper = BaseKeeper(
            accountKeeper: self.accountKeeper,
            paramSpace: self.subspaces[BankKeys.moduleName]!,
            blacklistedAddresses: Self.moduleAccountAddresses
        )

        self.supplyKeeper = SupplyKeeper(
            codec: self.codec,
            storeKey: keys[SupplyKeys.storeKey]!,
            accountKeeper: self.accountKeeper,
            bankKeeper: self.bankKeeper,
            moduleAccountPermissions: Self.moduleAccountPermissions
        )

        self.stakingKeeper = StakingKeeper(
            codec: self.codec,
            key: keys[StakingKeys.storeKey]!,
            supplyKeeper: self.supplyKeeper,
            paramstore: self.subspaces[StakingKeys.moduleName]!
        )

        self.stakingKeeper.setHooks(
            MultiStakingHooks()
        )

        self.nameserviceKeeper = NameServiceKeeper(
            coinKeeper: self.bankKeeper,
            codec: self.codec,
            storeKey: keys[NameServiceKeys.storeKey]!
        )
        
        self.moduleManager = ModuleManager(
            GenUtilAppModule(
                accountKeeper: self.accountKeeper,
                stakingKeeper: self.stakingKeeper
                // TODO: Deal with this, can't use self.deliverTx because self is not fully initialized yet.
//                deliverTx: self.deliverTx
            ),
            AuthAppModule(accountKeeper: self.accountKeeper),
            BankAppModule(keeper: self.bankKeeper, accountKeeper: self.accountKeeper),
            SupplyAppModule(keeper: self.supplyKeeper, accountKeeper: self.accountKeeper),
            NameServiceAppModule(keeper: self.nameserviceKeeper, coinKeeper: self.bankKeeper),
            StakingAppModule(
                keeper: self.stakingKeeper,
                accountKeeper: self.accountKeeper,
                supplyKeeper: self.supplyKeeper
            )
        )

        super.init(
            name: Self.appName,
            logger: logger,
            database: database,
            transactionDecoder: Auth.defaultTransactionDecoder(codec: codec),
            options: options
        )
      
        self.setCommitMultiStoreTracer(tracer: commitMultiStoreTracer)
        self.setAppVersion(version: VersionInfo.defaultVersion)

        self.moduleManager.setOrderEndBlockers(
            StakingKeys.moduleName
        )

        self.moduleManager.setOrderInitGenesis(
//            StakingKeys.moduleName,
            AuthKeys.moduleName,
            BankKeys.moduleName,
            NameServiceKeys.moduleName,
//            SupplyKeys.moduleName,
                GenUtilKeys.moduleName
        )

        self.moduleManager.registerRoutes(
            router: self.router,
            queryRouter: self.queryRouter
        )

        self.setInitChainer(self.initChainer)
        self.setBeginBlocker(self.beginBlocker)
        self.setEndBlocker(self.endBlocker)

        if let anteHandler = Auth.anteHandler(
            accountKeeper: self.accountKeeper,
            supplyKeeper: self.supplyKeeper,
            signatureVerificationGasConsumer: Auth.defaultSignatureVerificationGasConsumer
        ) {
            self.setAnteHandler(anteHandler)
        }

        self.mountKeyValueStores(keys: self.keys)
        self.mountTransientStores(keys: self.transientKeys)

        if loadLatest {
            try self.loadLatestVersion(baseKey: self.keys[BaseAppKeys.mainStoreKey]!)
        }
    }
}

typealias GenesisState = [String: RawMessage]

extension NameServiceApp {
    static func newDefaultGenesisState() -> GenesisState {
        moduleBasics.defaultGenesis()
    }
    
    public func initChainer(request: Request, initChainRequest: RequestInitChain) -> ResponseInitChain {
        let genesisState: GenesisState = codec.mustUnmarshalJSON(data: initChainRequest.appStateBytes)
        return moduleManager.initGenesis(request: request, genesisState: genesisState)
    }

    public func beginBlocker(request: Request, beginBlockRequest: RequestBeginBlock) -> ResponseBeginBlock {
         moduleManager.beginBlock(request: request, beginBlockRequest: beginBlockRequest)
    }
    
    public func endBlocker(request: Request, endBlockRequest: RequestEndBlock) -> ResponseEndBlock {
        moduleManager.endBlock(request: request, endBlockRequest: endBlockRequest)
    }
    
    public func load(height: Int64) throws {
        let baseKey = BaseAppKeys.mainStoreKey
        // TODO: Check what's the best way to deal with optionality here.
        try load(version: height, baseKey: keys[baseKey]!)
    }
    
    public static var moduleAccountAddresses: [String: Bool] {
        var moduleAccountAddresses: [String: Bool] = [:]
        
        for (permission, _) in moduleAccountPermissions {
            moduleAccountAddresses[ModuleAccount.moduleAddress(name: permission).description] = true
        }
        
        return moduleAccountAddresses
    }
}

extension NameServiceApp {
    public static func makeCodec() -> Codec {
        let codec = Codec()

        // TODO: Decide what to do about codecs
    //    ModuleBasics.registerCodec(codec)
    //    registerCodec(codec)
    //    codec.registerCrypto(codec)

    //    return codec.seal()
        return codec
    }
}

