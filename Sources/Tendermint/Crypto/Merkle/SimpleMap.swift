import Foundation

// Merkle tree from a map.
// Leaves are `hash(key) | hash(value)`.
// Leaves are sorted before Merkle hashing.
struct SimpleMap {
    var keyValuePairs: KeyValuePairs
    var sorted: Bool

    init() {
        self.keyValuePairs = []
        self.sorted = false
    }
}


extension SimpleMap {
    // Set creates a kv pair of the key and the hash of the value,
    // and then appends it to simpleMap's kv pairs.
    mutating func set(key: String, value: Data) {
        sorted = false

        // The value is hashed, so you can
        // check for equality with a cached value (say)
        // and make a determination to fetch or not.
        let valueHash = Hash.sum(data: value)
        
        let pair = KeyValuePair(
            key: key.data,
            value: valueHash
        )
        
        keyValuePairs.append(pair)
    }

    // Hash Merkle root hash of items sorted by key
    // (UNSTABLE: and by value too if duplicate key).
    mutating func hash() -> Data {
        sort()
        return Self.hash(keyValuePairs: keyValuePairs)
    }

    mutating func sort() {
        guard sorted else {
            return
        }
        
        keyValuePairs.sort()
        sorted = true
    }

//    // Returns a copy of sorted KVPairs.
//    // NOTE these contain the hashed key and value.
//    func (sm *simpleMap) KVPairs() kv.Pairs {
//        sm.Sort()
//        kvs := make(kv.Pairs, len(sm.kvs))
//        copy(kvs, sm.kvs)
//        return kvs
//    }

    //----------------------------------------

    static func hash(keyValuePairs: KeyValuePairs) -> Data {
        var keyValuePairHashes: [Data] = []
        
        for keyValuePair in keyValuePairs {
            keyValuePairHashes.append(keyValuePair.data)
        }
        
        return Merkle.simpleHash(items: keyValuePairHashes)
    }
}


// A local extension to KVPair that can be hashed.
// Key and value are length prefixed and concatenated,
// then hashed.
extension KeyValuePair {
    // Bytes returns key || value, with both the
    // key and value length prefixed.
    var data: Data {
        Data(uvarint: UInt64(key.count)) +
            key +
            Data(uvarint: UInt64(value.count)) +
            value
    }
}

extension Data {
    // PutUvarint encodes a uint64 into buf and returns the number of bytes written.
    // If the buffer is too small, PutUvarint will panic.
    init(uvarint value: UInt64) {
        var data = Data()
        var value = value

        while value >= 0x80 {
            data.append(UInt8(value) | 0x80)
            value >>= 7
        }
        
        data.append(UInt8(value))
        self = data
    }
}
