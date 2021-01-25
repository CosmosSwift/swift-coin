import Tendermint

// GenesisState - all auth state that must be provided at genesis
public struct AuthGenesisState: Codable, AppState {
    static public var metatype: String { "auth" }

    public var parameters: AuthParameters
    public var accounts: [BaseAccount]
    
    private enum CodingKeys: String, CodingKey {
        case parameters = "params"
        case accounts
    }
    
    // NewGenesisState - Create a new genesis state
    internal init(parameters: AuthParameters, accounts: [BaseAccount]) {
        self.parameters = parameters
        self.accounts = accounts
    }
    
//    public init(from decoder: Decoder) throws {
//        // TODO: Implement
//        fatalError()
//    }
    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(parameters, forKey: .parameters)
//        // TODO: Implement
////        try container.encode(accounts, forKey: .accounts)
//    }
}

extension AuthGenesisState {
    // DefaultGenesisState - Return a default genesis state
    static var `default`: AuthGenesisState {
        AuthGenesisState(
            parameters: .default,
            accounts: []
        )
    }
    
    public init(default:Void) {
        self.init(
            parameters: .default,
            accounts: []
        )
    }
}
