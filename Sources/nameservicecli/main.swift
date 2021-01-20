import Foundation
import ABCI
import ABCINIO

public final class Store {
    public final class Transaction {
        var storage: [String: String] = [:]
        
        init() {}
         
        public func put(key: String, value: String) {
            self.storage[key] = value
        }
    }
    
    private var storage: [String: String] = [:]
    
    public init() {}
    
    public func makeTransaction() -> Transaction {
        Transaction()
    }
    
    public func get(key: String) -> String? {
        self.storage[key]
    }
     
    public func commit(transaction: Transaction) {
        self.storage.merge(transaction.storage, uniquingKeysWith: { _, new in new })
    }
}

enum Endpoint {
    case root
    case balance
    case store
}

public final class KeyValueStoreApp {
    private let store = Store()
    private var transaction: Store.Transaction? = nil

    public init() {
        
    }
}

extension KeyValueStoreApp: ABCIApplication {
    public func echo(request: RequestEcho) -> ResponseEcho {
        .init(message: request.message)
    }

    public func info(request: RequestInfo) -> ResponseInfo {
        .init()
    }

    public func initChain(request: RequestInitChain) -> ResponseInitChain {
        .init()
    }

    public func query(request: RequestQuery) -> ResponseQuery {
        guard let key = String(data: request.data, encoding: .utf8) else {
            return ResponseQuery(code: 1)
        }
        
        guard let value = self.persistedValue(key: key) else {
            return ResponseQuery(log: "does not exist")
        }
        
        return .init(
            log: "exists",
            key: key.data(using: .utf8)!,
            value: value.data(using: .utf8)!
        )
    }

    public func beginBlock(request: RequestBeginBlock) -> ResponseBeginBlock {
        self.transaction = self.store.makeTransaction()
        return .init()
    }

    public func checkTx(request: RequestCheckTx) -> ResponseCheckTx {
        let result = self.validate(tx: request.tx)
        return .init(code: result.code, gasWanted: 1)
    }

    public func deliverTx(request: RequestDeliverTx) -> ResponseDeliverTx {
        let result = self.validate(tx: request.tx)
        
        if case .valid(let key, let value) = result {
            self.persist(key: key, value: value)
        }
        
        return .init(code: result.code)
    }
    
    public func endBlock(request: RequestEndBlock) -> ResponseEndBlock {
        .init()
    }

    public func commit() -> ResponseCommit {
        guard let transaction = self.transaction else {
            fatalError("Unexpected state. Transaction should exist during commit.")
        }
        
        self.store.commit(transaction: transaction)
        return .init(data: Data(count: 8))
    }
    
    public func listSnapshots() -> ResponseListSnapshots {
        .init()
    }
    
    public func offerSnapshot(request: RequestOfferSnapshot) -> ResponseOfferSnapshot {
        .init()
    }
    
    public func loadSnapshotChunk(request: RequestLoadSnapshotChunk) -> ResponseLoadSnapshotChunk {
        .init()
    }
    
    public func applySnapshotChunk(request: RequestApplySnapshotChunk) -> ResponseApplySnapshotChunk {
        .init()
    }
}

enum ValidationResult {
    case invalidStringEncoding
    case invalidFormat
    case valueAlreadyExists
    case valid(key: String, value: String)
    
    var code: UInt32 {
        switch self {
        case .invalidStringEncoding:
            return 1
        case .invalidFormat:
            return 2
        case .valueAlreadyExists:
            return 3
        case .valid:
            return 0
        }
    }
}

extension KeyValueStoreApp {
    private func validate(tx: Data) -> ValidationResult {
        guard let string = String(data: tx, encoding: .utf8) else {
            return .invalidStringEncoding
        }
        
        let parts = string.split(separator: "=")
        
        guard parts.count == 2 else {
            return .invalidFormat
        }
        
        let key = String(parts[0])
        let value = String(parts[1])

        if let stored = self.persistedValue(key: key), stored == value {
            return .valueAlreadyExists
        }
        
        return .valid(key: key, value: value)
    }

    func persistedValue(key: String) -> String? {
        self.store.get(key: key)
    }
    
    func persist(key: String, value: String) {
        self.transaction?.put(key: key, value: value)
    }
}

let app = KeyValueStoreApp()
let server = NIOABCIServer(application: app)
try server.start()



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
