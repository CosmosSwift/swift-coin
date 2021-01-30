import Foundation
import JSON
import Logging
import Tendermint
import ABCI
import Database

// AppCreator is a function that allows us to lazily initialize an
// application using various configurations.
public typealias MakeApp = (
    _ logger: Logger,
    _ database: Database,
    _ writer: Writer?,
    _ globalOptions: ServerOptions
) throws -> ABCIApplication

public typealias ExportApp = (
    _ logger: Logger,
    _ database: Database,
    _ traceStore: Writer?,
    _ height: Int64,
    _ forZeroHeight: Bool,
    _ jailWhiteList: [String]
) throws -> (JSON, [GenesisValidator])

extension ServerContext {
    public static func makeDatabase(path: String) throws -> Database {
        // TODO: Swap for a persistent database
//        let url = URL(fileURLWithPath: path).appendingPathComponent("data")
        return InMemoryDatabase()
    }

    public static func makeTraceWriter(path: String) throws -> Writer {
        try FileWriter(path: path)
    }
}
