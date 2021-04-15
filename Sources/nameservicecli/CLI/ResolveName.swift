import Foundation
import ArgumentParser
import Cosmos

// GetCmdResolveName queries information about a name
public struct ResolveName: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "resolve",
        abstract: "resolve name"
    )
    
    @OptionGroup var queryFlags: Flags.QueryFlags
    
    @Argument(help: "Domain name to resolve")
    var name: String

    public init() {}
    
    public mutating func run() throws {
        #warning("This can be removed or hardcoded in the url I believe")
        let queryRoute = "nameservice"
        
        let client = CosmosClient(url: queryFlags.node.description, eventLoopGroupProvider: .createNew)
        let response = client.queryWithData(path: "custom/\(queryRoute)/resolve-name/\(name)", data: nil).map { data, height in
            return data
        }
        
        switch response {
        case let .failure(error):
            fatalError(error.localizedDescription)
        case let .success(data):
//            var out types.QueryResResolve
//            cdc.MustUnmarshalJSON(res, &out)
//            return cliCtx.PrintOutput(out)
            let jsonDecoder = JSONDecoder()
            let queryResponse = try jsonDecoder.decode(QueryResponseResolve.self, from: data)
            print(queryResponse)
        }
    }
}
