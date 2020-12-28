import Foundation
import ABCI

extension AccountKeeper {
    // NewQuerier creates a querier for auth REST endpoints
    public func makeQuerier() -> Querier {
        return { request, path, queryRequest in
            switch path[0] {
            case AuthKeys.queryAccount:
                return try queryAccount(request: request, queryRequest: queryRequest)
            default:
                throw Cosmos.Error.unknownRequest(reason: "unknown query path: \(path[0])")
            }
        }
    }

    private func queryAccount(request: Request, queryRequest: RequestQuery) throws -> Data {
        do {
            let params: QueryAccountParams = try codec.unmarshalJSON(data: queryRequest.data)

            guard let account = self.account(request: request, address: params.address) else {
                throw Cosmos.Error.unknownAddress(reason: "account \(params.address) does not exist")
            }
            
            do {
                // TODO: Deal with this encoding protocol issue
                fatalError()
//                return try codec.mustMarshalJSONIndent(value: account)
            } catch {
                throw Cosmos.Error.jsonMarshal(error: error)
            }
        } catch {
            throw Cosmos.Error.jsonUnmarshal(error: error)
        }
    }
}
