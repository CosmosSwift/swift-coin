public struct Router {
    let routes: [String: Handler]
    
    // NewRouter returns a reference to a new router.
    init() {
        self.routes = [:]
    }
}
