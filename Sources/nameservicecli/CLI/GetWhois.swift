import Foundation
import ArgumentParser
import Cosmos


public struct GetWhois: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "get-whois",
        abstract: "query a whois by key"
    )
    
    @OptionGroup var queryFlags: Flags.QueryFlags
    
    @Argument var key: String

    public init() {}
    
    public mutating func run() throws {
        #warning("This can be removed or hardcoded in the url I believe")
        let queryRoute = "nameservice"
        
        let client = CosmosClient(url: queryFlags.node.description, eventLoopGroupProvider: .createNew)
        let response = client.queryWithData(path: "custom/\(queryRoute)/get-whois/\(key)", data: nil).map { data, height in
            return data
        }
        
        switch response {
        case let .failure(error):
            fatalError(error.localizedDescription)
        case let .success(data):
//            var out []types.Whois
//            cdc.MustUnmarshalJSON(res, &out)
//            return cliCtx.PrintOutput(out)
            let jsonDecoder = JSONDecoder()
            let whoIs = try jsonDecoder.decode(WhoIs.self, from: data)
            print(whoIs)
        }
    }
}
