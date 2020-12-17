public struct QueryRouter {
    let routes: [String: Querier]
    
    // NewQueryRouter returns a reference to a new QueryRouter.
    init() {
        self.routes = [:]
    }
}

