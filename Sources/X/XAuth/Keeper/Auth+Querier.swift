import Foundation
import Tendermint
import ABCI
import Cosmos

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
        let parameters: QueryAccountParameters
        
        do {
            parameters = try codec.unmarshalJSON(data: queryRequest.data)
        } catch {
            throw Cosmos.Error.jsonUnmarshal(error: error)
        }
        
        // TODO: this creates the address if it's missing.
        // TODO: this might not be the behaviour expected
        guard let account = self.account(request: request, address: parameters.address) else {
            throw Cosmos.Error.unknownAddress(reason: "account \(parameters.address) does not exist")
        }
        
        do {
            let value = AnyProtocolCodable(account)
            return try codec.marshalJSONIndent(value: value)
        } catch {
            throw Cosmos.Error.jsonMarshal(error: error)
        }
    }
}
