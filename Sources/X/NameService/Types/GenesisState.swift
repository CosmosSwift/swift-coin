import Cosmos
import Tendermint

// GenesisState - all nameservice state that must be provided at genesis
public struct GenesisState: Codable, AppState {
    
    static public var metatype: String { "nameservice" }

    let whoisRecords: [Whois]
}

extension GenesisState {
    // DefaultGenesisState - default GenesisState used by Cosmos Hub
    static var `default`: GenesisState {
        GenesisState(whoisRecords: [])
    }
    
    public init(default: Void) {
        self.init(whoisRecords: [])
    }
}

extension GenesisState {
    // ValidateGenesis validates the nameservice genesis parameters
    func validate() throws {
        // TODO: Create a sanity check to make sure the state conforms to the modules needs
        for record in whoisRecords {
            // TODO: check if it really makes sense to do this check.
//            if record.owner == nil {
//                throw Cosmos.Error.invalidGenesis(reason: "invalid WhoisRecord: Value: \(record.value). Error: Missing Owner")
//            }
            
            if record.value == "" {
                throw Cosmos.Error.invalidGenesis(reason: "invalid WhoisRecord: Owner: \(record.owner). Error: Missing Value")
            }
            
            // TODO: check if it really makes sense to do this check.
//            if record.price == nil {
//                throw Cosmos.Error.invalidGenesis(reason: "invalid WhoisRecord: Value: \(record.value). Error: Missing Price")
//            }
        }
    }
}
