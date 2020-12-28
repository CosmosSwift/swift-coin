import Foundation
import ABCI

// ----------------------------------------------------------------------------
// Event Manager
// ----------------------------------------------------------------------------

// EventManager implements a simple wrapper around a slice of Event objects that
// can be emitted from.
public final class EventManager {
    var events: Events
    
    public init() {
        self.events = []
    }
}

extension EventManager {
    // EmitEvent stores a single Event object.
    func emit(event: Event) {
        events.append(event)
    }

    // EmitEvents stores a series of Event objects.
    func emit(events: Events) {
        self.events.append(contentsOf: events)
    }
}

// ----------------------------------------------------------------------------
// Events
// ----------------------------------------------------------------------------

// Event is a type alias for an ABCI Event
public typealias Event = ABCI.Event

extension ABCI.Event {
    init(type: String, attributes: [Attribute]) {
        self.init(
            type: type,
            attributes: attributes.map(EventAttribute.init)
        )
    }
}

    // Attribute defines an attribute wrapper where the key and value are
    // strings instead of raw bytes.
public struct Attribute: Codable {
    let key: String
    let value: String?
}

extension EventAttribute {
    init(_ attribute: Attribute) {
        self.init(
            key: attribute.key.data,
            value: attribute.value?.data ?? Data()
        )
    }
}

// Events defines a slice of Event objects
public typealias Events = [Event]

// Common event types and attribute keys
enum EventType {
    static let message = "message"
}

enum AttributeKey {
    static let action = "action"
    static let module = "module"
    static let sender = "sender"
    static let amount = "amount"
}

enum AttributeValue {}
