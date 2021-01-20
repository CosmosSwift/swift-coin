import Foundation
import Crypto

public struct Hash {
    private var sha256 = SHA256()
    
    public init() {}
    
    public mutating func write(data: Data) {
        sha256.update(data: data)
    }
    
    public mutating func sum(end: Data? = nil) -> Data {
        if let end = end {
            sha256.update(data: end)
        }
        
        return Data(sha256.finalize())
    }
}

extension Hash {
    // Sum returns the SHA256 of the bz.
    static func sum(data: Data) -> Data {
        Data(SHA256.hash(data: data))
    }

    
    private static let truncatedSize = 20

    // SumTruncated returns the first 20 bytes of SHA256 of the bz.
    public static func sumTruncated(data: Data) -> Data {
        let hash = SHA256.hash(data: data)
        return Data(hash.prefix(truncatedSize))
    }
}
