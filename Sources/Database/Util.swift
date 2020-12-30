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
