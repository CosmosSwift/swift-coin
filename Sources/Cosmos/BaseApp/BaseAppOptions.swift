import Database

extension BaseApp {
    public func setName(_ name: String) {
        assertUnsealed("SetName() on sealed BaseApp")
        self.name = name
    }

    // SetAppVersion sets the application's version string.
    public func setAppVersion(version: String) {
        assertUnsealed("SetAppVersion() on sealed BaseApp")
        self.appVersion = version
    }

    public func setDatabase(database: Database) {
        assertUnsealed("SetDB() on sealed BaseApp")
        self.database = database
    }

    public func setCommitMultiStore(commitMultiStore: CommitMultiStore) {
        assertUnsealed("SetEndBlocker() on sealed BaseApp")
        self.commitMultiStore = commitMultiStore
    }

    
    public func setInitChainer(_ initChainer: @escaping InitChainer) {
        assertUnsealed("SetInitChainer() on sealed BaseApp")
        self.initChainer = initChainer
    }
    
    public func setBeginBlocker(_ beginBlocker: @escaping BeginBlocker) {
        assertUnsealed("SetBeginBlocker() on sealed BaseApp")
        self.beginBlocker = beginBlocker
    }

    public func setEndBlocker(_ endBlocker: @escaping EndBlocker) {
        assertUnsealed("SetEndBlocker() on sealed BaseApp")
        self.endBlocker = endBlocker
    }

    public func setAnteHandler(_ anteHandler: @escaping AnteHandler) {
        assertUnsealed("SetAnteHandler() on sealed BaseApp")
        self.anteHandler = anteHandler
    }

    public func setAddrPeerFilter(_ peerFilter: @escaping PeerFilter) {
        assertUnsealed("SetAddrPeerFilter() on sealed BaseApp")
        self.addressPeerFilter = peerFilter
    }

    public func setIDPeerFilter(_ peerFilter: @escaping PeerFilter) {
        assertUnsealed("SetIDPeerFilter() on sealed BaseApp")
        self.idPeerFilter = peerFilter
    }
    
    public func setFauxMerkleMode() {
        assertUnsealed("SetFauxMerkleMode() on sealed BaseApp")
        self.fauxMerkleMode = true
    }

    // SetCommitMultiStoreTracer sets the store tracer on the BaseApp's underlying
    // CommitMultiStore.
    public func setCommitMultiStoreTracer(tracer: Writer?) {
        self.commitMultiStore.set(tracer: tracer)
    }

    // SetStoreLoader allows us to customize the rootMultiStore initialization.
    public func setStoreLoader(loader: @escaping StoreLoader) {
        assertUnsealed("SetStoreLoader() on sealed BaseApp")
        self.storeLoader = loader
    }

    // SetRouter allows us to customize the router.
    public func SetRouter(router: Router) {
        assertUnsealed("SetRouter() on sealed BaseApp")
        self.router = router
    }
}
