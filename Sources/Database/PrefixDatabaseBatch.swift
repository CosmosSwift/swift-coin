import Foundation

final class PrefixDatabaseBatch: Batch {
    let prefix: Data
    let source: Batch
    
    internal init(prefix: Data, source: Batch) {
        self.prefix = prefix
        self.source = source
    }
}

extension PrefixDatabaseBatch {
    // Set implements Batch.
    func set(key: Data, value: Data) {
        let prefixedKey = prefixed(key: key)
        return source.set(key: prefixedKey, value: value)
    }

    // Delete implements Batch.
    func delete(key: Data) {
        let prefixedKey = prefixed(key: key)
        return source.delete(key: prefixedKey)
    }

    // Write implements Batch.
    func write() throws {
        try source.write()
    }

    // WriteSync implements Batch.
    func writeSync() throws {
        try source.writeSync()
    }

    // Close implements Batch.
    func close() {
        source.close()
    }

    private func prefixed(key: Data) -> Data {
        prefix + key
    }
}
