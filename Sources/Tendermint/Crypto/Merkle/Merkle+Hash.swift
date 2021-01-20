import Foundation

extension Merkle {
    // TODO: make these have a large predefined capacity
    static let leafPrefix  = Data([0])
    static let innerPrefix = Data([1])

    // returns tmhash(0x00 || leaf)
    static func leafHash(leaf: Data) -> Data {
        Hash.sum(data: leafPrefix + leaf)
    }

    // returns tmhash(0x01 || left || right)
    static func innerHash(left: Data, right: Data) -> Data {
        Hash.sum(data: innerPrefix + left + right)
    }
}
