import Foundation
import Tendermint
import Database

// Store is composed of many CommitStores. Name contrasts with
// cacheMultiStore which is for cache-wrapping other MultiStores. It implements
// the CommitMultiStore interface.
final class RootMultiStore: CommitMultiStore {
    static let latestVersionKey = "s/latest"
    static let pruneHeightsKey  = "s/pruneheights"
    
    // s/<version>
    static func commitInfoKey(version: Int64) -> String {
        "s/\(version)"
    }

    let database: Database
    var lastCommitInfo: CommitInfo? = nil
    
    // SetPruning sets the pruning strategy on the root store and all the sub-stores.
    // Note, calling SetPruning on the root store prior to LoadVersion or
    // LoadLatestVersion performs a no-op as the stores aren't mounted yet.
    var pruningOptions: PruningOptions
    
    var storesParameters: [StoreKey: StoreParameters]
    var stores: [StoreKey: CommitKeyValueStore]
    var keysByName: [String: StoreKey]
    
    // SetLazyLoading sets if the iavl store should be loaded lazily or not
    var isLazyLoadingEnabled: Bool = false
    var pruneHeights: [Int64]

    var traceWriter:  Writer?
    var traceContext: TraceContext = [:]

    var interBlockCache: MultiStorePersistentCache?
    
    // NewStore returns a reference to a new Store object with the provided DB. The
    // store will be created with a PruneNothing pruning strategy by default. After
    // a store is created, KVStores must be mounted and finally LoadLatestVersion or
    // LoadVersion must be called.
    init(database: Database) {
        self.database = database
        self.pruningOptions = .nothing
        self.storesParameters = [:]
        self.stores = [:]
        self.keysByName = [:]
        self.pruneHeights = []
    }

    // Implements Store.
    var storeType: StoreType {
        .multi
    }

    // Implements CommitMultiStore.
    func mountStoreWithDatabase(key: StoreKey, type: StoreType, database: Database?) {
        if storesParameters[key] != nil {
            fatalError("Store duplicate store key \(key)")
        }
        
        if keysByName[key.name] != nil {
           fatalError("Store duplicate store key name \(key)")
        }
        
        storesParameters[key] = StoreParameters(
            key: key,
            database: database,
            type: type
        )
        
        keysByName[key.name] = key
    }
    
    // GetCommitStore returns a mounted CommitStore for a given StoreKey. If the
    // store is wrapped in an inter-block cache, it will be unwrapped before returning.
    func commitStore(key: StoreKey) -> CommitStore? {
        commitKeyValueStore(key: key)
    }
   
    // GetCommitKVStore returns a mounted CommitKVStore for a given StoreKey. If the
    // store is wrapped in an inter-block cache, it will be unwrapped before returning.
    func commitKeyValueStore(key: StoreKey) -> CommitKeyValueStore? {
        // If the Store has an inter-block cache, first attempt to lookup and unwrap
        // the underlying CommitKVStore by StoreKey. If it does not exist, fallback to
        // the main mapping of CommitKVStores.
        if let interBlockCache = self.interBlockCache {
            if let store = interBlockCache.unwrap(key: key) {
                return store
            }
        }
        
        return stores[key]
    }
    
    // LoadLatestVersionAndUpgrade implements CommitMultiStore
    func loadLatestVersionAndUpgrade(upgrades: StoreUpgrades) throws {
        let version = Self.latestVersion(database: database)
        return try loadVersion(version: version, upgrades: upgrades)
    }

    // LoadVersionAndUpgrade allows us to rename substores while loading an older version
    func loadVersionAndUpgrade(version: Int64, upgrades: StoreUpgrades) throws {
        try loadVersion(version: version, upgrades: upgrades)
    }

    // LoadLatestVersion implements CommitMultiStore.
    func loadLatestVersion() throws {
        let version = Self.latestVersion(database: database)
        return try loadVersion(version: version, upgrades: nil)
    }

    // LoadVersion implements CommitMultiStore.
    func load(version: Int64) throws {
        try loadVersion(version: version, upgrades: nil)
    }
    
