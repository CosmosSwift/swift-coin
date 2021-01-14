import Foundation

// An address is a []byte, but hex-encoded even in JSON.
// []byte leaves us the option to change the address length.
// Use an alias so Unmarshal methods (with ptr receivers) are available too.
public typealias Address = Data

public enum Crypto {
    public static func addressHash(data: Data) -> Address {
        return TMHash.sumTruncated(data: data)
    }
}

public class PublicKey: Codable, Equatable {
    public var address: Address {
        fatalError("PublicKey must be subclassed.")
    }
    
    var data: Data {
        fatalError("PublicKey must be subclassed.")
    }
    
    public func verify(message: Data, signature: Data) -> Bool {
        fatalError("PublicKey must be subclassed.")
    }
    
    public static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        lhs.data == rhs.data
    }
}

public class PrivateKey: Codable, Equatable {
    var data: Data {
        fatalError("PublicKey must be subclassed.")
    }

    public var publicKey: PublicKey {
        fatalError("PublicKey must be subclassed.")
    }
    
    init() {}
    
    public func sign(message: Data) throws -> Data {
        fatalError("PublicKey must be subclassed.")
    }
    
    public static func == (lhs: PrivateKey, rhs: PrivateKey) -> Bool {
        lhs.data == rhs.data
    }
}
