//----------------------------------------
// commitDBStoreWrapper should only be used for simulation/debugging,
// as it doesn't compute any commit hash, and it cannot load older state.
final class CommitDatabaseAdapterStore: DatabaseAdapterStore {}

extension CommitDatabaseAdapterStore: CommitKeyValueStore {
    static let commitHash = "FAKE_HASH".data
    
    func commit() -> CommitID {
        CommitID(version: -1, hash: Self.commitHash)
    }
    
    var lastCommitID: CommitID? {
        CommitID(version: -1, hash: Self.commitHash)
    }
}
