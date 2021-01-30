import ArgumentParser

public struct ServerOptions: ParsableArguments {
    @Option(name: .customLong("inv-check-period"), help: "Assert registered invariants every N blocks")
    public var invariantCheckPeriod: UInt = 0

    @Option(name: .long, help: "directory for config and data")
    public var home: String?
    
    public init() {}
}
