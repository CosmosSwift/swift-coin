public enum StakingKeys {
    // ModuleName is the name of the staking module
    public static let moduleName = "staking"

    // StoreKey is the string store representation
    public static let storeKey = moduleName

    // TStoreKey is the string transient store representation
    public static let transientStoreKey = "transient_" + moduleName

    // QuerierRoute is the querier route for the staking module
    public static let querierRoute = moduleName

    // RouterKey is the msg router key for the staking module
    public static let routerKey = moduleName
}
