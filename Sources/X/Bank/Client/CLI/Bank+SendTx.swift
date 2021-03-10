import Foundation
import ArgumentParser
import Cosmos


// GetEncodeCommand returns the encode command to take a JSONified transaction and turn it into
// Amino-serialized bytes
public struct SendTransaction: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "send",
        abstract: "Create and sign a send tx.",
        discussion: """
    Encode transactions created with the --generate-only flag and signed with the sign command.
        Read a transaction from <file>, serialize it to the Amino wire protocol, and output it as base64.
        If you supply a dash (-) argument in place of an input filename, the command reads from standard input.
    """
    )
    
    @OptionGroup var txFlags: Flags.TransactionFlags
      
    @Argument(help: "From key or Address.")
    var from: AccountAddress
    
    @Argument(help: "To key or Address.")
    var to: AccountAddress

    @Argument(help: "Amount.")
    var amount: UInt

    public init() {}
    
    public mutating func run() throws {
        fatalError()
//        RunE: func(cmd *cobra.Command, args []string) error {
//            inBuf := bufio.NewReader(cmd.InOrStdin())
//            txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
//            cliCtx := context.NewCLIContextWithInputAndFrom(inBuf, args[0]).WithCodec(cdc)
//
//            to, err := sdk.AccAddressFromBech32(args[1])
//            if err != nil {
//                return err
//            }
//
//            // parse coins trying to be sent
//            coins, err := sdk.ParseCoins(args[2])
//            if err != nil {
//                return err
//            }
//
//            // build and sign the transaction, then broadcast to Tendermint
//            msg := types.NewMsgSend(cliCtx.GetFromAddress(), to, coins)
//            return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
//        },
    }
}


/*
 package cli

 import (
     "bufio"

     "github.com/spf13/cobra"

     "github.com/cosmos/cosmos-sdk/client"
     "github.com/cosmos/cosmos-sdk/client/context"
     "github.com/cosmos/cosmos-sdk/client/flags"
     "github.com/cosmos/cosmos-sdk/codec"
     sdk "github.com/cosmos/cosmos-sdk/types"
     "github.com/cosmos/cosmos-sdk/x/auth"
     "github.com/cosmos/cosmos-sdk/x/auth/client/utils"
     "github.com/cosmos/cosmos-sdk/x/bank/internal/types"
 )

 // GetTxCmd returns the transaction commands for this module
 func GetTxCmd(cdc *codec.Codec) *cobra.Command {
     txCmd := &cobra.Command{
         Use:                        types.ModuleName,
         Short:                      "Bank transaction subcommands",
         DisableFlagParsing:         true,
         SuggestionsMinimumDistance: 2,
         RunE:                       client.ValidateCmd,
     }
     txCmd.AddCommand(
         SendTxCmd(cdc),
     )
     return txCmd
 }

 // SendTxCmd will create a send tx and sign it with the given key.
 func SendTxCmd(cdc *codec.Codec) *cobra.Command {
     cmd := &cobra.Command{
         Use:   "send [from_key_or_address] [to_address] [amount]",
         Short: "Create and sign a send tx",
         Args:  cobra.ExactArgs(3),
         RunE: func(cmd *cobra.Command, args []string) error {
             inBuf := bufio.NewReader(cmd.InOrStdin())
             txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
             cliCtx := context.NewCLIContextWithInputAndFrom(inBuf, args[0]).WithCodec(cdc)

             to, err := sdk.AccAddressFromBech32(args[1])
             if err != nil {
                 return err
             }

             // parse coins trying to be sent
             coins, err := sdk.ParseCoins(args[2])
             if err != nil {
                 return err
             }

             // build and sign the transaction, then broadcast to Tendermint
             msg := types.NewMsgSend(cliCtx.GetFromAddress(), to, coins)
             return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
         },
     }

     cmd = flags.PostCommands(cmd)[0]

     return cmd
 }
 */
