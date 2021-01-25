import JSON
import Tendermint

// GenesisState defines the raw genesis transaction in JSON
public struct GenUtilGenesisState: Codable, AppState {
    static public var metatype: String { "genutil" }

    public let genesisTransactions: [JSON]
    
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
    
    public init(default:Void) {
        self.init(genesisTransactions: [])
    }
}
