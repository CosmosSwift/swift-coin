import Foundation
import ArgumentParser
import Cosmos
import NameService


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
        let response = client.query(path: "custom/\(queryRoute)/get-whois/\(key)").map { data, height in
            return data as Whois
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
