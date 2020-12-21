import Logging

extension Logger {
    init(label: String, level: Level) {
        self.init(label: label) { label in
            var handler = StreamLogHandler.standardOutput(label: label)
            handler.logLevel = level
            return handler
        }
    }
}

extension Logger.Level : LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(rawValue: description)
    }
    
    public var description: String {
        rawValue
    }
}
