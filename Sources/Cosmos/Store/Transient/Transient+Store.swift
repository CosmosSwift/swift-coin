import Database

// Store is a wrapper for a MemDB with Commiter implementation
final class TransientStore: DatabaseAdapterStore, CommitKeyValueStore {
    // Constructs new MemDB adapter
    init() {
        super.init(database: InMemoryDatabase())
    }

    // Implements CommitStore
    // Commit cleans up Store.
    func commit() -> CommitID {
        database = InMemoryDatabase()
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
