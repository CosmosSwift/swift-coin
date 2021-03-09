import Foundation
import ArgumentParser
import Cosmos

public struct SetName: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "set-name",
        abstract: "Set a new name."
    )

    @Argument(help: "Domain name to set.")
    var from: String
    
    @Argument(help: "Updated name.")
    var to: String


    public init() {}
    
    public mutating func run() throws {
        fatalError()
//        RunE: func(cmd *cobra.Command, args []string) error {
//            argsValue := args[0]
//            argsName := args[1]
//
//            cliCtx := context.NewCLIContext().WithCodec(cdc)
//            inBuf := bufio.NewReader(cmd.InOrStdin())
//            txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
//            msg := types.NewMsgSetName(cliCtx.GetFromAddress(), argsValue, argsName)
//            err := msg.ValidateBasic()
//            if err != nil {
//                return err
//            }
//            return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
//        },
    }
}


/*
 package cli

 import (
     "bufio"

     "github.com/spf13/cobra"

     "github.com/cosmos/cosmos-sdk/client/context"
     "github.com/cosmos/cosmos-sdk/codec"
     sdk "github.com/cosmos/cosmos-sdk/types"
     "github.com/cosmos/cosmos-sdk/x/auth"
     "github.com/cosmos/cosmos-sdk/x/auth/client/utils"
     "github.com/cosmos/sdk-tutorials/nameservice/nameservice/x/nameservice/types"
 )

 func GetCmdSetWhois(cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "set-name [value] [name]",
         Short: "Set a new name",
         Args:  cobra.ExactArgs(2),
         RunE: func(cmd *cobra.Command, args []string) error {
             argsValue := args[0]
             argsName := args[1]

             cliCtx := context.NewCLIContext().WithCodec(cdc)
             inBuf := bufio.NewReader(cmd.InOrStdin())
             txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
             msg := types.NewMsgSetName(cliCtx.GetFromAddress(), argsValue, argsName)
             err := msg.ValidateBasic()
             if err != nil {
                 return err
             }
             return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
         },
     }
 }
 */
