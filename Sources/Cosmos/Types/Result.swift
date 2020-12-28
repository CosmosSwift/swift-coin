import Foundation

// Result is the union of ResponseFormat and ResponseCheckTx.
public struct Result {
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
