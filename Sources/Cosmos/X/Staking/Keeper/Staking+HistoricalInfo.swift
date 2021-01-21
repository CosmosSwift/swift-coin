extension StakingKeeper {
    /// GetHistoricalInfo gets the historical info at a given height
    func getHistoricalInfo(request: Request, height: Int64) -> HistoricalInfo? {
        let store = request.keyValueStore(key: storeKey)
        let key = historicalInfoKey(height: height)
        
        guard let data = store.get(key: key) else {
            return nil
        }
        
        return HistoricalInfo.mustUnmarshalHistoricalInfo(codec: codec, value: data)
    }

    /// SetHistoricalInfo sets the historical info at a given height
    func setHistoricalInfo(request: Request, height: Int64, historicalInfo: HistoricalInfo) {
        let store = request.keyValueStore(key: storeKey)
        let key = historicalInfoKey(height: height)
        let value = HistoricalInfo.mustMarshalHistoricalInfo(codec: codec, historicalInfo: historicalInfo)
        store.set(key: key, value: value)
    }

    /// DeleteHistoricalInfo deletes the historical info at a given height
    func deleteHistoricalInfo(request: Request, height: Int64) {
        let store = request.keyValueStore(key: storeKey)
        let key = historicalInfoKey(height: height)
        store.delete(key: key)
    }

    /// TrackHistoricalInfo saves the latest historical-info and deletes the oldest
    /// heights that are below pruning height
    func trackHistoricalInfo(request: Request) {
        let historicalEntries = self.historicalEntries(request: request)

        // Prune store to ensure we only have parameter-defined historical entries.
        // In most cases, this will involve removing a single historical entry.
        // In the rare scenario when the historical entries gets reduced to a lower value k'
        // from the original value k. k - k' entries must be deleted from the store.
        // Since the entries to be deleted are always in a continuous range, we can iterate
        // over the historical entries starting from the most recent version to be pruned
        // and then return at the first empty entry.
        for height in (0 ..< request.header.height - Int64(historicalEntries)).reversed() {
            guard getHistoricalInfo(request: request, height: height) != nil else {
               break
            }
            
            deleteHistoricalInfo(request: request, height: height)
        }

        // if there is no need to persist historicalInfo, return
        guard historicalEntries != 0 else {
            return
        }

        // Create HistoricalInfo struct
        let lastValidators = self.lastValidators(request: request)
        
        let historicalEntry = HistoricalInfo(
            header: request.header,
            validatorSet: lastValidators
        )

        // Set latest HistoricalInfo at current height
        setHistoricalInfo(
            request: request,
            height: request.header.height,
            historicalInfo: historicalEntry
        )
    }
}
