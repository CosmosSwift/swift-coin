import Database

//----------------------------------------
// Store

// Store holds many cache-wrapped stores.
// Implements MultiStore.
// NOTE: a Store (and MultiStores in general) should never expose the
// keys for the substores.
final class BaseCacheMultiStore: CacheMultiStore {
    let database: CacheKeyValueStore
    var stores: [StoreKey: CacheWrap]
    let keys: [String: StoreKey]

    var traceWriter: Writer?
    var traceContext: TraceContext
    
    init(
        database: CacheKeyValueStore,
        stores: [StoreKey: CacheWrap],
        keys: [String: StoreKey],
        traceWriter: Writer?,
        traceContext: TraceContext
    ) {
        self.database = database
        self.stores = stores
        self.keys = keys
        self.traceWriter = traceWriter
        self.traceContext = traceContext
    }
    
    // NewFromKVStore creates a new Store object from a mapping of store keys to
    // CacheWrapper objects and a KVStore as the database. Each CacheWrapper store
    // is cache-wrapped.
    convenience init(
        store: KeyValueStore,
        stores: [StoreKey: CacheWrapper],
        keys: [String: StoreKey],
        traceWriter: Writer?,
        traceContext: TraceContext
    ) {
        self.init(
            database: BaseCacheKeyValueStore(parent: store),
            stores: [:],
            keys: keys,
            traceWriter: traceWriter,
            traceContext: traceContext
        )

        for (key, store) in stores {
            guard let writer = self.traceWriter else {
                self.stores[key] = store.cacheWrap
                continue
            }
           
            self.stores[key] = store.cacheWrapWithTrace(
                writer: writer,
                traceContext: self.traceContext
            )
        }
    }
    
    // NewStore creates a new Store object from a mapping of store keys to
    // CacheWrapper objects. Each CacheWrapper store is cache-wrapped.
    convenience init(
        database: Database,
        stores: [StoreKey: CacheWrapper],
        keys: [String: StoreKey],
        traceWriter: Writer?,
        traceContext: TraceContext
    ) {
        self.init(
            store: DatabaseAdapterStore(database: database),
            stores: stores,
            keys: keys,
            traceWriter: traceWriter,
            traceContext: traceContext
        )
    }
    
    convenience init(store: BaseCacheMultiStore) {
        var stores: [StoreKey: CacheWrap] = [:]
        
        for (key, value) in store.stores {
            stores[key] = value
        }

        self.init(
            database: store.database,
            stores: stores,
            keys: [:],
            traceWriter: store.traceWriter,
            traceContext: store.traceContext
        )
    }
}

extension BaseCacheMultiStore {
    // SetTracer sets the tracer for the MultiStore that the underlying
    // stores will utilize to trace operations. A MultiStore is returned.
    func set(tracer: Writer?) -> MultiStore {
        traceWriter = tracer
        return self
    }

    // SetTracingContext updates the tracing context for the MultiStore by merging
    // the given context with the existing context by key. Any existing keys will
    // be overwritten. It is implied that the caller should update the context when
    // necessary between tracing operations. It returns a modified MultiStore.
    func set(tracingContext: TraceContext) -> MultiStore {
        if !self.traceContext.isEmpty {
            for (key, value) in tracingContext {
                self.traceContext[key] = value
            }
        } else {
            self.traceContext = tracingContext
        }

        return self
    }

    // TracingEnabled returns if tracing is enabled for the MultiStore.
    var isTracingEnabled: Bool {
        traceWriter != nil
    }

    // GetStoreType returns the type of the store.
    var storeType: StoreType {
        .multi
    }

    // Write calls Write on each underlying store.
    func write() {
        database.write()
        
        for (_, store) in stores {
            store.write()
        }
    }

    // Implements CacheWrapper.
    var cacheWrap: CacheWrap {
        cacheMultiStore
    }

    // CacheWrapWithTrace implements the CacheWrapper interface.
    func cacheWrapWithTrace(writer: Writer, traceContext: TraceContext) -> CacheWrap {
        cacheWrap
    }

    // Implements MultiStore.
    var cacheMultiStore: CacheMultiStore {
        BaseCacheMultiStore(store: self)
    }

    // CacheMultiStoreWithVersion implements the MultiStore interface. It will panic
    // as an already cached multi-store cannot load previous versions.
    //
    // TODO: The store implementation can possibly be modified to support this as it
    // seems safe to load previous versions (heights).
    func cacheMultiStore(withVersion version: Int64) throws -> CacheMultiStore {
        fatalError("cannot cache-wrap cached multi-store with a version")
    }

    // GetStore returns an underlying Store by key.
    func store(key: StoreKey) -> Store {
        // TODO: Maybe store(key:) should return an optional
        stores[key]! as! Store
    }

    // GetKVStore returns an underlying KVStore by key.
    func keyValueStore(key: StoreKey) -> KeyValueStore {
        // TODO: There is a bug in their code where
        // they would test the key and not the store for nil
        // if key == nil {
        guard let store = stores[key] else {
            fatalError("kv store with key \(key) has not been registered in stores")
        }
        
        return store as! KeyValueStore
    }
}
