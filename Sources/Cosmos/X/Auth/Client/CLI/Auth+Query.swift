import Foundation
import ArgumentParser
import CosmosProto
import NIO
import GRPC

extension AccountAddress: ExpressibleByArgument {
    public init?(argument: String) {
        try? self.init(bech32Encoded: argument)
    }
}

// GetAccountCmd returns a query account that will display the state of the
// account at a given address.
public struct GetAccountCommand: ParsableCommand {

    @OptionGroup
    private var clientOptions: AuthClientOptions
    
    public static var configuration = CommandConfiguration(
        commandName: "account",
        abstract: "Query for account by address"
    )

    @Argument
    var address: AccountAddress
    
    public init() {}
    
    public func run() throws {
        // Setup an `EventLoopGroup` for the connection to run on.
        //
        // See: https://github.com/apple/swift-nio#eventloops-and-eventloopgroups
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        // Make sure the group is shutdown when we're done with it.
        defer {
          try! group.syncShutdownGracefully()
        }

        // Configure the channel, we're not using TLS so the connection is `insecure`.
        let channel = ClientConnection.insecure(group: group)
            .connect(host: clientOptions.node.host, port: clientOptions.node.port)

        // Close the connection when we're done with it.
        defer {
          try! channel.close().wait()
        }

        let client = Cosmos_Auth_V1beta1_QueryClient(channel: channel)
        
        let request = Cosmos_Auth_V1beta1_QueryAccountRequest.with {
            $0.address = address.data.hexEncodedString()
        }
        
        let getAccount = client.account(request)
        
        do {
            let response = try getAccount.response.wait()
            print(response.account)
        } catch {
            print("Getting Account failed: \(error)")
        }
    }
}


// GetQuery returns the transaction commands for this module
struct GetQuery: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: AuthKeys.moduleName,
        abstract: "Querying commands for the auth module",
        subcommands: [GetQueryParameters.self, GetAccount.self]
    )
    
    mutating func run() throws {
        
    }
}


// QueryParams returns the command handler for evidence parameter querying.
struct GetQueryParameters: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "params",
        abstract: "Query the current auth parameters"
    )
    
    @OptionGroup var queryFlags: Flags.QueryFlags
    
    mutating func run() throws {
        
    }
//    func QueryParamsCmd() *cobra.Command {
//        cmd := &cobra.Command{
//            Use:   "params",
//            Short: "Query the current auth parameters",
//            Args:  cobra.NoArgs,
//            Long: strings.TrimSpace(`Query the current auth parameters:
//    $ <appd> query auth params
//    `),
//            RunE: func(cmd *cobra.Command, args []string) error {
//                clientCtx, err := client.GetClientQueryContext(cmd)
//                if err != nil {
//                    return err
//                }
//
//                queryClient := types.NewQueryClient(clientCtx)
//                res, err := queryClient.Params(context.Background(), &types.QueryParamsRequest{})
//                if err != nil {
//                    return err
//                }
//
//                return clientCtx.PrintProto(&res.Params)
//            },
//        }
//
//        flags.AddQueryFlagsToCmd(cmd)
//
//        return cmd
//    }

}

// GetAccount returns a query account that will display the state of the account at a given address.
struct GetAccount: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "account",
        abstract: "Query for account by address"
    )
    
    @Argument
    var address: AccountAddress
    
    @OptionGroup var queryFlags: Flags.QueryFlags
    
    mutating func run() throws {
        
    }
//    func GetAccountCmd() *cobra.Command {
//        cmd := &cobra.Command{
//            Use:   "account [address]",
//            Short: "Query for account by address",
//            Args:  cobra.ExactArgs(1),
//            RunE: func(cmd *cobra.Command, args []string) error {
//                clientCtx, err := client.GetClientQueryContext(cmd)
//                if err != nil {
//                    return err
//                }
//                key, err := sdk.AccAddressFromBech32(args[0])
//                if err != nil {
//                    return err
//                }
//
//                queryClient := types.NewQueryClient(clientCtx)
//                res, err := queryClient.Account(context.Background(), &types.QueryAccountRequest{Address: key.String()})
//                if err != nil {
//                    return err
//                }
//
//                return clientCtx.PrintProto(res.Account)
//            },
//        }
//
//        flags.AddQueryFlagsToCmd(cmd)
//
//        return cmd
//    }
}

// QueryTransactionsByEvents returns a command to search through transactions by events.
struct QueryTransactionsByEvents: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: <#T##String?#>,
        abstract: <#T##String#>,
        discussion: <#T##String#>,
        version: <#T##String#>,
        shouldDisplay: <#T##Bool#>,
        subcommands: <#T##[ParsableCommand.Type]#>,
        defaultSubcommand: <#T##ParsableCommand.Type?#>,
        helpNames: <#T##NameSpecification#>
    )
    
    mutating func run() throws {
        
    }
