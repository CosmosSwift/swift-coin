import Cosmos

extension NameServiceKeeper {
    // NewQuerier creates a new querier for nameservice clients.
    func makeQuerier() -> Querier {
        return { request, path, queryRequest in
            switch path[0] {
        // this line is used by starport scaffolding # 2
            case queryResolveName:
                return try resolveName(request: request, path: Array(path.dropFirst()))
            case queryGetWhois:
                return try getWhois(request: request, path: Array(path.dropFirst()))
            case queryListWhois:
                return listWhois(request: request)
            default:
                throw Cosmos.Error.unknownRequest(reason: "unknown nameservice query endpoint")
            }
        }
    }
}
