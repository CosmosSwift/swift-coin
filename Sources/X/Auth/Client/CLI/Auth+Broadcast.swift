import Foundation
import ArgumentParser
import Cosmos


// GetBroadcastCommand returns the tx broadcast command.
public struct GetBroadcast: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "broadcast",
        abstract: "Broadcast transactions generated offline",
        discussion: """
             Broadcast transactions created with the --generate-only
             flag and signed with the sign command. Read a transaction from [file_path] and
             broadcast it to a node. If you supply a dash (-) argument in place of an input
             filename, the command reads from standard input.
             $ <appd> tx broadcast ./mytxn.json
            """
    )
    
    @OptionGroup var txFlags: Flags.TransactionFlags
  
    
    @Argument var filePath: String

    public init() {}
    
//    struct Payload: RequestPayload {
//        static var method: ABCIREST.Method { .abci_query }
//        var path: String { "custom/acc/" }
//
//        typealias ResponsePayload = AnyProtocolCodable // This is an Account
//
//        let Address: AccountAddress
//        
//    }
    
    public mutating func run() throws {
        fatalError()
        //            RunE: func(cmd *cobra.Command, args []string) error {
//        clientCtx, err := client.GetClientTxContext(cmd)
//        if err != nil {
//            return err
//        }
//
//        if offline, _ := cmd.Flags().GetBool(flags.FlagOffline); offline {
//            return errors.New("cannot broadcast tx during offline mode")
//        }
//
//        stdTx, err := authclient.ReadTxFromFile(clientCtx, args[0])
//        if err != nil {
//            return err
//        }
//
//        txBytes, err := clientCtx.TxConfig.TxEncoder()(stdTx)
//        if err != nil {
//            return err
//        }
//
//        res, err := clientCtx.BroadcastTx(txBytes)
//        if err != nil {
//            return err
//        }
//
//        return clientCtx.PrintProto(res)
        //            },
    }
}





/*
 
 
 package cli

 import (
     "errors"
     "strings"

     "github.com/spf13/cobra"

     "github.com/cosmos/cosmos-sdk/client"
     "github.com/cosmos/cosmos-sdk/client/flags"
     authclient "github.com/cosmos/cosmos-sdk/x/auth/client"
 )

 // GetBroadcastCommand returns the tx broadcast command.
 func GetBroadcastCommand() *cobra.Command {
     cmd := &cobra.Command{
         Use:   "broadcast [file_path]",
         Short: "Broadcast transactions generated offline",
         Long: strings.TrimSpace(`Broadcast transactions created with the --generate-only
 flag and signed with the sign command. Read a transaction from [file_path] and
 broadcast it to a node. If you supply a dash (-) argument in place of an input
 filename, the command reads from standard input.
 $ <appd> tx broadcast ./mytxn.json
 `),
         Args: cobra.ExactArgs(1),
         RunE: func(cmd *cobra.Command, args []string) error {
             clientCtx, err := client.GetClientTxContext(cmd)
             if err != nil {
                 return err
             }

             if offline, _ := cmd.Flags().GetBool(flags.FlagOffline); offline {
                 return errors.New("cannot broadcast tx during offline mode")
             }

             stdTx, err := authclient.ReadTxFromFile(clientCtx, args[0])
             if err != nil {
                 return err
             }

             txBytes, err := clientCtx.TxConfig.TxEncoder()(stdTx)
             if err != nil {
                 return err
             }

             res, err := clientCtx.BroadcastTx(txBytes)
             if err != nil {
                 return err
             }

             return clientCtx.PrintProto(res)
         },
     }

     flags.AddTxFlagsToCmd(cmd)

     return cmd
 }
 */
