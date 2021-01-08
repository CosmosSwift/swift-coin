import ArgumentParser
import Logging
import Tendermint
import ABCI
import Database
import Cosmos
import App

struct RootCommand: ParsableCommand {
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
) throws -> (RawMessage, [GenesisValidator]) {
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

NameServiceApp.configure()
ServerContext.defaultHome = NameServiceApp.defaultNodeHome

InitCommand.codec = codec
InitCommand.moduleBasicManager = NameServiceApp.moduleBasics
InitCommand.defaultHome = NameServiceApp.defaultNodeHome


ServerContext.makeApp = makeApp
ServerContext.exportApp = exportApp

let executor = Executor(command: RootCommand.self)
executor.execute()

