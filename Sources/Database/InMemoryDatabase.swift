import Foundation

// MemDB is an in-memory database backend using a B-tree for storage.
public final class InMemoryDatabase: Database {
    internal var items: [Data: Data] = [:]

    // NewMemDB creates a new in-memory database.
    public init() {}

    // Get implements DB.
    public func get(key: Data) throws -> Data? {
        items[key]
    }
    
    // Has implements DB.
    public func has(key: Data) throws -> Bool {
        items[key] != nil
    }

    // Set implements DB.
    public func set(key: Data, value: Data) throws {
        items[key] = value
    }

    // SetSync implements DB.
    public func setSync(key: Data, value: Data) throws {
        items[key] = value
    }

    // Delete implements DB.
    public func delete(key: Data) throws {
        items[key] = nil
    }
    
    // DeleteSync implements DB.
    public func deleteSync(key: Data) throws {
        items[key] = nil
    }

    // Close implements DB.
    public func close() throws {
        // Close is a noop since for an in-memory database, we don't have a destination to flush
        // contents to nor do we want any data loss on invoking Close().
        // See the discussion in https://github.com/tendermint/tendermint/libs/pull/56
    }

    // Print implements DB.
    public func print() throws {
        for (key, value) in items {
            Swift.print("[\(key)]:\t[\(value)]\n")
        }
    }

    // Stats implements DB.
    public func stats() -> [String : String] {
        [
            "database.type": "in-memory-database",
            "database.size": "\(items.count)",
        ]
    }

    // NewBatch implements DB.
    public func makeBatch() -> Batch {
        // TODO: Implement
//        return newMemDBBatch(db)
        fatalError()
    }

    // Iterator implements DB.
    // Takes out a read-lock on the database until the iterator is closed.
    public func iterator(start: Data, end: Data) throws -> Iterator {
        InMemoryDatabaseIterator(
            database: self,
            start: start,
            end: end,
            reverse: false
        )
    }

    // ReverseIterator implements DB.
    // Takes out a read-lock on the database until the iterator is closed.
    public func reverseIterator(start: Data, end: Data) throws -> Iterator {
        // TODO: Implement
//        return newMemDBIterator(db, start, end, true);, nil
        InMemoryDatabaseIterator(
            database: self,
            start: start,
            end: end,
            reverse: true
        )
    }
}
