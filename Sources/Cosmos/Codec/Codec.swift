import Foundation

public class Codec {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    public init() {}
    
    func marshalJSON<T: Encodable>(value: T) throws -> Data {
        try encoder.encode(value)
    }

    // MustMarshalJSON panics if an error occurs. Besides tha behaves exactly like MarshalJSON.
    public func mustMarshalJSON<T: Encodable>(value: T) -> Data {
        do {
            return try marshalJSON(value: value)
        } catch {
            fatalError("\(error)")
        }
    }

    public func mustMarshalBinaryLengthPrefixed<T: Encodable>(value: T) throws -> Data {
        try encoder.encode(value)
    }
    
    // Like UnmarshalBinaryBare, but will first decode the byte-length prefix.
    // UnmarshalBinaryLengthPrefixed will panic if ptr is a nil-pointer.
    // Returns an error if not all of bz is consumed.
    public func unmarshalBinaryLengthPrefixed<T: Decodable>(data: Data) throws -> T {
        if data.isEmpty {
            throw Cosmos.Error.decodingError(reason: "UnmarshalBinaryLengthPrefixed cannot decode empty bytes")
        }

        // Read byte-length prefix.
        let (u64, n) = data.uvarint()
        
        if n < 0 {
            throw Cosmos.Error.decodingError(reason: "Error reading msg byte-length prefix: got code \(n)")
        }
        
        if u64 > UInt64(data.count - n) {
            throw Cosmos.Error.decodingError(reason: "Not enough bytes to read in UnmarshalBinaryLengthPrefixed, want \(u64) more bytes but only have \(data.count - n)")
        } else if u64 < UInt64(data.count - n) {
            throw Cosmos.Error.decodingError(reason: "Bytes left over in UnmarshalBinaryLengthPrefixed, should read \(u64) more bytes but have \(data.count - n)")
        }
        
        let data = data.prefix(n)

        // Decode.
        return try unmarshalBinaryBare(data: data)
    }
    
    public func unmarshalJSON<T: Decodable>(data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }
    
    public func mustUnmarshalJSON<T: Decodable>(data: Data) -> T {
        do {
           return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("\(error)")
        }
    }
    
    // UnmarshalBinaryBare will panic if ptr is a nil-pointer.
    public func unmarshalBinaryBare<T: Decodable>(data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }
    
    // attempt to make some pretty json
    public func marshalJSONIndent<T: Encodable>(value: T) throws -> Data {
        try encoder.encode(value)
    }
    
    // Panics if error.
    public func mustUnmarshalBinaryLength<T: Decodable>(data: Data) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("\(error)")
        }
    }
    
    // MustMarshalJSONIndent executes MarshalJSONIndent except it fatal errors upon failure.
    public func mustMarshalJSONIndent<T: Encodable>(value: T) -> Data {
        do {
            return try marshalJSONIndent(value: value)
        } catch {
            fatalError("failed to marshal JSON: \(error)")
        }
    }

}

extension Data {
    // uvarint decodes a uint64 from buf and returns that value and the
    // number of bytes read (> 0). If an error occurred, the value is 0
    // and the number of bytes n is <= 0 meaning:
    //
    //     n == 0: buf too small
    //     n  < 0: value larger than 64 bits (overflow)
    //             and -n is the number of bytes read
    //
    func uvarint() -> (UInt64, Int) {
        var x: UInt64 = 0
        var s: UInt = 0
        
        for (i, b) in self.enumerated() {
            if b < 0x80 {
                if i > 9 || i == 9 && b > 1 {
                    return (0, -(i + 1)) // overflow
                }
                return (x | UInt64(b) << s, i + 1)
            }
            
            x |= UInt64(b & 0x7f) << s
            s += 7
        }
        
        return (0, 0)
    }
}
