import ABCI

extension BaseApp: ABCIApplication {
    public func echo(request: RequestEcho) -> ResponseEcho {
        // TODO: Implement
        fatalError()
    }
    
    public func info(request: RequestInfo) -> ResponseInfo {
        // TODO: Implement
        fatalError()
    }
    
    public func initChain(request: RequestInitChain) -> ResponseInitChain {
        // TODO: Implement
        fatalError()
    }
    
    public func query(request: RequestQuery) -> ResponseQuery {
        // TODO: Implement
        fatalError()
    }
    
    public func beginBlock(request: RequestBeginBlock) -> ResponseBeginBlock {
        // TODO: Implement
        fatalError()
    }
    
    public func checkTx(request: RequestCheckTx) -> ResponseCheckTx {
        // TODO: Implement
        fatalError()
    }
    
    public func deliverTx(request: RequestDeliverTx) -> ResponseDeliverTx {
        // TODO: Implement
        fatalError()
    }
    
    public func endBlock(request: RequestEndBlock) -> ResponseEndBlock {
        // TODO: Implement
        fatalError()
    }
    
    public func commit() -> ResponseCommit {
        // TODO: Implement
        fatalError()
    }
    
    public func listSnapshots() -> ResponseListSnapshots {
        // TODO: Implement
        fatalError()
    }
    
    public func offerSnapshot(request: RequestOfferSnapshot) -> ResponseOfferSnapshot {
        // TODO: Implement
        fatalError()
    }
    
    public func loadSnapshotChunk(request: RequestLoadSnapshotChunk) -> ResponseLoadSnapshotChunk {
        // TODO: Implement
        fatalError()
    }
    
    public func applySnapshotChunk(request: RequestApplySnapshotChunk) -> ResponseApplySnapshotChunk {
        // TODO: Implement
        fatalError()
    }
}
