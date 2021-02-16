import Tendermint
import Cosmos

// GenesisState is the supply state that must be provided at genesis.
public struct SupplyGenesisState: Codable, AppState {
    static public  var metatype: String { "supply" }

    public var supply: Coins
    
    // NewGenesisState creates a new genesis state.
    public init(supply: Coins) {
        self.supply = supply
    }
}

extension SupplyGenesisState {
    // DefaultGenesisState returns a default genesis state
    static var `default`: SupplyGenesisState {
        SupplyGenesisState(supply: Supply.default.total)
    }
    
    public init(default:Void) {
        self.init(supply: Supply.default.total)
    }
}
