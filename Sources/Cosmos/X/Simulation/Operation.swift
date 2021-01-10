import Foundation
import JSON

// Operation runs a state machine transition, and ensures the transition
// happened as expected.  The operation could be running and testing a fuzzed
// transaction, or doing the same for a message.
//
// For ease of debugging, an operation returns a descriptive message "action",
// which details what this fuzzed state machine transition actually did.
//
// Operations can optionally provide a list of "FutureOperations" to run later
// These will be ran at the beginning of the corresponding block.
public typealias Operation = (
    _ random: RandomNumber,
    _ app: BaseApp,
    _ request: Request,
    _ accounts: [Account],
    _ chainID: String
) throws -> (OperationMessage, [FutureOperation])

//_____________________________________________________________________

// OperationMsg - structure for operation output
public struct OperationMessage: Codable {
    // msg route (i.e module name)
    let route: String
    // operation name (msg Type or "no-operation")
    let name: String
    // additional comment
    let comment: String
    // success
    let ok: Bool
    // JSON encoded msg
    let message: JSON
}

//________________________________________________________________________

// FutureOperation is an operation which will be ran at the beginning of the
// provided BlockHeight. If both a BlockHeight and BlockTime are specified, it
// will use the BlockHeight. In the (likely) event that multiple operations
// are queued at the same block height, they will execute in a FIFO pattern.
public struct FutureOperation {
    let blockHeight: Int
    let blockTime: Date
    let operation: Operation
}

//________________________________________________________________________

// WeightedOperation is an operation with associated weight.
// This is used to bias the selection operation within the simulator.
struct WeightedOperation {
    let weight: Int
    let operation: Operation
}
