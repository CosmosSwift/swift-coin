import Foundation
import Database

extension KeyValueStore {
    // Iterator over all the keys with a certain prefix in ascending order
    public func prefixIterator(prefix: Data) -> Iterator {
        return iterator(start: prefix, end: prefixEndBytes(prefix: prefix))
    }
}

// prefixEndBytes returns the Data that would end a
// range query for all Data with a certain prefix
// Deals with last byte of prefix being FF without overflowing
func prefixEndBytes(prefix: Data) -> Data {
    if prefix.isEmpty {
        return Data()
    }

    var end = Data(prefix)

    while true {
        if end[end.count - 1] != 255 {
            end[end.count - 1] += 1
            break
        } else {
            end = end.dropLast(1)
                
            if end.isEmpty {
                return Data()
            }
        }
    }
    
    return end
}
