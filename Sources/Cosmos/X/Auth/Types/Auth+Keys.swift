import Foundation

public enum AuthKeys {
    // module name
    public static let moduleName = "auth"

    // StoreKey is string representation of the store key for auth
    public static let storeKey = "acc"

    // FeeCollectorName the root string for the fee collector account address
    public static let feeCollectorName = "fee_collector"

    // QuerierRoute is the querier route for acc
    public static let querierRoute = storeKey
}

// AddressStoreKeyPrefix prefix for account-by-address store
let addressStoreKeyPrefix = Data([0x01])

// param key for global account number
let globalAccountNumberKey = "globalAccountNumber".data

// AddressStoreKey turn an address to key used to get it from the account store
func addressStoreKey(address: AccountAddress) -> Data {
    addressStoreKeyPrefix + address.data
}
