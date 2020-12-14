import Foundation
import Database

// Store is composed of many CommitStores. Name contrasts with
// cacheMultiStore which is for cache-wrapping other MultiStores. It implements
// the CommitMultiStore interface.
final class RootMultiStore: CommitMultiStore {
    var isTracingEnabled: Bool = false
    
    static let latestVersionKey = "s/latest"
    static let pruneHeightsKey  = "s/pruneheights"
    // s/<version>
    static let commitInfoKeyFormat = "s/%d"

    let database: Database
    var lastCommitInfo: CommitInfo? = nil
    
    // SetPruning sets the pruning strategy on the root store and all the sub-stores.
    // Note, calling SetPruning on the root store prior to LoadVersion or
    // LoadLatestVersion performs a no-op as the stores aren't mounted yet.
    var pruningOptions: PruningOptions
    
//    let storesParameters: [StoreKey: StoreParameters]
    // TODO: Investigate if we should really use StoreKey as the dictionary key.
    var storesParameters: [String: StoreParameters]
//    let stores: [StoreKey: CommitKeyValueStore]
    // TODO: Investigate if we should really use StoreKey as the dictionary key.
    let stores: [String: CommitKeyValueStore]
    var keysByName: [String: StoreKey]
    
    // SetLazyLoading sets if the iavl store should be loaded lazily or not
    var isLazyLoadingEnabled: Bool = false
    let pruneHeights: [Int64]

//    let traceWriter: Writer
//    let traceContext: TraceContext

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
    func mountStoreWithDatabase(key: StoreKey, type: StoreType, database: Database) {
        // TODO: We're using key.name here to index the dictionary because StoreKey is not Hashable
        // and we couldn't use it as storeParameters key.
        if storesParameters[key.name] != nil {
            fatalError("Store duplicate store key \(key)")
        }
        
        if keysByName[key.name] != nil {
           fatalError("Store duplicate store key name \(key)")
        }
        
        // TODO: We're using key.name here to index the dictionary because StoreKey is not Hashable
        // and we couldn't use it as storeParameters key.
        storesParameters[key.name] = StoreParameters(
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
        // TODO: We're using key.name here to index the dictionary because StoreKey is not Hashable
        // and we couldn't use it as storeParameters key.
        return stores[key.name]
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
        fatalError()
//        infos := make(map[string]storeInfo)
//        var cInfo commitInfo
//
//        // load old data if we are not version 0
//        if ver != 0 {
//            var err error
//            cInfo, err = getCommitInfo(rs.db, ver)
//            if err != nil {
//                return err
//            }
//
//            // convert StoreInfos slice to map
//            for _, storeInfo := range cInfo.StoreInfos {
//                infos[storeInfo.Name] = storeInfo
//            }
//        }
//
//        // load each Store (note this doesn't panic on unmounted keys now)
//        var newStores = make(map[types.StoreKey]types.CommitKVStore)
//        for key, storeParams := range rs.storesParams {
//            // Load it
//            store, err := rs.loadCommitStoreFromParams(key, rs.getCommitID(infos, key.Name()), storeParams)
//            if err != nil {
//                return fmt.Errorf("failed to load Store: %v", err)
//            }
//            newStores[key] = store
//
//            // If it was deleted, remove all data
//            if upgrades.IsDeleted(key.Name()) {
//                if err := deleteKVStore(store.(types.KVStore)); err != nil {
//                    return fmt.Errorf("failed to delete store %s: %v", key.Name(), err)
//                }
//            } else if oldName := upgrades.RenamedFrom(key.Name()); oldName != "" {
//                // handle renames specially
//                // make an unregistered key to satify loadCommitStore params
//                oldKey := types.NewKVStoreKey(oldName)
//                oldParams := storeParams
//                oldParams.key = oldKey
//
//                // load from the old name
//                oldStore, err := rs.loadCommitStoreFromParams(oldKey, rs.getCommitID(infos, oldName), oldParams)
//                if err != nil {
//                    return fmt.Errorf("failed to load old Store '%s': %v", oldName, err)
//                }
//
//                // move all data
//                if err := moveKVStoreData(oldStore.(types.KVStore), store.(types.KVStore)); err != nil {
//                    return fmt.Errorf("failed to move store %s -> %s: %v", oldName, key.Name(), err)
//                }
//            }
//        }
//
//        rs.lastCommitInfo = cInfo
//        rs.stores = newStores
//
//        // load any pruned heights we missed from disk to be pruned on the next run
//        ph, err := getPruningHeights(rs.db)
//        if err == nil && len(ph) > 0 {
//            rs.pruneHeights = ph
//        }
//
//        return nil
    }

    func commitID(infos: [String: StoreInfo], name: String) -> CommitID {
        guard let info = infos[name] else {
            return CommitID()
        }
        
        return info.core.commitID
    }
    
    // SetInterBlockCache sets the Store's internal inter-block (persistent) cache.
    // When this is defined, all CommitKVStores will be wrapped with their respective
    // inter-block cache.
    func set(interBlockCache: MultiStorePersistentCache) {
        self.interBlockCache = interBlockCache
    }
    
    //----------------------------------------
    // +CommitStore

    // Implements Committer/CommitStore.
    func lastCommitID() -> CommitID {
        // TODO: Check this force unwrap
        lastCommitInfo!.commitID
    }

    // Implements Committer/CommitStore.
    func commit() -> CommitID {
        fatalError()
//        previousHeight := rs.lastCommitInfo.Version
//        version := previousHeight + 1
//        rs.lastCommitInfo = commitStores(version, rs.stores)
//
//        // Determine if pruneHeight height needs to be added to the list of heights to
//        // be pruned, where pruneHeight = (commitHeight - 1) - KeepRecent.
//        if int64(rs.pruningOpts.KeepRecent) < previousHeight {
//            pruneHeight := previousHeight - int64(rs.pruningOpts.KeepRecent)
//            // We consider this height to be pruned iff:
//            //
//            // - KeepEvery is zero as that means that all heights should be pruned.
//            // - KeepEvery % (height - KeepRecent) != 0 as that means the height is not
//            // a 'snapshot' height.
//            if rs.pruningOpts.KeepEvery == 0 || pruneHeight%int64(rs.pruningOpts.KeepEvery) != 0 {
//                rs.pruneHeights = append(rs.pruneHeights, pruneHeight)
//            }
//        }
//
//        // batch prune if the current height is a pruning interval height
//        if rs.pruningOpts.Interval > 0 && version%int64(rs.pruningOpts.Interval) == 0 {
//            rs.pruneStores()
//        }
//
//        flushMetadata(rs.db, version, rs.lastCommitInfo, rs.pruneHeights)
//
//        return types.CommitID{
//            Version: version,
//            Hash:    rs.lastCommitInfo.Hash(),
//        }
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
//    func (rs *Store) CacheWrap() types.CacheWrap {
//        return rs.CacheMultiStore().(types.CacheWrap)
//    }
//
//    // CacheWrapWithTrace implements the CacheWrapper interface.
//    func (rs *Store) CacheWrapWithTrace(_ io.Writer, _ types.TraceContext) types.CacheWrap {
//        return rs.CacheWrap()
//    }
    
    //----------------------------------------
    // +MultiStore

    // CacheMultiStore cache-wraps the multi-store and returns a CacheMultiStore.
    // It implements the MultiStore interface.
    var cacheMultiStore: CacheMultiStore {
        fatalError()
//        CacheMultiStore(
//            database,
//            stores,
//            keysByName//,
////            traceWriter,
////            traceContext
//        )
    }

    // CacheMultiStoreWithVersion is analogous to CacheMultiStore except that it
    // attempts to load stores at a given version (height). An error is returned if
    // any store cannot be loaded. This should only be used for querying and
    // iterating at past heights.
//    func (rs *Store) CacheMultiStoreWithVersion(version int64) (types.CacheMultiStore, error) {
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
//    }
//
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
        // TODO: Create a hash in StoreKey and use it instead of name.
        let store = stores[key.name]

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


    //----------------------------------------
    // Misc.
    
    static let codec = Codec()

    static func latestVersion(database: Database)  -> Int64 {
        do {
            guard let latestBytes = try database.get(key: latestVersionKey.data) else {
                return 0
            }
            
            return try codec.unmarshalBinaryLengthPrefixed(data: latestBytes)
        } catch {
            fatalError("\(error)")
        }
    }
}

//----------------------------------------
// storeParams

struct StoreParameters {
    let key: StoreKey
    let database: Database
    let type: StoreType
}


//----------------------------------------
// commitInfo

// NOTE: Keep commitInfo a simple immutable struct.
struct CommitInfo {
    // Version
    let version: Int64

    // Store info for
    let storeInfos: [StoreInfo]
    
    // Hash returns the simple merkle root hash of the stores sorted by name.
    var hash: Data {
        fatalError()
//        // TODO: cache to ci.hash []byte
//        m := make(map[string][]byte, len(ci.StoreInfos))
//
//        for _, storeInfo := range ci.StoreInfos {
//            m[storeInfo.Name] = storeInfo.Hash()
//        }
//
//        return merkle.SimpleHashFromMap(m)
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
struct StoreInfo {
    let name: String
    let core: StoreCore
}

struct StoreCore {
    // StoreType StoreType
    let commitID: CommitID
    // ... maybe add more state
}
