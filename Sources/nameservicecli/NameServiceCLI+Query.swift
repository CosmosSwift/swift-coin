import ArgumentParser
import Cosmos
import Auth

public struct KeysOptions: ParsableArguments {
    @Option(name: .customLong("keyring-backend"), help: "Select keyring's backend (os|file|test)")
    public var keyringBackend: KeyringBacked = .os

    public init() {}
}

// Commands registers a sub-tree of commands to interact with
// local private key storage.
public struct QueryCommand: ParsableCommand {
    public static var defaultHome: String!
    public static var codec: Codec!
    public static var moduleBasicManager: BasicManager!
    
    public static var configuration = CommandConfiguration(
        commandName: "query",
        abstract: "Querying commands",
        discussion:
        """
        Query allows to query the blockchain node
        """,
        subcommands: [
            GetAccount.self,
            QueryTransactionsByEvents.self,
            QueryTransaction.self
     
            //            RPC.ValidatorCommand.self,
            //            RPC.BlockCommand.self,
        ]
    )

    public init() {}
}

/*
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
 */
