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

    // StringAttribute defines en Event object wrapper where all the attributes
    // contain key/value pairs that are strings instead of raw bytes.
struct StringEvent: Codable {
    let type: String
    let attributes: [Attribute]
}

    // StringAttributes defines a slice of StringEvents objects.
typealias StringEvents = [StringEvent]

extension StringEvents {
    var description: String {
        // TODO: Implement
        fatalError()
//        var sb strings.Builder
//
//        for _, e := range se {
//            sb.WriteString(fmt.Sprintf("\t\t- %s\n", e.Type))
//
//            for _, attr := range e.Attributes {
//                sb.WriteString(fmt.Sprintf("\t\t\t- %s\n", attr.String()))
//            }
//        }
//
//        return strings.TrimRight(sb.String(), "\n")
    }

    // Flatten returns a flattened version of StringEvents by grouping all attributes
    // per unique event type.
    func flattened() -> StringEvents {
        // TODO: Implement
        fatalError()
//        let flatEvents = make(map[string][]Attribute)
//
//        for _, e := range se {
//            flatEvents[e.Type] = append(flatEvents[e.Type], e.Attributes...)
//        }
//
//        keys := make([]string, 0, len(flatEvents))
//        res := make(StringEvents, 0, len(flatEvents)) // appeneded to keys, same length of what is allocated to keys
//
//        for ty := range flatEvents {
//            keys = append(keys, ty)
//        }
//
//        sort.Strings(keys)
//        for _, ty := range keys {
//            res = append(res, StringEvent{Type: ty, Attributes: flatEvents[ty]})
//        }
//
//        return res
    }
}

extension Event {
    // StringifyEvent converts an Event object to a StringEvent object.
    func stringify() -> StringEvent {
        // TODO: Implement
        fatalError()
//        res := StringEvent{Type: e.Type}
//
//        for _, attr := range e.Attributes {
//            res.Attributes = append(
//                res.Attributes,
//                Attribute{string(attr.Key), string(attr.Value)},
//            )
//        }
//
//        return res
    }
}

extension Events {
    // StringifyEvents converts a slice of Event objects into a slice of StringEvent
    // objects.
    func stringify() -> StringEvents {
        // TODO: Implement
        fatalError()
//        res := make(StringEvents, 0, len(events))
//
//        for _, e := range events {
//            res = append(res, StringifyEvent(e))
//        }
//
//        return res.Flatten()
    }
}
