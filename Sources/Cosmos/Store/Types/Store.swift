import Foundation
import Database

public protocol CacheWrapper {
    // CacheWrap cache wraps.
//        var cacheWrap: CacheWrap { get }

    // CacheWrapWithTrace cache wraps with tracing enabled.
//    func cacheWrapWithTrace(writer: io.Writer, traceContext: TraceContext) -> CacheWrap
}

// CacheWrap makes the most appropriate cache-wrap. For example,
// IAVLStore.CacheWrap() returns a CacheKVStore. CacheWrap should not return
// a Committer, since Commit cache-wraps make no sense. It can return KVStore,
// HeapStore, SpaceStore, etc.
public protocol CacheWrap {
    // Write syncs with the underlying store.
    func write()

    // CacheWrap recursively wraps again.
    func cacheWrap() -> CacheWrap

    // CacheWrapWithTrace recursively wraps again with tracing enabled.
//    CacheWrapWithTrace(w io.Writer, tc TraceContext) CacheWrap
}

// kind of store
public enum StoreType {
    case multi
    case database
    case iavlTree
    case tansient
}

public protocol Store: CacheWrapper {
    var storeType: StoreType { get }
}

// StoreKey is a key used to index stores in a MultiStore.
public protocol StoreKey {
    var name: String { get }
    var string: String { get }
}

// KVStore is a simple interface to get/set data
public protocol KeyValueStore: Store {
    // Get returns nil iff key doesn't exist. Panics on nil key.
    func get(key: Data) -> Data?

    // Has checks if a key exists. Panics on nil key.
    func has(key: Data) -> Bool

    // Set sets the key. Panics on nil key or value.
    func set(key: Data, value: Data)

    // Delete deletes the key. Panics on nil key.
    func delete(key: Data)

    // Iterator over a domain of keys in ascending order. End is exclusive.
    // Start must be less than end, or the Iterator is invalid.
    // Iterator must be closed by caller.
    // To iterate over entire domain, use store.Iterator(nil, nil)
    // CONTRACT: No writes may happen within a domain while an iterator exists over it.
    // Exceptionally allowed for cachekv.Store, safe to write in the modules.
    func iterator(start: Data?, end: Data?) -> Iterator

    // Iterator over a domain of keys in descending order. End is exclusive.
    // Start must be less than end, or the Iterator is invalid.
    // Iterator must be closed by caller.
    // CONTRACT: No writes may happen within a domain while an iterator exists over it.
    // Exceptionally allowed for cachekv.Store, safe to write in the modules.
    func reverseIterator(start: Data?, end: Data?) -> Iterator
}

protocol MultiStore: Store {
    // Cache wrap MultiStore.
    // NOTE: Caller should probably not call .Write() on each, but
    // call CacheMultiStore.Write().
//    var cacheMultiStore: CacheMultiStore

    // CacheMultiStoreWithVersion cache-wraps the underlying MultiStore where
    // each stored is loaded at a specific version (height).
//    func cacheMultiStoreWithVersion(version: Int64) throws -> CacheMultiStore

    // Convenience for fetching substores.
    // If the store does not exist, panics.
    func getStore(key: StoreKey) -> Store
    func getKeyValueStore(key: StoreKey) -> KeyValueStore

    // TracingEnabled returns if tracing is enabled for the MultiStore.
    var tracingEnabled: Bool { get }

    // SetTracer sets the tracer for the MultiStore that the underlying
    // stores will utilize to trace operations. The modified MultiStore is
    // returned.
//    func setTracer(writer: Writer) -> MultiStore

    // SetTracingContext sets the tracing context for a MultiStore. It is
    // implied that the caller should update the context when necessary between
    // tracing operations. The modified MultiStore is returned.
//    func setTracingContext(context: TraceContext) -> MultiStore
}
