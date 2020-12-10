import ABCI

// ----------------------------------------------------------------------------
// Event Manager
// ----------------------------------------------------------------------------

// EventManager implements a simple wrapper around a slice of Event objects that
// can be emitted from.
public struct EventManager {
    let events: Events
    
    public init() {
        self.events = []
    }
}

// ----------------------------------------------------------------------------
// Events
// ----------------------------------------------------------------------------

// Event is a type alias for an ABCI Event
public typealias Event = ABCI.Event

    // Attribute defines an attribute wrapper where the key and value are
    // strings instead of raw bytes.
public struct Attribute: Codable {
    let key: String
    let value: String?
}

// Events defines a slice of Event objects
public typealias Events = [Event]
