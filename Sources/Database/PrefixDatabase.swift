import Foundation

// PrefixDB wraps a namespace of another database as a logical database.
public final class PrefixDatabase: Database {
    let prefix: Data
    let database: Database
    
    // NewPrefixDB lets you namespace multiple DBs within a single DB.
    public init(prefix: Data, database: Database) {
        self.prefix = prefix
        self.database = database
    }
}

extension PrefixDatabase {
    // Get implements DB.
    public func get(key: Data) throws -> Data? {
        let prefixedKey = prefixed(key: key)
        return try database.get(key: prefixedKey)
    }

    // Has implements DB.
    public func has(key: Data) throws -> Bool {
        let prefixedKey = prefixed(key: key)
        return try database.has(key: prefixedKey)
    }

    // Set implements DB.
    public func set(key: Data, value: Data) throws {
        let prefixedKey = prefixed(key: key)
        return try database.set(key: prefixedKey, value: value)
    }

    // SetSync implements DB.
    public func setSync(key: Data, value: Data) throws {
        let prefixedKey = prefixed(key: key)
        return try database.setSync(key: prefixedKey, value: value)
    }

    // Delete implements DB.
    public func delete(key: Data) throws {
        let prefixedKey = prefixed(key: key)
        return try database.delete(key: prefixedKey)
    }
    
    // DeleteSync implements DB.
    public func deleteSync(key: Data) throws {
        let prefixedKey = prefixed(key: key)
        return try database.deleteSync(key: prefixedKey)
    }

    // Iterator implements DB.
    public func iterator(start: Data, end: Data) throws -> Iterator {
        let prefixedStart = prefix + start
        var prefixedEnd: Data
        
        if !end.isEmpty {
            prefixedEnd = prefix + end
        } else {
            prefixedEnd = prefix.incremented()
        }
       
        let iterator = try database.iterator(
            start: prefixedStart,
            end: prefixedEnd
        )

        return try PrefixDatabaseIterator(
            prefix: prefix,
            start: prefixedStart,
            end: prefixedEnd,
            source: iterator
        )
    }

    // ReverseIterator implements DB.
    public func reverseIterator(start: Data, end: Data) throws -> Iterator {
        let prefixedStart = prefix + start
        var prefixedEnd: Data
        
        if !end.isEmpty {
            prefixedEnd = prefix + end
        } else {
            prefixedEnd = prefix.incremented()
        }
       
        let reverseIterator = try database.reverseIterator(
            start: prefixedStart,
            end: prefixedEnd
        )

        return try PrefixDatabaseIterator(
            prefix: prefix,
            start: prefixedStart,
            end: prefixedEnd,
            source: reverseIterator
        )
    }

    // NewBatch implements DB.
    public func makeBatch() -> Batch {
        PrefixDatabaseBatch(
            prefix: prefix,
            source: database.makeBatch()
        )
    }

    // Close implements DB.
    public func close() throws {
        try database.close()
    }

    // Print implements DB.
    public func print() throws {
       // TODO: Implement
        fatalError()
//        fmt.Printf("prefix: %X\n", pdb.prefix)
//
//        itr, err := pdb.Iterator(nil, nil)
//        if err != nil {
//            return err
//        }
//        defer itr.Close()
//        for ; itr.Valid(); itr.Next() {
//            key := itr.Key()
//            value := itr.Value()
//            fmt.Printf("[%X]:\t[%X]\n", key, value)
//        }
//        return nil
    }

    // Stats implements DB.
    public func stats() -> [String : String] {
        // TODO: Implement
        fatalError()
//        stats := make(map[string]string)
//        stats["prefixdb.prefix.string"] = string(pdb.prefix)
//        stats["prefixdb.prefix.hex"] = fmt.Sprintf("%X", pdb.prefix)
//        source := pdb.db.Stats()
//        for key, value := range source {
//            stats["prefixdb.source."+key] = value
//        }
//        return stats
    }

    private func prefixed(key: Data) -> Data {
        prefix + key
    }
}
