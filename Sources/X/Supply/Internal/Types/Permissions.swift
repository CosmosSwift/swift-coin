import Cosmos

// TODO: Maybe create another type insted
// permissions
public enum SupplyPermissions {
    public static let minter  = "minter"
    public static let burner  = "burner"
    public static let staking = "staking"
}

// PermissionsForAddress defines all the registered permissions for an address
struct PermissionsForAddress {
    let permissions: [String]
    let address: AccountAddress
    
    init(name: String, permissions: [String]) {
        self.permissions = permissions
        self.address = ModuleAccount.moduleAddress(name: name)
    }
}

extension SupplyPermissions {
    // performs basic permission validation
    static func validate(permissions: [String]) throws {
        for permission in permissions {
            guard !permission.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw Cosmos.Error.generic(reason: "module permission is empty")
            }
        }
    }
}
