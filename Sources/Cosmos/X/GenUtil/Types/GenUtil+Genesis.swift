import JSON

// GenesisState defines the raw genesis transaction in JSON
struct GenUtilGenesisState: Codable {
    let genesisTransactions: [JSON]
    
    private enum CodingKeys: String, CodingKey {
        case genesisTransactions = "gentxs"
    }
    
    // NewGenesisState creates a new GenesisState object
    internal init(genesisTransactions: [JSON]) {
        self.genesisTransactions = genesisTransactions
    }
}

extension GenUtilGenesisState {
    // DefaultGenesisState returns the genutil module's default genesis state.
    static var `default`: GenUtilGenesisState {
        GenUtilGenesisState(genesisTransactions: [])
    }
}
