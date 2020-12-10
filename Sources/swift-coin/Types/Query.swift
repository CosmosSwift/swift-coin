let queryListWhois = "list-whois"
let queryGetWhois = "get-whois"
let queryResolveName = "resolve-name"

// QueryResultResolve Queries Result Payload for a resolve query
struct QueryResultResolve: Codable {
    let value: String
}

// QueryResultNames Queries Result Payload for a names query
typealias QueryResultNames = [String]
