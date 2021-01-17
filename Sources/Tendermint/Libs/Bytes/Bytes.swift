import Foundation

// The main purpose of HexBytes is to enable HEX-encoding for json/encoding.
public struct HexadecimalData: RawRepresentable, Codable {
    public var rawValue: Data
    
    public init?(rawValue: Data) {
        self.rawValue = rawValue
    }
    
    public init(_ data: Data) {
        self.rawValue = data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexEncoded = try container.decode(String.self)
        
        guard let data = Data(hexEncoded: hexEncoded) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Could not decoded hex encoded string \(hexEncoded)"
            )
        }
        
        self.rawValue = data
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue.hexEncodedString(options: .upperCase))
    }
    
    public var isEmpty: Bool {
        rawValue.isEmpty
    }
}
