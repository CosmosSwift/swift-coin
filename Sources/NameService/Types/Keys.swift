// TODO: Maybe refactor this into a more generic raw value type
public enum NameServiceKeys {
    // moduleName is the name of the module
    public static let moduleName = "nameservice"

    // storeKey to be used when creating the KVStore
    public static let storeKey = moduleName

    // routerKey to be used for routing msgs
    public static let routerKey = moduleName

    // querierRoute to be used for querier msgs
    public static let querierRoute = moduleName

    public static let whoisPrefix = "whois-"
}
