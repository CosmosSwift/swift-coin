// Keeper of the supply store
public struct SupplyKeeper {
    // TODO: Implement
    let codec: Codec
    let storeKey: StoreKey
    let accountKeeper: AccountKeeper
    let bankKeeper: BankKeeper
    let permissionAddresses: [String: PermissionsForAddress]
    
    public init(
        codec: Codec,
        storeKey: StoreKey,
        accountKeeper: AccountKeeper,
        bankKeeper: BankKeeper,
        moduleAccountPermissions: [String: [String]]
    ) {
        // set the addresses
        var permissionAddresses: [String: PermissionsForAddress] = [:]
        
        for (name, permissions) in moduleAccountPermissions {
            permissionAddresses[name] = PermissionsForAddress(name: name, permissions: permissions)
        }
        
        self.codec = codec
        self.storeKey = storeKey
        self.accountKeeper = accountKeeper
        self.bankKeeper = bankKeeper
        self.permissionAddresses = permissionAddresses
    }
}
