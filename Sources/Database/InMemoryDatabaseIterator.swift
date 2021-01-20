import Foundation

// memDBIterator is a memDB iterator.
struct InMemoryDatabaseIterator: Iterator  {
    var iterator: AnyIterator<(key: Data, value: Data)>?
    var item: (key: Data, value: Data)?
    let start: Data
    let end: Data

    // newMemDBIterator creates a new memDBIterator.
    init(
        database: InMemoryDatabase,
        start: Data,
        end: Data,
        reverse: Bool
    ) {
        self.start = start
        self.end = end
        
        // TODO: We ignore reverse here because
        // Swift dictionaries don't guarantee any ordering
        let iterator = database.items
            .filter {
                if !start.isEmpty {
                    return $0.key.starts(with: start)
                }
                
                return true
            }
            .sorted { lhs, rhs in
                lhs.key.lexicographicallyPrecedes(rhs.key)
            }
            .makeIterator()
        
        if reverse {
            self.iterator = AnyIterator(iterator.reversed().makeIterator())
        } else {
            self.iterator = AnyIterator(iterator)
        }

        // prime the iterator with the first value, if any
        self.next()
    }
}

extension InMemoryDatabaseIterator {
    // Close implements Iterator.
    mutating func close() {
        iterator = nil
    }

    // Domain implements Iterator.
    var domain: (start: Data, end: Data) {
        (start, end)
    }

    // Valid implements Iterator.
    var isValid: Bool {
        iterator != nil
    }

    // Next implements Iterator.
    mutating func next() {
        guard var iterator = self.iterator else {
            fatalError("called next() on invalid iterator")
        }
        
        guard let item = iterator.next() else {
            return close()
        }
        
        self.item = item
    }

    // Error implements Iterator.
    var error: Error? {
        nil // famous last words
    }

    // Key implements Iterator.
    var key: Data {
        guard let item = self.item else {
            fatalError("called key on invalid iterator")
        }
        
        return item.key
    }

    // Value implements Iterator.
    var value: Data {
        guard let item = self.item else {
            fatalError("called value on invalid iterator")
        }
        
        return item.value
    }
}
