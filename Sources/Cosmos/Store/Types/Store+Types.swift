import Foundation
import ABCI
import Database

public protocol CacheWrapper {
    // CacheWrap cache wraps.
//        var cacheWrap: CacheWrap { get }

    // CacheWrapWithTrace cache wraps with tracing enabled.
//    func cacheWrapWithTrace(writer: io.Writer, traceContext: TraceContext) -> CacheWrap
}

// Stores of MultiStore must implement CommitStore.
public protocol CommitKeyValueStore: CommitStore, KeyValueStore {}

//----------------------------------------
// CacheWrap

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

//----------------------------------------
// CommitID

// CommitID contains the tree version number and its merkle root.
public struct CommitID: Codable {
    let version: Int64
    let hash: Data
    
    init(version: Int64 = 0, hash: Data = Data()) {
        self.version = version
        self.hash = hash
    }
}

extension CommitID: CustomStringConvertible {
    var isZero: Bool {
        version == 0 && hash.isEmpty
    }
   
    public var description: String {
        "CommitID{\(hash):\(version)}"
    }
}


// kind of store
public enum StoreType {
    case multi
    case database
    case iavlTree
    case transient
}

public protocol Store: CacheWrapper {
    var storeType: StoreType { get }
}

// something that can persist to disk
public protocol Commiter {
    func commit() -> CommitID
    var lastCommitID: CommitID? { get }
}

// Stores of MultiStore must implement CommitStore.
public protocol CommitStore: Commiter, Store {}

// Queryable allows a Store to expose internal state to the abci.Query
// interface. Multistore can route requests to the proper Store.
//
// This is an optional, but useful extension to any CommitStore
protocol Queryable {
    func query(queryRequest: RequestQuery) -> ResponseQuery
}


//----------------------------------------
// MultiStore

// StoreUpgrades defines a series of transformations to apply the multistore db upon load
public struct StoreUpgrades: Codable  {
    let renamed: [StoreRename]
    let deleted: [String]
}

// StoreRename defines a name change of a sub-store.
// All data previously under a PrefixStore with OldKey will be copied
// to a PrefixStore with NewKey, then deleted from OldKey store.
struct StoreRename: Codable {
    let oldKey: String
    let newKey: String
    
    private enum CodingKeys: String, CodingKey {
        case oldKey = "old_key"
        case newKey = "new_key"
    }
}

extension StoreUpgrades {
    // IsDeleted returns true if the given key should be deleted
    func isDeleted(keyName: String) -> Bool {
        deleted.contains(keyName)
    }
    
    // RenamedFrom returns the oldKey if it was renamed
    // Returns "" if it was not renamed
    func renamedFrom(keyName: String) -> String? {
        renamed
            .first(where: { $0.newKey == keyName })
            .map(\.oldKey)
    }
}


// StoreKey is a key used to index stores in a MultiStore.
public class StoreKey: Hashable, CustomStringConvertible {
    public let name: String
    
    init(name: String) {
        self.name = name
    }

    public var description: String {
        name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public static func == (lhs: StoreKey, rhs: StoreKey) -> Bool {
        lhs.name == rhs.name
    }
}

// KVStoreKey is used for accessing substores.
// Only the pointer value should ever be used - it functions as a capabilities key.
public final class KeyValueStoreKey: StoreKey {
    public override var description: String {
        "KeyValueStoreKey(\(ObjectIdentifier(self)), \(name))"
    }
}

// TransientStoreKey is used for indexing transient stores in a MultiStore
public final class TransientStoreKey: StoreKey {
    public override var description: String {
        "TransientStoreKey{\(ObjectIdentifier(self)), \(name)}"
    }
}

// TraceContext contains TraceKVStore context data. It will be written with
// every trace operation.
public typealias TraceContext = [String: Any]

// From MultiStore.CacheMultiStore()....
public protocol CacheMultiStore: MultiStore {
    // Writes operations to underlying KVStore
    func write() 
}

// A non-cache MultiStore.
public protocol CommitMultiStore: Commiter, MultiStore {
    // Mount a store of type using the given db.
    // If db == nil, the new store will use the CommitMultiStore db.
    func mountStoreWithDatabase(key: StoreKey, type: StoreType, database: Database?)

    // Panics on a nil key.
    func commitStore(key: StoreKey) -> CommitStore?

    // Panics on a nil key.
    func commitKeyValueStore(key: StoreKey) -> CommitKeyValueStore?

    // Load the latest persisted version. Called once after all calls to
    // Mount*Store() are complete.
    func loadLatestVersion() throws

    // LoadLatestVersionAndUpgrade will load the latest version, but also
    // rename/delete/create sub-store keys, before registering all the keys
    // in order to handle breaking formats in migrations
    func loadLatestVersionAndUpgrade(upgrades: StoreUpgrades) throws

    // LoadVersionAndUpgrade will load the named version, but also
    // rename/delete/create sub-store keys, before registering all the keys
    // in order to handle breaking formats in migrations
    func loadVersionAndUpgrade(version: Int64, upgrades: StoreUpgrades) throws

    // Load a specific persisted version. When you load an old version, or when
    // the last commit attempt didn't complete, the next commit after loading
    // must be idempotent (return the same commit id). Otherwise the behavior is
    // undefined.
    func load(version: Int64) throws

    // Set an inter-block (persistent) cache that maintains a mapping from
    // StoreKeys to CommitKVStores.
    func set(interBlockCache: MultiStorePersistentCache)
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

public protocol MultiStore: Store {
    // Cache wrap MultiStore.
    // NOTE: Caller should probably not call .Write() on each, but
    // call CacheMultiStore.Write().
    var cacheMultiStore: CacheMultiStore { get }

    // CacheMultiStoreWithVersion cache-wraps the underlying MultiStore where
    // each stored is loaded at a specific version (height).
//    func cacheMultiStoreWithVersion(version: Int64) throws -> CacheMultiStore

    // Convenience for fetching substores.
    // If the store does not exist, panics.
    func store(key: StoreKey) -> Store
    func keyValueStore(key: StoreKey) -> KeyValueStore

    // TracingEnabled returns if tracing is enabled for the MultiStore.
    var isTracingEnabled: Bool { get }

    // SetTracer sets the tracer for the MultiStore that the underlying
    // stores will utilize to trace operations. The modified MultiStore is
    // returned.
    // TODO: Check if it's OK to discard the result
    // TODO: Maybe we don't need to return anything
    @discardableResult
    func set(tracer: Writer?) -> MultiStore

    // SetTracingContext sets the tracing context for a MultiStore. It is
    // implied that the caller should update the context when necessary between
    // tracing operations. The modified MultiStore is returned.
    @discardableResult
    // TODO: Check if it's OK to discard the result
    // TODO: Maybe we don't need to return anything
    func set(tracingContext: TraceContext) -> MultiStore
}

// MultiStorePersistentCache defines an interface which provides inter-block
// (persistent) caching capabilities for multiple CommitKVStores based on StoreKeys.
public protocol MultiStorePersistentCache {
    // Wrap and return the provided CommitKVStore with an inter-block (persistent)
    // cache.
    func storeCache(key: StoreKey, store: CommitKeyValueStore) -> CommitKeyValueStore

    // Return the underlying CommitKVStore for a StoreKey.
    func unwrap(key: StoreKey) -> CommitKeyValueStore?

    // Reset the entire set of internal caches.
    func reset()
}

