import Tendermint

// ModuleAccount defines an account for modules that holds coins on a pool
public final class ModuleAccount: BaseAccount {
    // name of the module
    let name: String
    // permissions of module account
    let permissions: [String]
    
    // NewEmptyModuleAccount creates a empty ModuleAccount from a string
    public init(name: String, permissions: [String]) {
        let moduleAddress = ModuleAccount.moduleAddress(name: name)

        do {
            try SupplyPermissions.validate(permissions: permissions)
        } catch {
            fatalError("\(error)")
        }
        
        self.name = name
        self.permissions = permissions
        super.init(address: moduleAddress)
    }

}


// TODO: Rethink where best to put this function
extension ModuleAccount {
    // NewModuleAddress creates an AccAddress from the hash of the module's name
    public static func moduleAddress(name: String) -> AccountAddress {
        AccountAddress(data: Crypto.addressHash(data: name.data))
    }
}
