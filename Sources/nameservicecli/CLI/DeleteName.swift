import Foundation
import ArgumentParser
import Cosmos

public struct DeleteName: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "delete-name",
        abstract: "Deletes a domain name by id."
    )
      
    @Argument(help: "From key or Address.")
    var domainId: UInt // TODO: verify that this is the proper type

    public init() {}
    
    public mutating func run() throws {
        fatalError()
//        RunE: func(cmd *cobra.Command, args []string) error {
//
//            cliCtx := context.NewCLIContext().WithCodec(cdc)
//            inBuf := bufio.NewReader(cmd.InOrStdin())
//            txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
//
//            msg := types.NewMsgDeleteName(args[0], cliCtx.GetFromAddress())
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


 func GetCmdDeleteWhois(cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "delete-name [id]",
         Short: "Delete a new name by ID",
         Args:  cobra.ExactArgs(1),
         RunE: func(cmd *cobra.Command, args []string) error {

             cliCtx := context.NewCLIContext().WithCodec(cdc)
             inBuf := bufio.NewReader(cmd.InOrStdin())
             txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))

             msg := types.NewMsgDeleteName(args[0], cliCtx.GetFromAddress())
             err := msg.ValidateBasic()
             if err != nil {
                 return err
             }
             return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
         },
     }
 }

 */
