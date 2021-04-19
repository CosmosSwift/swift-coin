import Foundation
import ArgumentParser
import Cosmos
import Tendermint
import AsyncHTTPClient
import ABCIMessages
import NameService

public struct ListWhois: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list-whois",
        abstract: "list all whois"
    )
    
    @OptionGroup var queryFlags: Flags.QueryFlags

    public init() {}
    
    public mutating func run() throws {
        #warning("This can be removed or hardcoded in the url I believe")
        let queryRoute = "nameservice"
        
        
//        let height: Int64 = queryFlags.height
//        #warning("These shouldn't be hardcoded?")
//        let prove = false
        
        let client = CosmosClient(url: queryFlags.node.description, eventLoopGroupProvider: .createNew)
        let response = client.query(path: "custom/\(queryRoute)/list-whois").map { data, height in
            return data as [Whois]
        }
        
        switch response {
        case let .failure(error):
            fatalError(error.localizedDescription)
        case let .success(data):
            let d = try JSONEncoder().encode(data)
            print(String(data: d, encoding: .utf8)!)
        }
    }
}
