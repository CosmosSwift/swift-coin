import Foundation
import ABCI

// Querier defines a function type that a module querier must implement to handle
// custom client queries.
public typealias Querier = (_ request: Request, _ path: [String], _ requestQuery: RequestQuery) throws -> Data
