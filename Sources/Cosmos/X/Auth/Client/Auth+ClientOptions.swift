import ArgumentParser

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
    public var node: String = "tcp://localhost:26657"
    
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
