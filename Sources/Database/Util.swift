import Foundation

extension Data {
    // Returns a slice of the same length (big endian)
    // except incremented by one.
    // Returns nil on overflow (e.g. if bz bytes are all 0xFF)
    // CONTRACT: len(bz) > 0
    func incremented() -> Data {
        guard !isEmpty else {
            fatalError("cpIncr expects non-zero bz length")
        }
        
        var ret = self
        
        for i in self.indices.reversed() {
            if ret[i] < 0xFF {
                ret[i] += 1
                return ret
            }
            
            ret[i] = 0x00
            
            // Overflow
            if i == 0 {
                return Data()
            }
        }
        
        return Data()
    }
}

// See DB interface documentation for more information.
public func isKeyInDomain(key: Data, start: Data?, end: Data?) -> Bool {
    if key < start ?? Data() {
        return false
    }
    
    if let end = end, end <= key {
        return false
    }
    
    return true
}

extension Data: Comparable {
    public static func < (lhs: Data, rhs: Data) -> Bool {
        lhs.lexicographicallyPrecedes(rhs)
    }
}
