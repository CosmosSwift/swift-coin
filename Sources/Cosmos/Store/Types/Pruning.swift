// PruningOptions defines the pruning strategy used when determining which
// heights are removed from disk when committing state.
struct PruningOptions {
    // KeepRecent defines how many recent heights to keep on disk.
    let keepRecent: UInt64

    // KeepEvery defines how many offset heights are kept on disk past KeepRecent.
    let keepEvery: UInt64

    // Interval defines when the pruned heights are removed from disk.
    let interval: UInt64
    
    // PruneDefault defines a pruning strategy where the last 100 heights are kept
    // in addition to every 100th and where to-be pruned heights are pruned at
    // every 10th height.
    static let `default` = PruningOptions(keepRecent: 100, keepEvery: 100, interval: 10)

    // PruneEverything defines a pruning strategy where all committed heights are
    // deleted, storing only the current height and where to-be pruned heights are
    // pruned at every 10th height.
    static let everything = PruningOptions(keepRecent: 0, keepEvery: 0, interval: 10)

    // PruneNothing defines a pruning strategy where all heights are kept on disk.
    static let nothing = PruningOptions(keepRecent: 0, keepEvery: 1, interval: 0)
}