//    func QueryTxsByEventsCmd() *cobra.Command {
//        cmd := &cobra.Command{
//            Use:   "txs",
//            Short: "Query for paginated transactions that match a set of events",
//            Long: strings.TrimSpace(
//                fmt.Sprintf(`
//    Search for transactions that match the exact given events where results are paginated.
//    Each event takes the form of '%s'. Please refer
//    to each module's documentation for the full set of events to query for. Each module
//    documents its respective events under 'xx_events.md'.
//    Example:
//    $ %s query txs --%s 'message.sender=cosmos1...&message.action=withdraw_delegator_reward' --page 1 --limit 30
//    `, eventFormat, version.AppName, flagEvents),
//            ),
//            RunE: func(cmd *cobra.Command, args []string) error {
//                clientCtx, err := client.GetClientQueryContext(cmd)
//                if err != nil {
//                    return err
//                }
//                eventsRaw, _ := cmd.Flags().GetString(flagEvents)
//                eventsStr := strings.Trim(eventsRaw, "'")
//
//                var events []string
//                if strings.Contains(eventsStr, "&") {
//                    events = strings.Split(eventsStr, "&")
//                } else {
//                    events = append(events, eventsStr)
//                }
//
//                var tmEvents []string
//
//                for _, event := range events {
//                    if !strings.Contains(event, "=") {
//                        return fmt.Errorf("invalid event; event %s should be of the format: %s", event, eventFormat)
//                    } else if strings.Count(event, "=") > 1 {
//                        return fmt.Errorf("invalid event; event %s should be of the format: %s", event, eventFormat)
//                    }
//
//                    tokens := strings.Split(event, "=")
//                    if tokens[0] == tmtypes.TxHeightKey {
//                        event = fmt.Sprintf("%s=%s", tokens[0], tokens[1])
//                    } else {
//                        event = fmt.Sprintf("%s='%s'", tokens[0], tokens[1])
//                    }
//
//                    tmEvents = append(tmEvents, event)
//                }
//
//                page, _ := cmd.Flags().GetInt(flags.FlagPage)
//                limit, _ := cmd.Flags().GetInt(flags.FlagLimit)
//
//                txs, err := authclient.QueryTxsByEvents(clientCtx, tmEvents, page, limit, "")
//                if err != nil {
//                    return err
//                }
//
//                return clientCtx.PrintProto(txs)
//            },
//        }
//
//        cmd.Flags().StringP(flags.FlagNode, "n", "tcp://localhost:26657", "Node to connect to")
//        cmd.Flags().String(flags.FlagKeyringBackend, flags.DefaultKeyringBackend, "Select keyring's backend (os|file|kwallet|pass|test)")
//        cmd.Flags().Int(flags.FlagPage, rest.DefaultPage, "Query a specific page of paginated results")
//        cmd.Flags().Int(flags.FlagLimit, rest.DefaultLimit, "Query number of transactions results per page returned")
//        cmd.Flags().String(flagEvents, "", fmt.Sprintf("list of transaction events in the form of %s", eventFormat))
//        cmd.MarkFlagRequired(flagEvents)
//
//        return cmd
//    }
}

// QueryTransaction implements the default command for a tx query.
struct QueryTransaction: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: <#T##String?#>,
        abstract: "Query for a transaction by hash in a committed block",
        subcommands: <#T##[ParsableCommand.Type]#>,
        defaultSubcommand: <#T##ParsableCommand.Type?#>,
        helpNames: <#T##NameSpecification#>
    )
    
    mutating func run() throws {
        
    }
//    func QueryTxCmd() *cobra.Command {
//        cmd := &cobra.Command{
//            Use:   "tx [hash]",
//            Short: "Query for a transaction by hash in a committed block",
//            Args:  cobra.ExactArgs(1),
//            RunE: func(cmd *cobra.Command, args []string) error {
//                clientCtx, err := client.GetClientQueryContext(cmd)
//                if err != nil {
//                    return err
//                }
//                output, err := authclient.QueryTx(clientCtx, args[0])
//                if err != nil {
//                    return err
//                }
//
//                if output.Empty() {
//                    return fmt.Errorf("no transaction found with hash %s", args[0])
//                }
//
//                return clientCtx.PrintProto(output)
//            },
//        }
//
//        flags.AddQueryFlagsToCmd(cmd)
//
//        return cmd
//    }
//    */
}


/*
 package cli

 import (
     "context"
     "fmt"
     "strings"

     "github.com/spf13/cobra"
     tmtypes "github.com/tendermint/tendermint/types"

     "github.com/cosmos/cosmos-sdk/client"
     "github.com/cosmos/cosmos-sdk/client/flags"
     sdk "github.com/cosmos/cosmos-sdk/types"
     "github.com/cosmos/cosmos-sdk/types/rest"
     "github.com/cosmos/cosmos-sdk/version"
     authclient "github.com/cosmos/cosmos-sdk/x/auth/client"
     "github.com/cosmos/cosmos-sdk/x/auth/types"
 )

 const (
     flagEvents = "events"

     eventFormat = "{eventType}.{eventAttribute}={value}"
 )
