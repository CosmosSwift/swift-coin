// TODO: Maybe refactor this into a more generic raw value type
enum Keys {
    // moduleName is the name of the module
    static let moduleName = "nameservice"

    // storeKey to be used when creating the KVStore
    static let storeKey = moduleName

    // routerKey to be used for routing msgs
    static let routerKey = moduleName

    // querierRoute to be used for querier msgs
    static let querierRoute = moduleName

    static let whoisPrefix = "whois-"
}
