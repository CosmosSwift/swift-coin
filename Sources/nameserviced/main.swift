import ArgumentParser
import Logging
import ABCI
import Database
import App

enum GenUtilCLI {
    struct InitCommand: ParsableCommand {}
    struct CollectGenTxCommand: ParsableCommand {}
    struct MigrateGenesisCommand: ParsableCommand {}
    struct GenTxCommand: ParsableCommand {}
    struct ValidateGenesisCommand: ParsableCommand {}
}

struct DebugCommand: ParsableCommand {}

struct RootCommand: ParsableCommand {
//                PersistentPreRunE: server.PersistentPreRunEFn(ctx),
    
    static var configuration = CommandConfiguration(
        abstract: "app Daemon (server)",
        subcommands: [
            GenUtilCLI.InitCommand.self,
            GenUtilCLI.CollectGenTxCommand.self,
            GenUtilCLI.MigrateGenesisCommand.self,
            GenUtilCLI.GenTxCommand.self,
            GenUtilCLI.ValidateGenesisCommand.self,
            AddGenesisAccountCommand.self,
            DebugCommand.self,
        ],
        defaultSubcommand: nil
    )
    
    //            rootCmd.AddCommand(genutilcli.InitCmd(ctx, cdc, app.ModuleBasics, app.DefaultNodeHome))
    //            rootCmd.AddCommand(genutilcli.CollectGenTxsCmd(ctx, cdc, auth.GenesisAccountIterator{}, app.DefaultNodeHome))
    //            rootCmd.AddCommand(genutilcli.MigrateGenesisCmd(ctx, cdc))
    //            rootCmd.AddCommand(
    //                genutilcli.GenTxCmd(
    //                    ctx, cdc, app.ModuleBasics, staking.AppModuleBasic{},
    //                    auth.GenesisAccountIterator{}, app.DefaultNodeHome, app.DefaultCLIHome,
    //                ),
    //            )
    //            rootCmd.AddCommand(genutilcli.ValidateGenesisCmd(ctx, cdc, app.ModuleBasics))
    //            rootCmd.AddCommand(AddGenesisAccountCmd(ctx, cdc, app.DefaultNodeHome, app.DefaultCLIHome))
    //            rootCmd.AddCommand(flags.NewCompletionCmd(rootCmd, true))
    //            rootCmd.AddCommand(debug.Cmd(cdc))
    
    @Option(
        name: .customLong("inv-check-period"),
        help: "Assert registered invariants every N blocks"
    )
    var invariantCheckPeriod: UInt = 0

    mutating func run() throws {
//        let codec = App.makeCodec()
//        App.setConfig()
//        let context = ServerContext.default
//
//            server.AddCommands(ctx, cdc, rootCmd, newApp, exportAppStateAndTMValidators)
    }
    
    func newApp(
        logger: Logger,
        database: Database,
        traceStore: TextOutputStream
    ) throws -> ABCIApplication {
    //    var cache: MultiStorePersistentCache
    //
    //    if viper.getBool(server.FlagInterBlockCache) {
    //        cache = store.NewCommitKVStoreCacheManager()
    //    }
    //
    //    let pruningOpts = try server.getPruningOptionsFromFlags()

        return try NameServiceApp(
            logger: logger,
            database: database,
            commitMultiStoreTracer: traceStore,
            loadLatest: true,
            invariantCheckPeriod: invariantCheckPeriod
    //        BaseApp.setPruning(pruningOpts),
    //        BaseApp.setMinGasPrices(viper.GetString(server.FlagMinGasPrices)),
    //        BaseApp.setHaltHeight(viper.GetUint64(server.FlagHaltHeight)),
    //        BaseApp.setHaltTime(viper.GetUint64(server.FlagHaltTime)),
    //        BaseApp.setInterBlockCache(cache)
        )
    }
}

// prepare and add flags
//let executor = Cli.prepareBaseCmd(RootCommand.self, "AU", App.defaultNodeHome)
//try executor.execute()
RootCommand.main()

