import Cosmos

// bank module event types
extension EventType {
    static let transfer = "transfer"
}

extension AttributeKey {
    static let recipient = "recipient"
}

extension AttributeValue {
    static let category = BankKeys.moduleName
}

