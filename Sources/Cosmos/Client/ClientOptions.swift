import ArgumentParser

public struct ClientOptions: ParsableArguments {
    public static var defaultHome: String = ""
    
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
        name: [.customLong("home")],
        help: "directory for config and data"
    )
    public var home: String = Self.defaultHome
    
    public init() {}
}
