public protocol ProtocolCodable: Codable {
    static var metaType: MetaType { get }
}

public extension ProtocolCodable {
    static func metaType(key: String) -> MetaType {
        MetaType(type: self, key: key)
    }
    
    static func registerMetaType() {
        _ = metaType
    }
}

public struct MetaType: Codable {
    private static var table: [String: ProtocolCodable.Type] = [:]
    
    public let key: String
    public let type: ProtocolCodable.Type
    
    fileprivate init(type: ProtocolCodable.Type) {
        self.key = ""
        self.type = type
    }
    
    fileprivate init(type: ProtocolCodable.Type, key: String) {
        self.type = type
        self.key = key
        
        if let existingType = Self.table[key] {
            fatalError("Failed to register type '\(type)' for key '\(key)'.\nType '\(existingType)' is already registered with that key.")
        }
        
        Self.table[key] = type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.key = try container.decode(String.self)
        
        guard let type = Self.table[key] else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "No type registered for key '\(key)'"
            )
        }
        
        self.type = type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(key)
    }
}

public struct AnyProtocolCodable: ProtocolCodable {
    public static let metaType = MetaType(type: Self.self)
    public let value: ProtocolCodable
    
    public init(_ value: ProtocolCodable) {
        self.value = value
    }
    
    private enum CodingKeys : CodingKey {
        case type
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metaType = try container.decode(MetaType.self, forKey: .type)
        self.value = try metaType.type.init(from: container.superDecoder(forKey: .value))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Swift.type(of: value).metaType, forKey: .type)
        try value.encode(to: container.superEncoder(forKey: .value))
    }
}
