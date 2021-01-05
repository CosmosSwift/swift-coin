import Foundation

// GasInfo defines tx execution gas context.
struct GasInfo: Codable {
    // GasWanted is the maximum units of work we allow this tx to perform.
    let gasWanted: UInt64

    // GasUsed is the amount of gas actually consumed.
    let gasUsed: UInt64
    
    internal init(gasWanted: UInt64 = 0, gasUsed: UInt64 = 0) {
        self.gasWanted = gasWanted
        self.gasUsed = gasUsed
    }
}

// Result is the union of ResponseFormat and ResponseCheckTx.
public struct Result: Codable {
    // Data is any data returned from message or handler execution. It MUST be length
    // prefixed in order to separate data from multiple message executions.
    let data: Data

    // Log contains the log information from message or handler execution.
    let log: String

    // Events contains a slice of Event objects that were emitted during message or
    // handler execution.
    let events: Events
    
    public init(
        data: Data = Data(),
        log: String = "",
        events: Events = []
    ) {
        self.data = data
        self.log = log
        self.events = events
    }
}

// SimulationResponse defines the response generated when a transaction is successfully
// simulated by the Baseapp.
struct SimulationResponse: Codable {
    let gasInfo: GasInfo
    let result: Result
}

// ABCIMessageLogs represents a slice of ABCIMessageLog.
typealias ABCIMessageLogs = [ABCIMessageLog]

// ABCIMessageLog defines a structure containing an indexed tx ABCI message log.
struct ABCIMessageLog: Codable, CustomStringConvertible {
    let messageIndex: UInt16
    let log: String

    // Events contains a slice of Event objects that were emitted during some
    // execution.
    let events: StringEvents
    
    internal init(messageIndex: UInt16, log: String, events: Events) {
        self.messageIndex = messageIndex
        self.log = log
        self.events = events.stringify()
    }
    
    // String implements the fmt.Stringer interface for the ABCIMessageLogs type.
    var description: String {
        // TODO: Implement
        fatalError()
//        if logs != nil {
//            raw, err := codec.Cdc.MarshalJSON(logs)
//            if err == nil {
//                str = string(raw)
//            }
//        }
//
//        return str
    }
}
