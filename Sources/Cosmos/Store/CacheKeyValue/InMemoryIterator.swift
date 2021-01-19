import Foundation
import Tendermint
import Database

// Iterates over iterKVCache items.
// if key is nil, means it was deleted.
// Implements Iterator.
struct InMemoryIterator: Iterator {
    let start: Data
    let end: Data
    var iterator: AnyIterator<KeyValuePair>?
    var pair: KeyValuePair?

    init(
        start: Data,
        end: Data,
        items: [KeyValuePair],
        ascending: Bool
    ) {
        var itemsInDomain: [KeyValuePair] = []
        var entered = false

        for item in items {
            if !isKeyInDomain(key: item.key, start: start, end: end) {
                if entered {
                    break
                }
                
                continue
            }
            
            itemsInDomain.append(item)
            entered = true
        }
        
        self.start = start
        self.end = end
        
        self.iterator = AnyIterator(
            ascending ?
            itemsInDomain.makeIterator() :
            itemsInDomain.reversed().makeIterator()
        )
    }
}

extension InMemoryIterator {
    var domain: (start: Data, end: Data) {
        (start, end)
    }

    var isValid: Bool {
        iterator != nil
    }

    private func assertValid() {
        if let error = self.error {
            fatalError("\(error)")
        }
    }

    mutating func next() {
        assertValid()
        
        guard let pair = iterator?.next() else {
            return self.iterator = nil
        }
        
        self.pair = pair
    }

    var key: Data {
        assertValid()
        return pair!.key
    }

    var value: Data {
        assertValid()
        return pair!.value!
    }

    mutating func close() {
        iterator = nil
    }

    // Error returns an error if the memIterator is invalid defined by the Valid
    // method.
    var error: Swift.Error? {
        guard isValid else {
            struct InMemoryIteratorError: Swift.Error, CustomStringConvertible {
                var description: String
            }
            
            return InMemoryIteratorError(description: "invalid memIterator")
        }

        return nil
    }
}
