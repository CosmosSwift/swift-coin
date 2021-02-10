import ArgumentParser

public struct NodeURL: ExpressibleByArgument {
    public enum URLScheme: String {
        case tcp
        case http
        case https
    }
    
    let scheme: URLScheme
    let host: String
    let port: Int
    
    public init?(argument: String) {
        let parts = argument.split(separator: ":")
        switch parts.count {
        case 3:
            guard let scheme = URLScheme(rawValue: String(parts[0]))  else {
                return nil
            }
            self.scheme = scheme
            self.host = String(parts[1].dropFirst(2))
            guard let port = Int(parts[2]) else {
                return nil
            }
            self.port = port
        case 2:
            self.scheme = .tcp
            self.host = String(parts[1])
            guard let port = Int(parts[2]) else {
                return nil
            }
            self.port = port
        default:
            return nil
        }
    }
}

public struct AuthClientOptions: ParsableArguments {
    public enum OutputFormat: String, ExpressibleByArgument {
        case text
        case json
    }
    
    @Option(
        name: [.customShort("o"), .customLong("output")],
        help: "Output format (text|json)"
    )
    public var output: OutputFormat = .text
    
    @Option(
        name: [.customLong("node")],
        help: "<host>:<port> to Tendermint RPC interface for this chain"
    )
    public var node: NodeURL = NodeURL(argument: "tcp://localhost:26657")!
    
    @Option(
        name: [.customLong("height")],
        help: "Use a specific height to query state at (this can error if the node is pruning state)"
    )
    public var height: UInt64 = 0
    
    @Option(
        name: [.customLong("chain-id")],
        help: "Chain Id"
    )
    public var chainId: String
    
    public init() {}
}
