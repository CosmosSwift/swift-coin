// GenesisState is the bank state that must be provided at genesis.
public struct BankGenesisState: Codable {
    let isSendEnabled: Bool
    
    private enum CodingKeys: String, CodingKey {
        case isSendEnabled = "send_enabled"
    }
    
    // NewGenesisState creates a new genesis state.
    init(isSendEnabled: Bool) {
        self.isSendEnabled = isSendEnabled
    }
}

public extension BankGenesisState {
    // DefaultGenesisState returns a default genesis state
    static var `default`: BankGenesisState {
        BankGenesisState(isSendEnabled: true)
    }
}

