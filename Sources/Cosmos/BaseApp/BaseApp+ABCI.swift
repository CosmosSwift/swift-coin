import ABCI

extension BaseApp: ABCIApplication {
    // InitChain implements the ABCI interface. It runs the initialization logic
    // directly on the CommitMultiStore.
    public func initChain(request: RequestInitChain) -> ResponseInitChain {
        var request = request
        // stash the consensus params in the cms main store and memoize
        // TODO: consensusParams is not optional.
        // Check why this check exists
//        if let consensusParams = request.consensusParams {
        set(consensusParams: request.consensusParams)
        store(consensusParams: request.consensusParams)
//        }

        let initHeader = Header( 
            chainID: request.chainID,
            time: request.time
        )

        // initialize the deliver state and check state with a correct header
        set(deliverState: initHeader)
        set(checkState: initHeader)

        guard let initChainer = self.initChainer else {
            return ResponseInitChain()
        }

        // TODO: Find best way to deal with force unwraps
        // add block gas meter for any genesis transactions (allow infinite gas)
        deliverState!.request.blockGasMeter = InfiniteGasMeter()
        var response = initChainer(deliverState!.request, request)

        // sanity check
        if !request.validators.isEmpty {
            guard request.validators.count == response.validators.count else {
                fatalError("len(RequestInitChain.Validators) != len(GenesisValidators) (\(request.validators.count) != \(response.validators.count)")
            }
            
            request.validators.sort()
            response.validators.sort()

            for (i, validator) in response.validators.enumerated() {
                guard validator == request.validators[i] else {
                    fatalError("genesisValidators[\(i)] != req.Validators[\(i)]")
                }
            }
        }

        // NOTE: We don't commit, but BeginBlock for block 1 starts from this
        // deliverState.
        return response
    }
    // Info implements the ABCI interface.
    public func info(request: RequestInfo) -> ResponseInfo {
        guard let lastCommitID = commitMultiStore.lastCommitID else {
            return ResponseInfo(data: name)
        }

        return ResponseInfo(
            data: name,
            lastBlockHeight: lastCommitID.version,
            lastBlockAppHash: lastCommitID.hash
        )
    }

    public func query(request: RequestQuery) -> ResponseQuery {
        // TODO: Implement
        fatalError()
    }
    
    // BeginBlock implements the ABCI application interface.
    public func beginBlock(request: RequestBeginBlock) -> ResponseBeginBlock {
        if commitMultiStore.isTracingEnabled {
            commitMultiStore.set(tracingContext: [
                "blockHeight": request.header.height,
            ])
        }

        do {
            try validateHeight(request: request)
        } catch {
            fatalError("\(error)")
        }

        // Initialize the DeliverTx state. If this is the first block, it should
        // already be initialized in InitChain. Otherwise app.deliverState will be
        // nil, since it is reset on Commit.
        if let deliverState = deliverState {
            // In the first block, app.deliverState.ctx will already be initialized
            // by InitChain. Context is now updated with Header information.
            deliverState.request.header = request.header
            // TODO: This call seems pointless, check later.
            deliverState.request.header.height = request.header.height
        } else {
            set(deliverState: request.header)
        }

        // add block gas meter
        let gasMeter: GasMeter

        if maximumBlockGas > 0 {
            gasMeter = BasicGasMeter(limit: maximumBlockGas)
        } else {
            gasMeter = InfiniteGasMeter()
        }
        
        guard let deliverState = self.deliverState else {
            fatalError("deliverState should be set by now")
        }

        deliverState.request.blockGasMeter = gasMeter
        var response = ResponseBeginBlock()
        
        if let beginBlocker = self.beginBlocker {
            response = beginBlocker(deliverState.request, request)
        }

        // set the signed validators for addition to context in deliverTx
        voteInfo = request.lastCommitInfo.votes
        return response
    }
    
    // EndBlock implements the ABCI interface.
    public func endBlock(request: RequestEndBlock) -> ResponseEndBlock {
        guard let deliverState = self.deliverState else {
            return ResponseEndBlock()
        }
        
        if deliverState.multiStore.isTracingEnabled {
            deliverState.multiStore.set(tracingContext: [:])
        }

        if let endBlocker = self.endBlocker {
            return endBlocker(deliverState.request, request)
        }

        return ResponseEndBlock()
    }

    // CheckTx implements the ABCI interface and executes a tx in CheckTx mode. In
    // CheckTx mode, messages are not executed. This means messages are only validated
    // and only the AnteHandler is executed. State is persisted to the BaseApp's
    // internal CheckTx state if the AnteHandler passes. Otherwise, the ResponseCheckTx
    // will contain releveant error information. Regardless of tx execution outcome,
    // the ResponseCheckTx will contain relevant gas execution context.
    public func checkTx(request: RequestCheckTx) -> ResponseCheckTx {
        let transaction: Transaction
            
        do {
            transaction = try transactionDecoder(request.tx)
        } catch {
            return ResponseCheckTx(error: error, gasWanted: 0, gasUsed: 0, debug: trace)
        }

        var mode: RunTransactionMode

        switch request.type {
        case .new:
            mode = .check
        case .recheck:
            mode = .recheck
        default:
            fatalError("unknown RequestCheckTx type: \(request.type)")
        }
        
        // TODO: Implement
        fatalError()
//        do {
//            let (gInfo, result) = try runTransaction(mode, request.tx, transaction)
//        } catch {
//            return ResponseCheckTx(error: error, gasWanted: gInfo.gasWanted, gasUsed: gInfo.gasUsed, debug: trace)
//        }
//
//        return ResponseCheckTx(
//            gasWanted: Int64(gInfo.GasWanted), // TODO: Should type accept unsigned ints?
//            gasUsed:   Int64(gInfo.GasUsed),   // TODO: Should type accept unsigned ints?
//            log:       result.log,
//            data:      result.data,
//            events:    result.events.abciEvents(),
//        }
    }

    public func deliverTx(request: RequestDeliverTx) -> ResponseDeliverTx {
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
