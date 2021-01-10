// GenesisState - all auth state that must be provided at genesis
struct AuthGenesisState: Codable {
    let parameters: AuthParameters
    let accounts: GenesisAccounts
    
    private enum CodingKeys: String, CodingKey {
        case parameters = "params"
        case accounts
    }
    
    // NewGenesisState - Create a new genesis state
    internal init(parameters: AuthParameters, accounts: GenesisAccounts) {
        self.parameters = parameters
        self.accounts = accounts
    }
    
    init(from decoder: Decoder) throws {
        // TODO: Implement
        fatalError()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(parameters, forKey: .parameters)
        // TODO: Implement
//        try container.encode(accounts, forKey: .accounts)
    }
}

extension AuthGenesisState {
    // DefaultGenesisState - Return a default genesis state
    static var `default`: AuthGenesisState {
        AuthGenesisState(
            parameters: .default,
            accounts: GenesisAccounts()
        )
    }
}
