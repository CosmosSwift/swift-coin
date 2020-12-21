import Foundation
import ArgumentParser
import Logging
import ABCI
import ABCINIO
import Database

// StartCommand runs the service passed in stand-alone.
public struct StartCommand: ParsableCommand {
    private static let discussion = """
    Run the full node application with Tendermint out of process.
    """
    
    public static var configuration = CommandConfiguration(
        commandName: "start",
        abstract: "Run the full node",
        discussion: discussion
    )
    
    @Option(name: .long, help: "Listen address host")
    private var host: String = "127.0.0.1"

    @Option(name: .long, help: "Listen address port")
    private var port: Int = 26658
    
    @Option(name: .long, help: "Enable KeyValueStore tracing to an output file")
    private var storeTraceFilePath: String?
    
    @OptionGroup
    private var globalOptions: GlobalOptions

    public init() {}
    
    public func run() throws {
        let logger = ServerContext.logger
        logger.info("starting ABCI without Tendermint")

        let database = try ServerContext.makeDatabase(path: globalOptions.home ?? ServerContext.defaultHome)
        let traceWriter = try storeTraceFilePath.map(ServerContext.makeTraceWriter)
        
        let application = try ServerContext.makeApp(
            logger,
            database,
            traceWriter,
            globalOptions
        )
        
        let server = NIOABCIServer(application: application, logger: logger)
        try server.start(host: host, port: port)
        try server.start()
    }
}

