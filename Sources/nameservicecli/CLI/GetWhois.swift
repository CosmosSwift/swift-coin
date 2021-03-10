import Foundation
import ArgumentParser
import Cosmos

public struct GetWhois: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "get-whois",
        abstract: "Query a whois by key."
    )
      
    @Argument(help: "From key or Address.")
    var key: String // TODO: not sure what the type is

    public init() {}
    
    public mutating func run() throws {
        fatalError()
//        RunE: func(cmd *cobra.Command, args []string) error {
//            cliCtx := context.NewCLIContext().WithCodec(cdc)
//            key := args[0]
//
//            res, _, err := cliCtx.QueryWithData(fmt.Sprintf("custom/%s/%s/%s", queryRoute, types.QueryGetWhois, key), nil)
//            if err != nil {
//                fmt.Printf("could not resolve whois %s \n%s\n", key, err.Error())
//
//                return nil
//            }
//
//            var out types.Whois
//            cdc.MustUnmarshalJSON(res, &out)
//            return cliCtx.PrintOutput(out)
//        },
    }
}


/*
 package cli

 import (
     "fmt"

     "github.com/cosmos/cosmos-sdk/client/context"
     "github.com/cosmos/cosmos-sdk/codec"
     "github.com/cosmos/sdk-tutorials/nameservice/nameservice/x/nameservice/types"
     "github.com/spf13/cobra"
 )


 func GetCmdGetWhois(queryRoute string, cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "get-whois [key]",
         Short: "Query a whois by key",
         Args:  cobra.ExactArgs(1),
         RunE: func(cmd *cobra.Command, args []string) error {
             cliCtx := context.NewCLIContext().WithCodec(cdc)
             key := args[0]

             res, _, err := cliCtx.QueryWithData(fmt.Sprintf("custom/%s/%s/%s", queryRoute, types.QueryGetWhois, key), nil)
             if err != nil {
                 fmt.Printf("could not resolve whois %s \n%s\n", key, err.Error())

                 return nil
             }

             var out types.Whois
             cdc.MustUnmarshalJSON(res, &out)
             return cliCtx.PrintOutput(out)
         },
     }
 }

 */
