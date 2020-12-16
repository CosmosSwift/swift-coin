import Foundation
import Crypto

enum TMHash {
    private static let truncatedSize = 20

    // SumTruncated returns the first 20 bytes of SHA256 of the bz.
    public static func sumTruncated(data: Data) -> Data {
        let hash = SHA256.hash(data: data)
        return Data(hash.prefix(truncatedSize))
    }
}
