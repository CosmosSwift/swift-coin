// GenesisState is the supply state that must be provided at genesis.
struct SupplyGenesisState: Codable {
    let supply: Coins
    
    // NewGenesisState creates a new genesis state.
    init(supply: Coins) {
        self.supply = supply
    }
}

extension SupplyGenesisState {
    // DefaultGenesisState returns a default genesis state
    static var `default`: SupplyGenesisState {
        SupplyGenesisState(supply: Supply.default.total)
    }
}