    func loadVersion(version: Int64, upgrades: StoreUpgrades?) throws {
        var infos: [String: StoreInfo] = [:]
        var commitInfo: CommitInfo?

        // load old data if we are not version 0
        if version != 0 {
            let ci = try Self.commitInfo(database: database, version: version)

            // convert StoreInfos slice to map
            for storeInfo in ci.storeInfos {
                infos[storeInfo.name] = storeInfo
            }
            
            commitInfo = ci
        }

        // load each Store (note this doesn't panic on unmounted keys now)
        var newStores: [StoreKey: CommitKeyValueStore] = [:]
        
        for (key, storeParameters) in storesParameters {
            // Load it
            do {
                let store = try loadCommitStoreFromParameters(
                    key: key,
                    id: commitID(infos: infos, name: key.name),
                    parameters: storeParameters
                )
                
                newStores[key] = store

                // If it was deleted, remove all data
                if upgrades?.isDeleted(keyName: key.name) ?? false {
                    do {
                        try delete(keyValueStore: store)
                    } catch {
                        throw Cosmos.Error.generic(reason: "failed to delete store \(key.name): \(error)")
                    }
                } else if let oldName = upgrades?.renamedFrom(keyName: key.name) {
                    // handle renames specially
                    // make an unregistered key to satify loadCommitStore params
                    let oldKey = KeyValueStoreKey(name: oldName)
                    var oldParameters = storeParameters
                    oldParameters.key = oldKey

                    // load from the old name
                    do {
                        let oldStore = try loadCommitStoreFromParameters(
                            key: oldKey,
                            id: commitID(infos: infos, name: oldName),
                            parameters: oldParameters
                        )
                        
                        // move all data
                        do {
                            try moveKeyValueStoreData(
                                oldStore: oldStore,
                                newStore: store
                            )
                        } catch {
                            throw Cosmos.Error.generic(reason: "failed to move store \(oldName) -> \(key.name): \(error)")
                        }
                    } catch {
                        throw Cosmos.Error.generic(reason: "failed to load old Store '\(oldName)': \(error)")
                    }
                }
            } catch {
                throw Cosmos.Error.generic(reason: "failed to load Store: \(error)")
            }
        }

        self.lastCommitInfo = commitInfo
        self.stores = newStores

        // load any pruned heights we missed from disk to be pruned on the next run
        guard let pruneHeights = try? RootMultiStore.pruneHeights(database: self.database) else {
            return
        }
        
        guard !pruneHeights.isEmpty else {
            return
        }
        
        self.pruneHeights = pruneHeights
    }

    func commitID(infos: [String: StoreInfo], name: String) -> CommitID {
        guard let info = infos[name] else {
            return CommitID()
        }
        
        return info.core.commitID
    }
    
    func delete(keyValueStore: KeyValueStore) throws {
        // Note that we cannot write while iterating, so load all keys here, delete below
        var keys: [Data] = []
        var iterator = keyValueStore.iterator(start: Data(), end: Data())
        
        while iterator.isValid {
            defer {
                iterator.next()
            }
            
            keys.append(iterator.key)
        }
        
        iterator.close()

        for key in keys {
            keyValueStore.delete(key: key)
        }
    }
    
    // we simulate move by a copy and delete
    func moveKeyValueStoreData(
        oldStore: KeyValueStore,
        newStore: KeyValueStore
    ) throws {
        // we read from one and write to another
        var iterator = oldStore.iterator(start: Data(), end: Data())
        
        while iterator.isValid {
            defer {
                iterator.next()
            }
            
            newStore.set(key: iterator.key, value: iterator.value)
        }
        
        iterator.close()

        // then delete the old store
        try delete(keyValueStore: oldStore)
    }

    // SetInterBlockCache sets the Store's internal inter-block (persistent) cache.
    // When this is defined, all CommitKVStores will be wrapped with their respective
    // inter-block cache.
    func set(interBlockCache: MultiStorePersistentCache) {
        self.interBlockCache = interBlockCache
    }
    
    // SetTracer sets the tracer for the MultiStore that the underlying
    // stores will utilize to trace operations. A MultiStore is returned.
    func set(tracer: Writer?) -> MultiStore {
        self.traceWriter = tracer
        return self
    }

