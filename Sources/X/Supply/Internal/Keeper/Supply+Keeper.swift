import Cosmos
import Auth
import Bank

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
    
    // GetSupply retrieves the Supply from store
    func supply(request: Request) -> Supply {
        let store = request.keyValueStore(key: storeKey)
        
        guard let data = store.get(key: SupplyKeys.supplyKey) else {
            fatalError("stored supply should not have been nil")
        }
        
        return codec.mustUnmarshalBinaryLengthPrefixed(data: data)
    }
    
    func setSupply(request: Request, supply: Coins) {
        let store = request.keyValueStore(key: storeKey)
        let data = codec.mustMarshalBinaryLengthPrefixed(value: supply)
        
        store.set(key: SupplyKeys.supplyKey, value: data)
    }
}
