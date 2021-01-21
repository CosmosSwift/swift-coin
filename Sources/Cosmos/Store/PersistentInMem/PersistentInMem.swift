import Database

// Store is a wrapper for a MemDB with Commiter implementation
// This store is a temporary In Mem store which doesn't reset after a commit
// (unlike the TransientStore)
final class PersistentInMemStore: DatabaseAdapterStore, CommitKeyValueStore {
    // Constructs new MemDB adapter
    init() {
        super.init(database: InMemoryDatabase())
    }

    // Implements CommitStore
    // Commit cleans up Store.
    func commit() -> CommitID {
        return CommitID()
    }

    // Implements CommitStore
    var lastCommitID: CommitID? {
        CommitID()
    }

    // Implements Store.
    override var storeType: StoreType {
        .transient
    }
}
