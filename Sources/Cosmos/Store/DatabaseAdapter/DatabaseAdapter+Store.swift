import Foundation
import Database

// dbm.DB implements KVStore so we can CacheKVStore it.
// Wrapper type for dbm.Db with implementation of KVStorej
class DatabaseAdapterStore: KeyValueStore {
    var database: Database
    
    init(database: Database) {
        self.database = database
    }
    
    // Get wraps the underlying DB's Get method panicing on error.
    func get(key: Data) -> Data? {
        do {
            return try database.get(key: key)
        } catch {
            fatalError("\(error)")
        }
    }
        
    // Has wraps the underlying DB's Has method panicing on error.
    func has(key: Data) -> Bool {
        do {
            return try database.has(key: key)
        } catch {
            fatalError("\(error)")
        }
    }

    // Set wraps the underlying DB's Set method panicing on error.
    func set(key: Data, value: Data) {
        do {
            return try database.set(key: key, value: value)
        } catch {
            fatalError("\(error)")
        }
    }

    // Delete wraps the underlying DB's Delete method panicing on error.
    func delete(key: Data) {
        do {
            return try database.delete(key: key)
        } catch {
            fatalError("\(error)")
        }
    }

    // Iterator wraps the underlying DB's Iterator method panicing on error.
    func iterator(start: Data?, end: Data?) -> Iterator {
        do {
            return try database.iterator(start: start, end: end)
        } catch {
            fatalError("\(error)")
        }
    }

    // ReverseIterator wraps the underlying DB's ReverseIterator method panicing on error.
    func reverseIterator(start: Data?, end: Data?) -> Iterator {
        do {
            return try database.reverseIterator(start: start, end: end)
        } catch {
            fatalError("\(error)")
        }
    }

    // GetStoreType returns the type of the store.
    var storeType: StoreType {
        .database
    }
    
    // TODO: Implement
    // CacheWrap cache wraps the underlying store.
//    func (dsa Store) CacheWrap() types.CacheWrap {
//        return cachekv.NewStore(dsa)
//    }
//
//    // CacheWrapWithTrace implements KVStore.
//    func (dsa Store) CacheWrapWithTrace(w io.Writer, tc types.TraceContext) types.CacheWrap {
//        return cachekv.NewStore(tracekv.NewStore(dsa, w, tc))
//    }
}
