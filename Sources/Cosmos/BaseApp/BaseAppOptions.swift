import Database

extension BaseApp {
    private func assertSealed(_ message: String) {
        guard !self.sealed else {
            fatalError(message)
        }
    }
    
    public func setName(_ name: String) {
        assertSealed("SetName() on sealed BaseApp")
        self.name = name
    }

    // SetAppVersion sets the application's version string.
    public func setAppVersion(version: String) {
        assertSealed("SetAppVersion() on sealed BaseApp")
        self.appVersion = version
    }

    public func setDatabase(database: Database) {
        assertSealed("SetDB() on sealed BaseApp")
        self.database = database
    }

    public func setCommitMultiStore(commitMultiStore: CommitMultiStore) {
        assertSealed("SetEndBlocker() on sealed BaseApp")
        self.commitMultiStore = commitMultiStore
    }

    
    public func setInitChainer(_ initChainer: @escaping InitChainer) {
        assertSealed("SetInitChainer() on sealed BaseApp")
        self.initChainer = initChainer
    }
    
    public func setBeginBlocker(_ beginBlocker: @escaping BeginBlocker) {
        assertSealed("SetBeginBlocker() on sealed BaseApp")
        self.beginBlocker = beginBlocker
    }

    public func setEndBlocker(_ endBlocker: @escaping EndBlocker) {
        assertSealed("SetEndBlocker() on sealed BaseApp")
        self.endBlocker = endBlocker
    }

    public func setAnteHandler(_ anteHandler: @escaping AnteHandler) {
        assertSealed("SetAnteHandler() on sealed BaseApp")
        self.anteHandler = anteHandler
    }

    public func setAddrPeerFilter(_ peerFilter: @escaping PeerFilter) {
        assertSealed("SetAddrPeerFilter() on sealed BaseApp")
        self.addressPeerFilter = peerFilter
    }

    public func setIDPeerFilter(_ peerFilter: @escaping PeerFilter) {
        assertSealed("SetIDPeerFilter() on sealed BaseApp")
        self.idPeerFilter = peerFilter
    }
    
    public func setFauxMerkleMode() {
        assertSealed("SetFauxMerkleMode() on sealed BaseApp")
        self.fauxMerkleMode = true
    }

    // SetCommitMultiStoreTracer sets the store tracer on the BaseApp's underlying
    // CommitMultiStore.
    public func setCommitMultiStoreTracer(tracer: TextOutputStream) {
        self.commitMultiStore.set(tracer: tracer)
    }

    // SetStoreLoader allows us to customize the rootMultiStore initialization.
    public func setStoreLoader(loader: @escaping StoreLoader) {
        assertSealed("SetStoreLoader() on sealed BaseApp")
        self.storeLoader = loader
    }

    // SetRouter allows us to customize the router.
    public func SetRouter(router: Router) {
        assertSealed("SetRouter() on sealed BaseApp")
        self.router = router
    }
}
