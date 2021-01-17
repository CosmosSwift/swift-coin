import Foundation
import Database

// If value is nil but deleted is false, it means the parent doesn't have the
// key.  (No need to delete upon Write())
struct CacheValue {
    let value: Data?
    let deleted: Bool
    let dirty: Bool
}

// Store wraps an in-memory cache around an underlying types.KVStore.
final class BaseCacheKeyValueStore: CacheKeyValueStore {
    var cache: [String: CacheValue]
    var unsortedCache: [String: Bool]
    // always ascending sorted
    var sortedCache: [Any]
    let parent: KeyValueStore
    
    internal init(parent: KeyValueStore) {
        self.cache = [:]
        self.unsortedCache = [:]
        self.sortedCache = []
        self.parent = parent
    }
}

extension BaseCacheKeyValueStore {
    // Implements Store.
    var storeType: StoreType {
        parent.storeType
    }

    // Implements types.KVStore.
    func get(key: Data) -> Data? {
        let value: Data?
        
        if let cacheValue = cache[key.hexEncodedString()] {
            value = cacheValue.value
        } else {
            value = parent.get(key: key)
           
            setCacheValue(
                key: key,
                value: value,
                deleted: false,
                dirty: false
            )
        }

        return value
    }

    // Implements types.KVStore.
    func set(key: Data, value: Data) {
        setCacheValue(
            key: key,
            value: value,
            deleted: false,
            dirty: true
        )
    }

    // Implements types.KVStore.
    func has(key: Data) -> Bool {
        get(key: key) != nil
    }

    // Implements types.KVStore.
    func delete(key: Data) {
        setCacheValue(
            key: key,
            value: nil,
            deleted: true,
            dirty: true
        )
    }

    // Implements Cachetypes.KVStore.
    func write() {
        // We need a copy of all of the keys.
        // Not the best, but probably not a bottleneck depending.
        var keys: [String] = []
        
        for (key, databaseValue) in cache {
            if databaseValue.dirty {
                keys.append(key)
            }
        }

        keys.sort()

        // TODO: Consider allowing usage of Batch, which would allow the write to
        // at least happen atomically.
        for key in keys {
            guard let cacheValue = cache[key] else {
                fatalError("Should not happen")
            }
            
            if cacheValue.deleted {
                parent.delete(key: key.data)
            } else if let value = cacheValue.value {
                parent.set(key: key.data, value: value)
            } else {
                // Skip, it already doesn't exist in parent.
                continue
            }
        }

        // Clear the cache
        cache = [:]
        unsortedCache = [:]
        sortedCache = []
    }

    //----------------------------------------
    // To cache-wrap this Store further.

    // Implements CacheWrapper.
    var cacheWrap: CacheWrap {
        BaseCacheKeyValueStore(parent: self)
    }

    // CacheWrapWithTrace implements the CacheWrapper interface.
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

    //----------------------------------------
    // Iteration

    // Implements types.KVStore.
    func iterator(start: Data?, end: Data?) -> Iterator {
        iterator(start: start, end: end, ascending: true)
    }

    // Implements types.KVStore.
    func reverseIterator(start: Data?, end: Data?) -> Iterator {
        iterator(start: start, end: end, ascending: false)
    }

    func iterator(start: Data?, end: Data?, ascending: Bool) -> Iterator {
        let parent: Iterator

        if ascending {
            parent = self.parent.iterator(start: start, end: end)
        } else {
            parent = self.parent.reverseIterator(start: start, end: end)
        }

        dirtyItems(start: start, end: end)
        
        // TODO: Implement
        fatalError()
//        let cache = InMemoryIterator(
//            start: start,
//            end: end,
//            store.sortedCache,
//            ascending
//        )
//
//        return CacheMergeIterator(
//            parent: parent,
//            cache: cache,
//            ascending: ascending
//        )
    }

    // Constructs a slice of dirty items, to use w/ memIterator.
    func dirtyItems(start: Data?, end: Data?) {
        // TODO: Implement
        fatalError()
//        var unsorted: [KeyValuePair] = []
//
//        for key in unsortedCache {
//            cacheValue = cache[key]
//
//            if dbm.IsKeyInDomain([]byte(key), start, end) {
//                unsorted = append(unsorted, &tmkv.Pair{Key: []byte(key), Value: cacheValue.value})
//                delete(store.unsortedCache, key)
//            }
//        }
//
//        sort.Slice(unsorted, func(i, j int) bool {
//            return bytes.Compare(unsorted[i].Key, unsorted[j].Key) < 0
//        })
//
//        for e := store.sortedCache.Front(); e != nil && len(unsorted) != 0; {
//            uitem := unsorted[0]
//            sitem := e.Value.(*tmkv.Pair)
//            comp := bytes.Compare(uitem.Key, sitem.Key)
//            switch comp {
//            case -1:
//                unsorted = unsorted[1:]
//                store.sortedCache.InsertBefore(uitem, e)
//            case 1:
//                e = e.Next()
//            case 0:
//                unsorted = unsorted[1:]
//                e.Value = uitem
//                e = e.Next()
//            }
//        }
//
//        for _, kvp := range unsorted {
//            store.sortedCache.PushBack(kvp)
//        }

    }

    //----------------------------------------
    // etc

    // Only entrypoint to mutate store.cache.
    func setCacheValue(
        key: Data,
        value: Data?,
        deleted: Bool,
        dirty: Bool
    ) {
        cache[key.hexEncodedString()] = CacheValue(
            value: value,
            deleted: deleted,
            dirty: dirty
        )
        
        if dirty {
            unsortedCache[key.hexEncodedString()] = true
        }
    }
}
