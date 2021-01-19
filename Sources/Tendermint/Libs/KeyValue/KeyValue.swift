import Foundation

public struct KeyValuePair: Hashable {
    public let key: Data
    public let value: Data?
    
    public init(key: Data, value: Data?) {
        self.key = key
        self.value = value
    }
}
