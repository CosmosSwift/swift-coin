import ArgumentParser

public struct ClientOptions: ParsableArguments {
    public enum OutputFormat: String, ExpressibleByArgument {
        case text
        case json
    }
    
    @Option(
        name: [.customShort("o"), .customLong("output")],
        help: "Output format (text|json)"
    )
    public var output: OutputFormat = .text
    
    public init() {}
}
