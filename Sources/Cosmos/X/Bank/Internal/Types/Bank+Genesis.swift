// GenesisState is the bank state that must be provided at genesis.
struct BankGenesisState: Codable {
    let sendEnabled: Bool
    
    private enum CodingKeys: String, CodingKey {
        case sendEnabled = "send_enabled"
    }
    
    // NewGenesisState creates a new genesis state.
    init(sendEnabled: Bool) {
        self.sendEnabled = sendEnabled
    }
}

extension BankGenesisState {
    // DefaultGenesisState returns a default genesis state
    static var `default`: BankGenesisState {
        BankGenesisState(sendEnabled: true)
    }
}

