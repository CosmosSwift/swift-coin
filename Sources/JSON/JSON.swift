import Foundation

public enum JSON : Codable {
    case null
    case boolean(Bool)
    case integer(Int)
    case double(Double)
    case string(String)
    case array([JSON])
    case object([String: JSON])
    
    public var value: Any? {
        switch self {
        case .null:
            return nil
        case .boolean(let boolean):
            return boolean
        case .integer(let integer):
            return integer
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .array(let array):
            return array.map({ $0.value })
        case .object(let dictionary):
            return dictionary.mapValues({ $0.value })
        }
    }
    
    public init?(_ value: Any?) {
        guard let value = value else {
            self = .null
            return
        }
        
        if let boolean = value as? Bool {
            self = .boolean(boolean)
        } else if let integer = value as? Int {
            self = .integer(integer)
        } else if let double = value as? Double {
            self = .double(double)
        } else if let string = value as? String {
            self = .string(string)
        } else if let array = value as? [Any] {
            var mapped: [JSON] = []
            
            for inner in array {
                guard let inner = JSON(inner) else {
                    return nil
                }
                
                mapped.append(inner)
            }
            
            self = .array(mapped)
        } else if let dictionary = value as? [String : Any] {
            var mapped: [String: JSON] = [:]
            
            for (key, inner) in dictionary {
                guard let inner = JSON(inner) else {
                    return nil
                }
                
                mapped[key] = inner
            }
            
            self = .object(mapped)
        } else {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        guard !container.decodeNil() else {
            self = .null
            return
        }
        
        if let boolean = try container.decodeIfMatched(Bool.self) {
            self = .boolean(boolean)
        } else if let integer = try container.decodeIfMatched(Int.self) {
            self = .integer(integer)
        } else if let integer = try container.decodeIfMatched(Int32.self) {
            self = .integer(Int(integer))
        } else if let integer = try container.decodeIfMatched(Int64.self) {
            self = .integer(Int(integer))
        } else if let integer = try container.decodeIfMatched(UInt.self) {
            self = .integer(Int(integer))
        } else if let integer = try container.decodeIfMatched(UInt32.self) {
            self = .integer(Int(integer))
        } else if let integer = try container.decodeIfMatched(UInt64.self) {
            self = .integer(Int(integer))
        } else if let double = try container.decodeIfMatched(Double.self) {
            self = .double(double)
        } else if let string = try container.decodeIfMatched(String.self) {
            self = .string(string)
        } else if let array = try container.decodeIfMatched([JSON].self) {
            self = .array(array)
        } else if let dictionary = try container.decodeIfMatched([String: JSON].self) {
            self = .object(dictionary)
        } else {
            throw DecodingError.typeMismatch(
                JSON.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode JSON as any of the possible types."
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
            case .null:
                try container.encodeNil()
            case .boolean(let boolean):
                try container.encode(boolean)
            case .integer(let integer):
                try container.encode(integer)
            case .double(let double):
                try container.encode(double)
            case .string(let string):
                try container.encode(string)
            case .array(let array):
                try container.encode(array)
            case .object(let dictionary):
                try container.encode(dictionary)
        }
    }
}

fileprivate extension SingleValueDecodingContainer {
    func decodeIfMatched<T : Decodable>(_ type: T.Type) throws -> T? {
        do {
            return try self.decode(T.self)
        } catch DecodingError.typeMismatch {
            return nil
        }
    }
}
