import Foundation

public enum Merkle {
    // SimpleHashFromByteSlices computes a Merkle tree where the leaves are the byte slice,
    // in the provided order.
    static func simpleHash(items: [Data]) -> Data {
        switch items.count {
        case 0:
            return Data()
        case 1:
            return leafHash(leaf: items[0])
        default:
            let splitPoint = getSplitPoint(count: items.count)
            let left = simpleHash(items: Array(items.prefix(upTo: splitPoint)))
            let right = simpleHash(items: Array(items.suffix(from: splitPoint)))
            return innerHash(left: left, right: right)
        }
    }

    // SimpleHashFromMap computes a Merkle tree from sorted map.
    // Like calling SimpleHashFromHashers with
    // `item = []byte(Hash(key) | Hash(value))`,
    // sorted by `item`.
    public static func simpleHash(map: [String: Data]) -> Data {
        var simpleMap = SimpleMap()
        
        for (key, value) in map {
            simpleMap.set(key: key, value: value)
        }
        
        return simpleMap.hash()
    }
    
    // getSplitPoint returns the largest power of 2 less than length
    static func getSplitPoint(count: Int) -> Int {
        if count < 1 {
            fatalError("Trying to split a tree with size < 1")
        }
        
        // TODO: Check if this is correct
        let unsignedBitWidth = UInt(count).bitWidth
        var splitPoint = 1 << UInt(unsignedBitWidth - 1)
        
        if splitPoint == count {
            splitPoint >>= 1
        }
        
        return splitPoint
    }
}
