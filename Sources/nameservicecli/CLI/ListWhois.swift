import Foundation
import ArgumentParser
import Cosmos

public struct ListWhois: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list-whois",
        abstract: "list all whois.",
        discussion: """
    """
    )
    
    @OptionGroup var txFlags: Flags.TransactionFlags
    

    public init() {}
    
    public mutating func run() throws {
        fatalError()

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

 func GetCmdListWhois(queryRoute string, cdc *codec.Codec) *cobra.Command {
     return &cobra.Command{
         Use:   "list-whois",
         Short: "list all whois",
         RunE: func(cmd *cobra.Command, args []string) error {
             cliCtx := context.NewCLIContext().WithCodec(cdc)
             res, _, err := cliCtx.QueryWithData(fmt.Sprintf("custom/%s/%s", queryRoute, types.QueryListWhois), nil)
             if err != nil {
                 fmt.Printf("could not list Whois\n%s\n", err.Error())
                 return nil
             }
             var out []types.Whois
             cdc.MustUnmarshalJSON(res, &out)
             return cliCtx.PrintOutput(out)
         },
     }
 }

 */
