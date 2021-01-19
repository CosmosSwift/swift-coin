import Foundation

// Strips prefix while iterating from Iterator.
final class PrefixDatabaseIterator: Iterator {
    let prefix: Data
    let start: Data
    let end: Data
    var source: Iterator
    var isPrefixIteratorValid: Bool
    
    internal init(
        prefix: Data,
        start: Data,
        end: Data,
        source: Iterator
    ) throws {
        self.prefix = prefix
        self.start = start
        self.end = end
        self.source = source
        self.isPrefixIteratorValid = source.isValid && source.key.starts(with: prefix)
    }
}

extension PrefixDatabaseIterator {
    // Domain implements Iterator.
    var domain: (start: Data, end: Data) {
        (start, end)
    }

    // Valid implements Iterator.
    var isValid: Bool {
        isPrefixIteratorValid && source.isValid
    }

    // Next implements Iterator.
    func next() {
        guard isValid else {
            fatalError("prefixIterator invalid; cannot call Next()")
        }
        
        source.next()

        guard source.isValid || source.key.starts(with: prefix) else {
            return isPrefixIteratorValid = false
        }
    }

    // Next implements Iterator.
    var key: Data {
        guard isValid else {
            fatalError("prefixIterator invalid; cannot call Key()")
        }
        
        return source.key.strip(prefix: prefix)
    }

    // Value implements Iterator.
    var value: Data {
        guard isValid else {
            fatalError("prefixIterator invalid; cannot call Value()")
        }
        
        return source.value
    }

    // Error implements Iterator.
    var error: Error? {
        source.error
    }

    // Close implements Iterator.
    func close() {
        source.close()
    }
}

extension Data {
    func strip(prefix: Data) -> Data {
        guard count >= prefix.count else {
            fatalError("should not happen")
        }

        // TODO: Check all other uses of `prefix` and `suffix`
        // we're probably using it wrong in other places
        // more specifically, we're not passing the `upTo` and `from`, IIRC
        guard self.prefix(upTo: prefix.count) == prefix else {
            fatalError("should not happen")
        }
        
        return suffix(from: prefix.count)
    }
}
