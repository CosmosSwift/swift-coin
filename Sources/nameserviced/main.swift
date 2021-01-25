import JSON
import ArgumentParser
import Logging
import Tendermint
import ABCI
import Database
import Cosmos
import App
import NameService

struct Nameserviced: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "app Daemon (server)",
        subcommands: [
            InitCommand.self,
            CollectGenesisTransactionsCommand.self,
            MigrateGenesisCommand.self,
            GenerateGenesisTransactionCommand.self,
            ValidateGenesisCommand.self,
            AddGenesisAccountCommand.self,
            DebugCommand.self,
        ] + ServerContext.commands,
        defaultSubcommand: StartCommand.self
    )
}

func makeApp(
    logger: Logger,
    database: Database,
    traceStore:  Writer?,
    globalOptions: GlobalOptions
) throws -> ABCIApplication {
    try NameServiceApp(
        logger: logger,
        database: database,
        commitMultiStoreTracer: traceStore,
        loadLatest: true,
        invariantCheckPeriod: globalOptions.invariantCheckPeriod
//        BaseApp.setPruning(pruningOpts),
//        BaseApp.setMinGasPrices(viper.GetString(server.FlagMinGasPrices)),
//        BaseApp.setHaltHeight(viper.GetUint64(server.FlagHaltHeight)),
//        BaseApp.setHaltTime(viper.GetUint64(server.FlagHaltTime)),
//        BaseApp.setInterBlockCache(cache)
    )
}

func exportApp(
    logger: Logger,
    database: Database,
    traceStore: Writer?,
    height: Int64,
    forZeroHeight: Bool,
    jailWhiteList: [String]
) throws -> (JSON, [GenesisValidator]) {
    let app = try NameServiceApp(
        logger: logger,
        database: database,
        commitMultiStoreTracer: traceStore,
        loadLatest: true,
        invariantCheckPeriod: 1
    )
    
    if height != -1 {
        try app.load(height: height)
    }
    
    return try app.exportAppStateAndValidators(
        forZeroHeight: forZeroHeight,
        jailWhiteList: jailWhiteList
    )
}

let codec = NameServiceApp.makeCodec()

AppStateMetatype.register(NameService.GenesisState.self) // Nameservice
AppStateMetatype.register(Cosmos.AuthGenesisState.self) // Auth
AppStateMetatype.register(Cosmos.StakingGenesisState.self) // Staking
AppStateMetatype.register(Cosmos.SupplyGenesisState.self) // Supply
AppStateMetatype.register(Cosmos.GenUtilGenesisState.self) // GenUtil
AppStateMetatype.register(Cosmos.BankGenesisState.self) // Bank

NameServiceApp.configure()
ServerContext.defaultHome = NameServiceApp.defaultNodeHome

InitCommand.codec = codec
InitCommand.moduleBasicManager = NameServiceApp.moduleBasics
InitCommand.defaultHome = NameServiceApp.defaultNodeHome

AddGenesisAccountCommand.defaultHome = NameServiceApp.defaultNodeHome
AddGenesisAccountCommand.codec = codec
AddGenesisAccountCommand.defaultClientHome = NameServiceApp.defaultCLIHome

ServerContext.makeApp = makeApp
ServerContext.exportApp = exportApp

let executor = Executor(command: Nameserviced.self)
executor.execute()

