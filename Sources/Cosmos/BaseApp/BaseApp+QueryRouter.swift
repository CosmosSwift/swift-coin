extension BaseApp {
    public final class QueryRouter: Cosmos.QueryRouter {
        private var routes: [String: Querier] = [:]
    
        // NewQueryRouter returns a reference to a new QueryRouter.
        init() {}
        
        // AddRoute adds a query path to the router with a given Querier. It will panic
        // if a duplicate route is given. The route must be alphanumeric.
        public func addRoute(path: String, querier: @escaping Querier) {
            guard path.isAlphaNumeric else {
                fatalError("route expressions can only contain alphanumeric characters")
            }
            
            guard routes[path] == nil else {
                fatalError("route \(path) has already been initialized")
            }

            routes[path] = querier
        }
        
        // Route returns the Querier for a given query route path.
        public func route(path: String) -> Querier? {
            routes[path]
        }
    }
}
