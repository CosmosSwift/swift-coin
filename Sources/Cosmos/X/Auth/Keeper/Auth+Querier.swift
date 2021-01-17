import Foundation
import ABCI

extension AccountKeeper {
    // NewQuerier creates a querier for auth REST endpoints
    public func makeQuerier() -> Querier {
        return { request, path, queryRequest in
            switch path[0] {
            case AuthKeys.queryAccount:
                // TODO: Deal with the generics
                return try queryAccount(of: BaseAccount.self, request: request, queryRequest: queryRequest)
            default:
                throw Cosmos.Error.unknownRequest(reason: "unknown query path: \(path[0])")
            }
        }
    }

    private func queryAccount<A: Account>(of type: A.Type, request: Request, queryRequest: RequestQuery) throws -> Data {
        let parameters: QueryAccountParameters
        
        do {
            parameters = try codec.unmarshalJSON(data: queryRequest.data)
        } catch {
            throw Cosmos.Error.jsonUnmarshal(error: error)
        }

        guard let account: A = self.account(request: request, address: parameters.address) else {
            throw Cosmos.Error.unknownAddress(reason: "account \(parameters.address) does not exist")
        }
        
        do {
            return try codec.marshalJSONIndent(value: account)
        } catch {
            throw Cosmos.Error.jsonMarshal(error: error)
        }
    }
}