    // SetTracingContext updates the tracing context for the MultiStore by merging
    // the given context with the existing context by key. Any existing keys will
    // be overwritten. It is implied that the caller should update the context when
    // necessary between tracing operations. It returns a modified MultiStore.
    func set(tracingContext: TraceContext) -> MultiStore {
        if !self.traceContext.isEmpty {
            for (key, value) in traceContext {
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

    //----------------------------------------
    // +CommitStore

    // Implements Committer/CommitStore.
    var lastCommitID: CommitID? {
        // TODO: Check this force unwrap
        lastCommitInfo?.commitID
    }

    // Implements Committer/CommitStore.
    func commit() -> CommitID {
        //fatalError()
        let previousHeight = lastCommitInfo?.version ?? 0
        let version = previousHeight + 1
        lastCommitInfo = commitStores(version: version)


        // TODO: Implement
        
        // Determine if pruneHeight height needs to be added to the list of heights to
        // be pruned, where pruneHeight = (commitHeight - 1) - KeepRecent.
//        if int64(rs.pruningOpts.KeepRecent) < previousHeight {
//            pruneHeight := previousHeight - int64(rs.pruningOpts.KeepRecent)
            // We consider this height to be pruned iff:
            //
            // - KeepEvery is zero as that means that all heights should be pruned.
            // - KeepEvery % (height - KeepRecent) != 0 as that means the height is not
            // a 'snapshot' height.
//            if rs.pruningOpts.KeepEvery == 0 || pruneHeight%int64(rs.pruningOpts.KeepEvery) != 0 {
//                rs.pruneHeights = append(rs.pruneHeights, pruneHeight)
//            }
//        }
//
        // batch prune if the current height is a pruning interval height
//        if rs.pruningOpts.Interval > 0 && version%int64(rs.pruningOpts.Interval) == 0 {
//            rs.pruneStores()
//        }
//
//        flushMetadata(rs.db, version, rs.lastCommitInfo, rs.pruneHeights)
//

        return CommitID(version: version)
    }

    // pruneStores will batch delete a list of heights from each mounted sub-store.
    // Afterwards, pruneHeights is reset.
    func pruneStores() {
//        if len(rs.pruneHeights) == 0 {
//            return
//        }
//
//        for key, store := range rs.stores {
//            if store.GetStoreType() == types.StoreTypeIAVL {
//                // If the store is wrapped with an inter-block cache, we must first unwrap
//                // it to get the underlying IAVL store.
//                store = rs.GetCommitKVStore(key)
//
//                if err := store.(*iavl.Store).DeleteVersions(rs.pruneHeights...); err != nil {
//                    if errCause := errors.Cause(err); errCause != nil && errCause != iavltree.ErrVersionDoesNotExist {
//                        panic(err)
//                    }
//                }
//            }
//        }
//
//        rs.pruneHeights = make([]int64, 0)
    }

    // Implements CacheWrapper/Store/CommitStore.
    var cacheWrap: CacheWrap {
        cacheMultiStore
    }
 
    // CacheWrapWithTrace implements the CacheWrapper interface.
    func cacheWrapWithTrace(writer: Writer, traceContext: TraceContext) -> CacheWrap {
        cacheWrap
    }
    
    //----------------------------------------
    // +MultiStore

    // CacheMultiStore cache-wraps the multi-store and returns a CacheMultiStore.
    // It implements the MultiStore interface.
    var cacheMultiStore: CacheMultiStore {
        var stores: [StoreKey: CacheWrapper] = [:]
        
        for (key, value) in self.stores {
            stores[key] = value
        }

        return BaseCacheMultiStore(
            database: database,
            stores: stores,
            keys: keysByName,
            traceWriter: traceWriter,
            traceContext: traceContext
        )
    }

    // CacheMultiStoreWithVersion is analogous to CacheMultiStore except that it
    // attempts to load stores at a given version (height). An error is returned if
    // any store cannot be loaded. This should only be used for querying and
    // iterating at past heights.
    func cacheMultiStore(withVersion version: Int64) throws -> CacheMultiStore {
        // TODO: Implement
        fatalError()
//        cachedStores := make(map[types.StoreKey]types.CacheWrapper)
//        for key, store := range rs.stores {
//            switch store.GetStoreType() {
//            case types.StoreTypeIAVL:
//                // If the store is wrapped with an inter-block cache, we must first unwrap
//                // it to get the underlying IAVL store.
//                store = rs.GetCommitKVStore(key)
//
//                // Attempt to lazy-load an already saved IAVL store version. If the
//                // version does not exist or is pruned, an error should be returned.
//                iavlStore, err := store.(*iavl.Store).GetImmutable(version)
//                if err != nil {
//                    return nil, err
//                }
//
//                cachedStores[key] = iavlStore
//
//            default:
//                cachedStores[key] = store
//            }
//        }
//
//        return cachemulti.NewStore(rs.db, cachedStores, rs.keysByName, rs.traceWriter, rs.traceContext), nil
    }

    // GetStore returns a mounted Store for a given StoreKey. If the StoreKey does
    // not exist, it will panic. If the Store is wrapped in an inter-block cache, it
    // will be unwrapped prior to being returned.
    //
    // TODO: This isn't used directly upstream. Consider returning the Store as-is
    // instead of unwrapping.
    func store(key: StoreKey) -> Store {
        guard let store = commitKeyValueStore(key: key) else {
           fatalError("store does not exist for key: \(key)")
        }
        
        return store
    }
    
    // GetKVStore returns a mounted KVStore for a given StoreKey. If tracing is
    // enabled on the KVStore, a wrapped TraceKVStore will be returned with the root
    // store's tracer, otherwise, the original KVStore will be returned.
    //
    // NOTE: The returned KVStore may be wrapped in an inter-block cache if it is
    // set on the root store.
    func keyValueStore(key: StoreKey) -> KeyValueStore {
        let store = stores[key]

        // TODO: Implement
//        if isTracingEnabled {
//            store = tracekv.NewStore(store, rs.traceWriter, rs.traceContext)
//        }

        return store!
    }
//    }
//
//    // getStoreByName performs a lookup of a StoreKey given a store name typically
//    // provided in a path. The StoreKey is then used to perform a lookup and return
//    // a Store. If the Store is wrapped in an inter-block cache, it will be unwrapped
//    // prior to being returned. If the StoreKey does not exist, nil is returned.
//    func (rs *Store) getStoreByName(name string) types.Store {
//        key := rs.keysByName[name]
//        if key == nil {
//            return nil
//        }
//
//        return rs.GetCommitKVStore(key)
//    }

    func loadCommitStoreFromParameters(
        key: StoreKey,
        id: CommitID,
        parameters: StoreParameters
    ) throws -> CommitKeyValueStore {
        let database: Database

        if let parametersDatabase = parameters.database {
            database = PrefixDatabase(prefix: "s/_/".data, database: parametersDatabase)
        } else {
            let prefix = "s/k:" + parameters.key.name + "/"
            database = PrefixDatabase(prefix: prefix.data, database: self.database)
        }

        switch parameters.type {
        case .multi:
            fatalError("recursive MultiStores not yet supported")
        case .iavlTree:
            let store = TransientStore()
            // TODO: Implement actual iAVL store
//            var store: CommitKeyValueStore = try IAVLStore(
//                database: database,
//                commitId: id,
//                isLazyLoadingEnabled: isLazyLoadingEnabled
//            )
//
//            if let cache = interBlockCache {
//                // Wrap and get a CommitKVStore with inter-block caching. Note, this should
//                // only wrap the primary CommitKVStore, not any store that is already
//                // cache-wrapped as that will create unexpected behavior.
//                store = cache.storeCache(key: key, store: store)
//            }

            return store
        case .database:
            return CommitDatabaseAdapterStore(database: database)
        case .transient:
            guard key is TransientStoreKey else {
                throw Cosmos.Error.generic(reason: "invalid StoreKey for StoreTypeTransient: \(key.description)")
            }

            return TransientStore()
        }
    }

}

//----------------------------------------
// storeParams

struct StoreParameters {
    var key: StoreKey
    let database: Database?
    let type: StoreType
}


//----------------------------------------
// commitInfo

// NOTE: Keep commitInfo a simple immutable struct.
struct CommitInfo: Codable {
    // Version
    let version: Int64

    // Store info for
    let storeInfos: [StoreInfo]
    
    // Hash returns the simple merkle root hash of the stores sorted by name.
    var hash: Data {
        var map: [String: Data] = [:]

        for storeInfo in storeInfos {
            map[storeInfo.name] = storeInfo.hash
        }

        return Merkle.simpleHash(map: map)
    }

    var commitID: CommitID {
        CommitID(version: version, hash: hash)
    }
}

//----------------------------------------
// storeInfo

// storeInfo contains the name and core reference for an
// underlying store.  It is the leaf of the Stores top
// level simple merkle tree.
struct StoreInfo: Codable {
    let name: String
    let core: StoreCore
}

struct StoreCore: Codable {
    // StoreType StoreType
    let commitID: CommitID
    // ... maybe add more state
}

extension StoreInfo {
    // Implements merkle.Hasher.
    var hash: Data {
        // Doesn't write Name, since merkle.SimpleHashFromMap() will
        // include them via the keys.
        let data = core.commitID.hash
        var hasher = Hash()
        hasher.write(data: data)
        return hasher.sum()
    }

}

//----------------------------------------
// Misc.

extension RootMultiStore {
    static let codec = Codec()

    static func latestVersion(database: Database)  -> Int64 {
        guard let latestBytes = try! database.get(key: latestVersionKey.data) else {
            return 0
        }
        
        return try! codec.unmarshalBinaryLengthPrefixed(data: latestBytes)
    }
    
    //// Commits each store and returns a new commitInfo.
    func commitStores(version: Int64) -> CommitInfo {
        var storeInfos: [StoreInfo] = []
    
        for (key, store) in stores {
            let commitID = store.commit()
    
            if store is TransientStore {
                continue
            }

            storeInfos.append(StoreInfo(name: key.name, core: StoreCore(commitID: commitID)))
        }
    
        return CommitInfo(
            version:    version,
            storeInfos: storeInfos
        )
    
    }

    // Gets commitInfo from disk.
    static func commitInfo(database: Database, version: Int64) throws -> CommitInfo {
        let commitInfoKey = self.commitInfoKey(version: version)
        
        do {
            guard let commitInfoData = try database.get(key: commitInfoKey.data) else {
                throw Cosmos.Error.generic(reason: "failed to get commit info: no data")
            }
                
            do {
                return try codec.unmarshalBinaryLengthPrefixed(data: commitInfoData)
            } catch {
                throw Cosmos.Error.generic(reason: "failed to get Store: \(error)")
            }
            
        } catch {
            throw Cosmos.Error.generic(reason: "failed to get commit info: \(error)")
        }
    }

    //func setCommitInfo(batch dbm.Batch, version int64, cInfo commitInfo) {
    //    cInfoBytes := cdc.MustMarshalBinaryLengthPrefixed(cInfo)
    //    cInfoKey := fmt.Sprintf(commitInfoKeyFmt, version)
    //    batch.Set([]byte(cInfoKey), cInfoBytes)
    //}
    //
    //func setLatestVersion(batch dbm.Batch, version int64) {
    //    latestBytes := cdc.MustMarshalBinaryLengthPrefixed(version)
    //    batch.Set([]byte(latestVersionKey), latestBytes)
    //}
    //
    //func setPruningHeights(batch dbm.Batch, pruneHeights []int64) {
    //    bz := cdc.MustMarshalBinaryBare(pruneHeights)
    //    batch.Set([]byte(pruneHeightsKey), bz)
    //}
    
    static func pruneHeights(database: Database) throws -> [Int64] {
        let rawData: Data?
        
        do {
            rawData = try database.get(key: pruneHeightsKey.data)
        } catch {
            throw Cosmos.Error.generic(reason: "failed to get pruned heights: \(error)")
        }
        
        guard let data = rawData, !data.isEmpty else {
            throw Cosmos.Error.generic(reason: "no pruned heights found")
        }
        
        do {
            return try codec.unmarshalBinaryBare(data: data)
        } catch {
            throw Cosmos.Error.generic(reason: "failed to unmarshal pruned heights: \(error)")
        }
    }
    
    //func flushMetadata(db dbm.DB, version int64, cInfo commitInfo, pruneHeights []int64) {
    //    batch := db.NewBatch()
    //    defer batch.Close()
    //
    //    setCommitInfo(batch, version, cInfo)
    //    setLatestVersion(batch, version)
    //    setPruningHeights(batch, pruneHeights)
    //
    //    if err := batch.Write(); err != nil {
    //        panic(fmt.Errorf("error on batch write %w", err))
    //    }
    //}
}
