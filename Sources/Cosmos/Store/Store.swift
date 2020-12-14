import Database

func makeCommitMultiStore(database: Database) -> CommitMultiStore {
    RootMultiStore(database: database)
}
