// Router provides handlers for each transaction type.
public protocol Router: class {
    func addRoute(path: String, handler: @escaping Handler)
    func route(request: Request, path: String) -> Handler?
}

// QueryRouter provides queryables for each query path.
public protocol QueryRouter: class {
    func addRoute(path: String, querier: @escaping Querier)
    func route(path: String) -> Querier?
}
