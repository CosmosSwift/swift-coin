import Foundation
import ArgumentParser
import CosmosProto
import NIO
import GRPC
import Cosmos
import ABCIREST
import ABCIMessages
import Tendermint
import AsyncHTTPClient

fileprivate let flagEvents = "events"

#warning("might be put in a more general location is used twice in the go source")
fileprivate let eventFormat = "{eventType}.{eventAttribute}={value}"

// GetQuery returns the transaction commands for this module
struct GetQuery: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: AuthKeys.moduleName,
        abstract: "Querying commands for the auth module",
        subcommands: [GetQueryParameters.self, GetAccount.self]
    )
    
    mutating func run() throws {
        
    }
}


// QueryParams returns the command handler for evidence parameter querying.
// This is a 0.4x.x call
public struct GetQueryParameters: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "params",
        abstract: "Query the current auth parameters",
        discussion: """
            Query the current auth parameters:
            
            $ <appd> query auth params
            """
    )
    
    @OptionGroup var queryFlags: Flags.QueryFlags
  
    public init() {}
    
    /*struct GetParamsPayload: RequestPayload {
        static var method: ABCIREST.Method { .abci_query }
        var path: String { "custom/acc/" }
        
        typealias ResponsePayload = AnyProtocolCodable // This is an Account

        let Address: AccountAddress
        
    }*/
    
    public mutating func run() throws {
        fatalError()
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
    }
}

// GetAccount returns a query account that will display the state of the account at a given address.
public struct GetAccount: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "account",
        abstract: "Query for account by address"
    )
    
    @OptionGroup var queryFlags: Flags.QueryFlags

    @Argument var address: AccountAddress
    
    
    struct GetAccountPayload: Codable {
        let Address: AccountAddress
    }
    
    public init() {}
        
    public mutating func run() throws {
        // TODO: map url to the proper value
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        let client = RESTClient(url: "http://192.168.64.1:26657", httpClient: httpClient)
        let height: Int64 = 4
        let prove = false
        
        let params = RequestQuery(data: GetAccountPayload(Address: self.address), path: "custom/acc/account", height: height, prove: prove)
        let response: RESTResponse<ResponseQuery<AnyProtocolCodable>> = try client.abciQuery(id: 10, params: params).wait()
                
        let data = try JSONEncoder().encode(response)
        
        print(String(data: data, encoding: .utf8)!)
    }
}


// QueryTransactionsByEvents returns a command to search through transactions by events.
public struct QueryTransactionsByEvents: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "txs",
        abstract: "Query for paginated transactions that match a set of events",
        discussion: """
            Search for transactions that match the exact given events where results are paginated.
            Each event takes the form of '\(eventFormat)'. Please refer
            to each module's documentation for the full set of events to query for. Each module
            documents its respective events under 'xx_events.md'.
            Example:
            $ \(Version.appName) query txs --\(flagEvents) 'message.sender=cosmos1...&message.action=withdraw_delegator_reward' --page 1 --limit 30
            """
    )
    
    #warning("the <host>:<port> format seems like it could leverage some type safety")
    @Option(help: "<host>:<port> to Tendermint RPC interface for this chain")
    var node: Flags.NodeURL = Flags.NodeURL(argument: "tcp://localhost:26657")!
    
    enum KeyRingBackend: String, ExpressibleByArgument {
        case os
        case file
        case kwallet
        case pass
        case test
    }
    
    @Option(help: "Select keyring's backend (os|file|kwallet|pass|test)")
    var keyringBackend: KeyRingBackend = .os
    
    @Option(help: "Query a specific page of paginated results")
    var page: Int = Rest.defaultPage
    
    @Option(help: "Query number of transactions results per page returned")
    var limit: Int = Rest.defaultLimit
    
    #warning("This still needs a correct Event type")
    @Option(help: "list of transaction events in the form of \(eventFormat)")
    var events: String
    
    #warning("this comes from the root command but is marked required (in go) for this implementation specifically")
    @Option(help: "The network chain ID")
    var chainId: String
    
    public init() { }
    
    public mutating func run() throws {
        fatalError()
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
        //
        //        return cmd
        //    }
    }
}

// QueryTransaction implements the default command for a tx query.
public struct QueryTransaction: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "tx",
        abstract: "Query for a transaction by hash in a committed block"
    )
    
    @OptionGroup var queryFlags: Flags.QueryFlags
    
    #warning("still needs renaming")
    @Argument var txHash: String
    
    
//    struct Payload: RequestPayload {
//        static var method: ABCIREST.Method { .abci_query }
//        var path: String { "custom/acc/account" }
//        
//        typealias ResponsePayload = TxResponse // This is an Account
//
//        let hash: String
//        
//    }
    
    
    
    public init() { }
    
    public mutating func run() throws {
        
        
        
        
        fatalError()
        //    func QueryTxCmd() *cobra.Command {
        //        cmd := &cobra.Command{
        //            Use:   "tx [hash]",
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
        ////
        //        return cmd
        //    }
        //    */
        
        
        
//        TxResponse{
//                TxHash:    res.Hash.String(),
//                Height:    res.Height,
//                Codespace: res.TxResult.Codespace,
//                Code:      res.TxResult.Code,
//                Data:      strings.ToUpper(hex.EncodeToString(res.TxResult.Data)),
//                RawLog:    res.TxResult.Log,
//                Logs:      parsedLogs,
//                Info:      res.TxResult.Info,
//                GasWanted: res.TxResult.GasWanted,
//                GasUsed:   res.TxResult.GasUsed,
//                Tx:        anyTx,
//                Timestamp: timestamp,
//            }
    }
}
