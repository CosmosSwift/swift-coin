import Foundation
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
        guard let deliverState = self.deliverState else {
            fatalError("deliverState should be set by now")
        }
        
        // add block gas meter for any genesis transactions (allow infinite gas)
        deliverState.request.blockGasMeter = InfiniteGasMeter()
        var response = initChainer(deliverState.request, request)

        // sanity check
        // TODO: Implement
//        if !request.validators.isEmpty {
//            guard request.validators.count == response.validators.count else {
//                fatalError("len(RequestInitChain.Validators) != len(GenesisValidators) (\(request.validators.count) != \(response.validators.count)")
//            }
//
//            request.validators.sort()
//            response.validators.sort()
//
//            for (i, validator) in response.validators.enumerated() {
//                guard validator == request.validators[i] else {
//                    fatalError("genesisValidators[\(i)] != req.Validators[\(i)]")
//                }
//            }
//        }

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
    
    // FilterPeerByAddrPort filters peers by address/port.
    private func filterPeer(byAddressPort info: String) -> ResponseQuery {
        if let filter = addressPeerFilter {
            return filter(info)
        }
        
        return ResponseQuery()
    }

    // FilterPeerByIDfilters peers by node ID.
    func filterPeer(byID info: String) -> ResponseQuery {
        if let filter = idPeerFilter {
            return filter(info)
        }
        
        return ResponseQuery()
    }

    // BeginBlock implements the ABCI application interface.
    public func beginBlock(request: RequestBeginBlock) -> ResponseBeginBlock {
        if commitMultiStore.isTracingEnabled {
            commitMultiStore.set(tracingContext: [
                "blockHeight": request.header.height,
            ])
        }

        try! validateHeight(request: request)

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
        
        let (gasInfo, result) = runTransaction(
            mode: mode,
            transactionData: request.tx,
            transaction: transaction
        )
       
        do {
            let result = try result.get()
            
            return ResponseCheckTx(
                data: result.data,
                log: result.log,
                gasWanted: Int64(gasInfo.gasWanted), // TODO: Should type accept unsigned ints?
                gasUsed: Int64(gasInfo.gasUsed), // TODO: Should type accept unsigned ints?
                events: result.events
            )
        } catch {
            return ResponseCheckTx(
                error: error,
                gasWanted: gasInfo.gasWanted,
                gasUsed: gasInfo.gasUsed,
                debug: trace
            )
        }
    }
    
    // DeliverTx implements the ABCI interface and executes a tx in DeliverTx mode.
    // State only gets persisted if all messages are valid and get executed successfully.
    // Otherwise, the ResponseDeliverTx will contain releveant error information.
    // Regardless of tx execution outcome, the ResponseDeliverTx will contain relevant
    // gas execution context.
    public func deliverTx(request: RequestDeliverTx) -> ResponseDeliverTx {
        let transaction: Transaction
       
        do {
            transaction = try transactionDecoder(request.tx)
        } catch {
            return ResponseDeliverTx(
                error: error,
                gasWanted: 0,
                gasUsed: 0,
                debug: trace
            )
        }

        let (gasInfo, result) = runTransaction(mode: .deliver, transactionData: request.tx, transaction: transaction)
        
        do {
            let result = try result.get()
            
            return ResponseDeliverTx(
                data:      result.data,
                log:       result.log,
                gasWanted: Int64(gasInfo.gasWanted), // TODO: Should type accept unsigned ints?
                gasUsed:   Int64(gasInfo.gasUsed),   // TODO: Should type accept unsigned ints?
                events:    result.events
            )
        } catch {
            return ResponseDeliverTx(
                error: error,
                gasWanted: gasInfo.gasWanted,
                gasUsed: gasInfo.gasUsed,
                debug: trace
            )
        }

    }
    
    // Commit implements the ABCI interface. It will commit all state that exists in
    // the deliver state's multi-store and includes the resulting commit ID in the
    // returned abci.ResponseCommit. Commit will set the check state based on the
    // latest header and reset the deliver state. Also, if a non-zero halt height is
    // defined in config, Commit will execute a deferred function call to check
    // against that height and gracefully halt if it matches the latest committed
    // height.
    public func commit() -> ResponseCommit {
        guard let deliverState = self.deliverState else {
            fatalError("deliverState should be set by now")
        }
        
        let header = deliverState.request.header

        // Write the DeliverTx state which is cache-wrapped and commit the MultiStore.
        // The write to the DeliverTx state writes all state transitions to the root
        // MultiStore (app.cms) so when Commit() is called is persists those values.
        deliverState.multiStore.write()
        guard let commitID = try? commitMultiStore.commit() else {
            fatalError("Enable to commit multistore")
        }
        logger.debug("Commit synced.\ncommit: \(commitID)")

        // Reset the Check state to the latest committed.
        //
        // NOTE: This is safe because Tendermint holds a lock on the mempool for
        // Commit. Use the header from this latest block.
        set(checkState: header)

        // empty/reset the deliver state
        self.deliverState = nil

        var halt: Bool = false

        if haltHeight > 0 && UInt64(header.height) >= haltHeight {
            halt = true
        }

        // Check haltTime type, maybe TimeInterval makes more sense.
        if haltTime > 0 && header.time.timeIntervalSince1970 >= TimeInterval(haltTime) {
            halt = true
        }

        if halt {
            // Halt the binary and allow Tendermint to receive the ResponseCommit
            // response with the commit ID hash. This will allow the node to successfully
            // restart and process blocks assuming the halt configuration has been
            // reset or moved to a more distant value.
            self.halt()
        }

        return ResponseCommit(data: commitID.hash)
    }
    
    // halt attempts to gracefully shutdown the node via SIGINT and SIGTERM falling
    // back on os.Exit if both fail.
    private func halt() {
        logger.info("Halting node per configuration.\nheight: \(haltHeight)\ntime: \(haltTime)")

        // TODO: Find out how to implement this in Swift
//        let p = findProcess(os.getpid())
//
//        if err == nil {
//            // attempt cascading signals in case SIGINT fails (os dependent)
//            sigIntErr := process.signal(syscall.SIGINT)
//            sigTermErr := process.signal(syscall.SIGTERM)
//
//            if sigIntErr == nil || sigTermErr == nil {
//                return
//            }
//        }

        // Resort to exiting immediately if the process could not be found or killed
        // via SIGINT/SIGTERM signals.
        logger.info("failed to send SIGINT/SIGTERM; exiting...")
        exit(0)
    }

    // Query implements the ABCI interface. It delegates to CommitMultiStore if it
    // implements Queryable.
    public func query(request: RequestQuery) -> ResponseQuery {
        let path = split(path: request.path)
        
        guard !path.isEmpty else {
            return ResponseQuery(
                error: CosmosError.wrap(error: CosmosError.unknownRequest, description: "no query path provided")
            )
        }

        switch path[0] {
        // "/app" prefix for special application queries
        case "app":
            return handleQueryApp(path: path, request: request)

        case "store":
            return handleQueryStore(path: path, request: request)

        case "p2p":
            return handleQueryP2P(path: path)

        case "custom":
            return handleQueryCustom(path: path, request: request)
            
        default:
            return ResponseQuery(
                error: CosmosError.wrap(error: CosmosError.unknownRequest, description: "unknown query path")
            )
        }
    }

    func handleQueryApp(path: [Substring], request: RequestQuery) -> ResponseQuery {
        if path.count >= 2 {
            switch path[1] {
            case "simulate":
                let transactionData = request.data

                let transaction: Transaction
                
                do {
                    transaction = try transactionDecoder(transactionData)
                } catch {
                    return ResponseQuery(
                        error: CosmosError.wrap(error: error, description: "failed to decode tx")
                    )
                }

                let gasInfo: GasInfo
                let result: Result
                 
                do {
                    let (simulateGasInfo, simulateResult) = simulate(
                        transactionData: transactionData,
                        transaction: transaction
                    )
                    
                    gasInfo = simulateGasInfo
                    result = try simulateResult.get()
                } catch {
                    return ResponseQuery(
                        error: CosmosError.wrap(error: error, description: "failed to simulate tx")
                    )
                }

                let simulationResponse = SimulationResponse(
                    gasInfo: gasInfo,
                    result: result
                )

                return ResponseQuery(
                    value: Codec.codec.mustMarshalBinaryBare(value: simulationResponse),
                    height: request.height,
                    codespace: CosmosError.rootCodespace
                )

            case "version":
                return ResponseQuery(
                    value: appVersion.data,
                    height: request.height,
                    codespace: CosmosError.rootCodespace
                )

            default:
                return ResponseQuery(
                    error: CosmosError.wrap(
                        error: CosmosError.unknownRequest,
                        description: "unknown query: \(path)"
                    )
                )
            }
        }

        return ResponseQuery(
            error: CosmosError.wrap(
                error: CosmosError.unknownRequest,
                description: "expected second parameter to be either 'simulate' or 'version', neither was present"
            )
        )
    }

    func handleQueryStore(path: [Substring], request: RequestQuery) -> ResponseQuery {
        // "/store" prefix for store queries
        guard let queryable = commitMultiStore as? Queryable else {
            return ResponseQuery(
                error: CosmosError.wrap(
                    error: CosmosError.unknownRequest,
                    description: "multistore doesn't support queries"
                )
            )
        }

        var request = request
        request.path = "/" + path.suffix(from: 1).joined(separator: "/")

        // when a client did not provide a query height, manually inject the latest
        if request.height == 0 {
            // TODO: Maybe this should fatalError?
            request.height = lastBlockHeight ?? 0
        }

        if request.height <= 1 && request.prove {
            return ResponseQuery(
                error: CosmosError.wrap(
                    error: CosmosError.invalidRequest,
                    description: "cannot query with proof when height <= 1; please provide a valid height"
                )
            )
        }

        var response = queryable.query(queryRequest: request)
        response.height = request.height
        return response
    }

    func handleQueryP2P(path: [Substring]) -> ResponseQuery {
        // "/p2p" prefix for p2p queries
        if path.count >= 4 {
            let command = path[1]
            let type = path[2]
            let argument = path[3]
            
            switch command {
            case "filter":
                switch type {
                case "addr":
                    return filterPeer(byAddressPort: String(argument))

                case "id":
                    return filterPeer(byID: String(argument))
                default:
                    break
                }

            default:
                return ResponseQuery(
                    error: CosmosError.wrap(
                        error: CosmosError.unknownRequest,
                        description: "expected second parameter to be 'filter'"
                    )
                )
            }
        }

        return ResponseQuery(
            error: CosmosError.wrap(
                error: CosmosError.unknownRequest,
                description: "expected path is p2p filter <addr|id> <parameter>"
            )
        )
    }

    func handleQueryCustom(path: [Substring], request: RequestQuery) -> ResponseQuery {
        // path[0] should be "custom" because "/custom" prefix is required for keeper
        // queries.
        //
        // The QueryRouter routes using path[1]. For example, in the path
        // "custom/gov/proposal", QueryRouter routes using "gov".
        if path.count < 2 || path[1] == "" {
            return ResponseQuery(
                error: CosmosError.wrap(
                    error: CosmosError.unknownRequest,
                    description: "no route for custom query specified"
                )
            )
        }

        // TODO: Maybe change route's path parameter to Substring
        guard let querier = queryRouter.route(path: String(path[1])) else {
            return ResponseQuery(
                error: CosmosError.wrap(
                    error: CosmosError.unknownRequest,
                    description: "no custom querier found for route \(path[1])"
                )
            )
        }
        
        var request = request

        // when a client did not provide a query height, manually inject the latest
        if request.height == 0 {
            // TODO: Maybe this should fatalError if nil?
            request.height = lastBlockHeight ?? 0
        }

        if request.height <= 1 && request.prove {
            return ResponseQuery(
                error: CosmosError.wrap(
                    error: CosmosError.invalidRequest,
                    description: "cannot query with proof when height <= 1; please provide a valid height"
                )
            )
        }

        let cacheMultiStore: MultiStore
            
        do {
            cacheMultiStore = try commitMultiStore.cacheMultiStore(withVersion: request.height)
        } catch {
            return ResponseQuery(
                error: CosmosError.wrap(
                    error: CosmosError.invalidRequest,
                    description: "failed to load state at height \(request.height); \(error) (latest height: \(lastBlockHeight ?? 0))"
                )
            )
        }
        
        guard let checkState = self.checkState else {
            fatalError("checkState should be set by now")
        }

        // cache wrap the commit-multistore for safety
        let cachedRequest = Request(
            multiStore: cacheMultiStore,
            header: checkState.request.header,
            isCheckTransaction: true,
            logger: logger
        )
        
        // TODO: Maybe minGasPrices can be not optional?
        cachedRequest.minGasPrices = self.minGasPrices ?? DecimalCoins()

        // Passes the rest of the path as an argument to the querier.
        //
        // For example, in the path "custom/gov/proposal/test", the gov querier gets
        // []string{"proposal", "test"} as the path.
        do {
            let responseData = try querier(
                cachedRequest,
                // TODO: Maybe change querier's path parameter to [Substring]
                path.suffix(from: 2).map(String.init),
                request
            )
            
            return ResponseQuery(
                value: responseData,
                height: request.height
            )
        } catch {
            let (space, code, log) = abciInfo(error: error, debug: false)
            
            return ResponseQuery(
                code: code,
                log: log,
                height: request.height,
                codespace: space
            )
        }
    }

    // splitPath splits a string path using the delimiter '/'.
    //
    // e.g. "this/is/funny" becomes []string{"this", "is", "funny"}
    func split(path requestPath: String) -> [Substring] {
        let path = requestPath.split(separator: "/")

        // first element is empty string
        if !path.isEmpty && path[0] == "" {
            return Array(path.dropFirst())
        }

        return path
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
