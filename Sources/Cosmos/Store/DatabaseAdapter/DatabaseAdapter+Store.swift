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
        try! database.get(key: key)
    }
        
    // Has wraps the underlying DB's Has method panicing on error.
    func has(key: Data) -> Bool {
        try! database.has(key: key)
    }

    // Set wraps the underlying DB's Set method panicing on error.
    func set(key: Data, value: Data) {
        try! database.set(key: key, value: value)
    }

    // Delete wraps the underlying DB's Delete method panicing on error.
    func delete(key: Data) {
        try! database.delete(key: key)
    }

    // Iterator wraps the underlying DB's Iterator method panicing on error.
    func iterator(start: Data?, end: Data?) -> Iterator {
        try! database.iterator(start: start, end: end)
    }

    // ReverseIterator wraps the underlying DB's ReverseIterator method panicing on error.
    func reverseIterator(start: Data?, end: Data?) -> Iterator {
        try! database.reverseIterator(start: start, end: end)
    }

    // GetStoreType returns the type of the store.
    var storeType: StoreType {
        .database
    }
    
    // CacheWrap cache wraps the underlying store.
    var cacheWrap: CacheWrap {
        BaseCacheKeyValueStore(parent: self)
    }
    
    // CacheWrapWithTrace implements KVStore.
    func cacheWrapWithTrace(writer: Writer, traceContext: TraceContext) -> CacheWrap {
        // TODO: Implement
        fatalError()
//        let parent = TraceKeyValueStore(
//            store: self,
//            writer: writer,
//            traceContext: traceContext
//        )
//
//        return BaseCacheKeyValueStore(parent: parent)
    }
}
