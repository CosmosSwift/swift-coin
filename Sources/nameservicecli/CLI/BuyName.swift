import Foundation
import ArgumentParser
import Cosmos
import ABCIREST

public struct BuyName: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "buy-name",
        abstract: "Buys a new name."
    )
    
    @OptionGroup var txFlags: Flags.TransactionFlags
      
    @Argument(help: "Domain name to buy.")
    var name: String
    
    @Argument(help: "Price.")
    var price: UInt

    public init() {}
    
    public mutating func run() throws {
        fatalError()
//        RunE: func(cmd *cobra.Command, args []string) error {
//            argsName := string(args[0])
//
//            cliCtx := context.NewCLIContext().WithCodec(cdc)
//            inBuf := bufio.NewReader(cmd.InOrStdin())
//            txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))
//
//            coins, err := sdk.ParseCoins(args[1])
//            if err != nil {
//                return err
//            }
//
//            msg := types.NewMsgBuyName(argsName, coins, cliCtx.GetFromAddress())
//            err = msg.ValidateBasic()
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

 func GetCmdBuyName(cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "buy-name [name] [price]",
         Short: "Buys a new name",
         Args:  cobra.ExactArgs(2),
         RunE: func(cmd *cobra.Command, args []string) error {
             argsName := string(args[0])

             cliCtx := context.NewCLIContext().WithCodec(cdc)
             inBuf := bufio.NewReader(cmd.InOrStdin())
             txBldr := auth.NewTxBuilderFromCLI(inBuf).WithTxEncoder(utils.GetTxEncoder(cdc))

             coins, err := sdk.ParseCoins(args[1])
             if err != nil {
                 return err
             }

             msg := types.NewMsgBuyName(argsName, coins, cliCtx.GetFromAddress())
             err = msg.ValidateBasic()
             if err != nil {
                 return err
             }
             return utils.GenerateOrBroadcastMsgs(cliCtx, txBldr, []sdk.Msg{msg})
         },
     }
 }

 */
