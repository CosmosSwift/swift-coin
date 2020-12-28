extension BaseApp {
    public final class Router: Cosmos.Router {
        private var routes: [String: Handler] = [:]
        
        // NewRouter returns a reference to a new router.
        init() {}

        // AddRoute adds a route path to the router with a given handler. The route must
        // be alphanumeric.
        public func addRoute(path: String, handler: @escaping Handler) {
            guard path.isAlphaNumeric else {
                fatalError("route expressions can only contain alphanumeric characters")
            }
            
            guard routes[path] == nil else {
                fatalError("route \(path) has already been initialized")
            }

            routes[path] = handler
        }
        
        // Route returns a handler for a given route path.
        //
        // TODO: Handle expressive matches.
        public func route(request: Request, path: String) -> Handler? {
            routes[path]
        }
    }
}
