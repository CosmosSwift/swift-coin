import JSON
import ArgumentParser
import Logging
import Tendermint
import ABCI
import Database
import Cosmos
import App

struct Nameservicecli: ParsableCommand {
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

NameServiceApp.configure()
ServerContext.defaultHome = NameServiceApp.defaultNodeHome

InitCommand.codec = codec
InitCommand.moduleBasicManager = NameServiceApp.moduleBasics
InitCommand.defaultHome = NameServiceApp.defaultNodeHome


ServerContext.makeApp = makeApp
ServerContext.exportApp = exportApp

let executor = Executor(command: Nameservicecli.self)
executor.execute()


//
/*
package main

import (
    "fmt"
    "os"
    "path"

    "github.com/cosmos/cosmos-sdk/client"
    "github.com/cosmos/cosmos-sdk/client/flags"
    "github.com/cosmos/cosmos-sdk/client/keys"
    "github.com/cosmos/cosmos-sdk/client/lcd"
    "github.com/cosmos/cosmos-sdk/client/rpc"
    "github.com/cosmos/cosmos-sdk/version"
    "github.com/cosmos/cosmos-sdk/x/auth"
    authcmd "github.com/cosmos/cosmos-sdk/x/auth/client/cli"
    authrest "github.com/cosmos/cosmos-sdk/x/auth/client/rest"
    "github.com/cosmos/cosmos-sdk/x/bank"
    bankcmd "github.com/cosmos/cosmos-sdk/x/bank/client/cli"

    "github.com/spf13/cobra"
    "github.com/spf13/viper"

    "github.com/tendermint/go-amino"
    "github.com/tendermint/tendermint/libs/cli"

    "github.com/cosmos/sdk-tutorials/nameservice/nameservice/app"
    // this line is used by starport scaffolding
)

func main() {
    // Configure cobra to sort commands
    cobra.EnableCommandSorting = false

    // Instantiate the codec for the command line application
    cdc := app.MakeCodec()

    app.SetConfig()

    // TODO: setup keybase, viper object, etc. to be passed into
    // the below functions and eliminate global vars, like we do
    // with the cdc

    rootCmd := &cobra.Command{
        Use:   "nameservicecli",
        Short: "Command line interface for interacting with nameserviced",
    }

    // Add --chain-id to persistent flags and mark it required
    rootCmd.PersistentFlags().String(flags.FlagChainID, "", "Chain ID of tendermint node")
    rootCmd.PersistentPreRunE = func(_ *cobra.Command, _ []string) error {
        return initConfig(rootCmd)
    }

    // Construct Root Command
    rootCmd.AddCommand(
        rpc.StatusCommand(),
        client.ConfigCmd(app.DefaultCLIHome),
        queryCmd(cdc),
        txCmd(cdc),
        flags.LineBreak,
        lcd.ServeCommand(cdc, registerRoutes),
        flags.LineBreak,
        keys.Commands(),
        flags.LineBreak,
        version.Cmd,
        flags.NewCompletionCmd(rootCmd, true),
    )

    // Add flags and prefix all env exposed with AA
    executor := cli.PrepareMainCmd(rootCmd, "AA", app.DefaultCLIHome)

    err := executor.Execute()
    if err != nil {
        fmt.Printf("Failed executing CLI command: %s, exiting...\n", err)
        os.Exit(1)
    }
}

func queryCmd(cdc *amino.Codec) *cobra.Command {
    queryCmd := &cobra.Command{
        Use:     "query",
        Aliases: []string{"q"},
        Short:   "Querying subcommands",
    }

    queryCmd.AddCommand(
        authcmd.GetAccountCmd(cdc),
        flags.LineBreak,
        rpc.ValidatorCommand(cdc),
        rpc.BlockCommand(),
        authcmd.QueryTxsByEventsCmd(cdc),
        authcmd.QueryTxCmd(cdc),
        flags.LineBreak,
    )

    // add modules' query commands
    app.ModuleBasics.AddQueryCommands(queryCmd, cdc)

    return queryCmd
}

func txCmd(cdc *amino.Codec) *cobra.Command {
    txCmd := &cobra.Command{
        Use:   "tx",
        Short: "Transactions subcommands",
    }

    txCmd.AddCommand(
        bankcmd.SendTxCmd(cdc),
        flags.LineBreak,
        authcmd.GetSignCommand(cdc),
        authcmd.GetMultiSignCommand(cdc),
        flags.LineBreak,
        authcmd.GetBroadcastCommand(cdc),
        authcmd.GetEncodeCommand(cdc),
        authcmd.GetDecodeCommand(cdc),
        flags.LineBreak,
    )

    // add modules' tx commands
    app.ModuleBasics.AddTxCommands(txCmd, cdc)

    // remove auth and bank commands as they're mounted under the root tx command
    var cmdsToRemove []*cobra.Command

    for _, cmd := range txCmd.Commands() {
        if cmd.Use == auth.ModuleName || cmd.Use == bank.ModuleName {
            cmdsToRemove = append(cmdsToRemove, cmd)
        }
    }

    txCmd.RemoveCommand(cmdsToRemove...)

    return txCmd
}

// registerRoutes registers the routes from the different modules for the LCD.
// NOTE: details on the routes added for each module are in the module documentation
// NOTE: If making updates here you also need to update the test helper in client/lcd/test_helper.go
func registerRoutes(rs *lcd.RestServer) {
    client.RegisterRoutes(rs.CliCtx, rs.Mux)
    authrest.RegisterTxRoutes(rs.CliCtx, rs.Mux)
    app.ModuleBasics.RegisterRESTRoutes(rs.CliCtx, rs.Mux)
    // this line is used by starport scaffolding # 2
}

func initConfig(cmd *cobra.Command) error {
    home, err := cmd.PersistentFlags().GetString(cli.HomeFlag)
    if err != nil {
        return err
    }

    cfgFile := path.Join(home, "config", "config.toml")
    if _, err := os.Stat(cfgFile); err == nil {
        viper.SetConfigFile(cfgFile)

        if err := viper.ReadInConfig(); err != nil {
            return err
        }
    }
    if err := viper.BindPFlag(flags.FlagChainID, cmd.PersistentFlags().Lookup(flags.FlagChainID)); err != nil {
        return err
    }
    if err := viper.BindPFlag(cli.EncodingFlag, cmd.PersistentFlags().Lookup(cli.EncodingFlag)); err != nil {
        return err
    }
    return viper.BindPFlag(cli.OutputFlag, cmd.PersistentFlags().Lookup(cli.OutputFlag))
}
*/
