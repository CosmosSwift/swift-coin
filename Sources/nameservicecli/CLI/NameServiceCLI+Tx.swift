import ArgumentParser
import Cosmos
import Auth
import Bank

// Commands registers a sub-tree of commands to interact with
// local private key storage.
public struct TransactionCommand: ParsableCommand {
    public static var defaultHome: String!
    public static var codec: Codec!
    public static var moduleBasicManager: BasicManager!
    
    public static var configuration = CommandConfiguration(
        commandName: "tx",
        abstract: "Transaction subcommands",
        discussion:
        """
        Performs transactions on the blockchain
        """,
        subcommands: [
            SendTransaction.self,
            GetSign.self,
            GetMultiSign.self,
            GetBroadcast.self,
            GetEncode.self,
            GetDecode.self,

            //            RPC.ValidatorCommand.self,
            //            RPC.BlockCommand.self,
            TransactionNameserviceCommand.self
        ]
    )

    public init() {}
}


public struct TransactionNameserviceCommand: ParsableCommand {
    public static var defaultHome: String!
    public static var codec: Codec!
    public static var moduleBasicManager: BasicManager!
    
    public static var configuration = CommandConfiguration(
        commandName: "nameservice",
        abstract: "Nameservice specific transaction commands",
        discussion:"""
        """,
        subcommands: [
            BuyName.self,
            SetName.self,
            DeleteName.self
        ]
    )

    public init() {}
}

/*
 
 
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
 
 */
