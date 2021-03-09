import Foundation
import ArgumentParser
import Cosmos


// GetCmdResolveName queries information about a name
public struct Resolve: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "resolve",
        abstract: "Resolve name."
    )
      
    @Argument(help: "Domain name to resolve.")
    var name: String


    public init() {}
    
    public mutating func run() throws {
        fatalError()
//        RunE: func(cmd *cobra.Command, args []string) error {
//            cliCtx := context.NewCLIContext().WithCodec(cdc)
//            name := args[0]
//
//            res, _, err := cliCtx.QueryWithData(fmt.Sprintf("custom/%s/%s/%s", queryRoute, types.QueryResolveName, name), nil)
//            if err != nil {
//                fmt.Printf("could not resolve name - %s \n", name)
//                return nil
//            }
//
//            var out types.QueryResResolve
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

 // GetCmdResolveName queries information about a name
 func GetCmdResolveName(queryRoute string, cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "resolve [name]",
         Short: "resolve name",
         Args:  cobra.ExactArgs(1),
         RunE: func(cmd *cobra.Command, args []string) error {
             cliCtx := context.NewCLIContext().WithCodec(cdc)
             name := args[0]

             res, _, err := cliCtx.QueryWithData(fmt.Sprintf("custom/%s/%s/%s", queryRoute, types.QueryResolveName, name), nil)
             if err != nil {
                 fmt.Printf("could not resolve name - %s \n", name)
                 return nil
             }

             var out types.QueryResResolve
             cdc.MustUnmarshalJSON(res, &out)
             return cliCtx.PrintOutput(out)
         },
     }
 }

 */
