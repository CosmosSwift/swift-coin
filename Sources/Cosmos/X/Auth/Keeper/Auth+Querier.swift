import Foundation
import Tendermint
import ABCI

struct LocalQueryAccountParameters: Codable {
    let Address: String
}

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

        
        let parameters: LocalQueryAccountParameters
        
        do {
            parameters = try codec.unmarshalJSON(data: queryRequest.data)
        } catch {
            throw Cosmos.Error.jsonUnmarshal(error: error)
        }
        
        let address = try AccountAddress(bech32Encoded: parameters.Address)

        // TODO: this creates the address if it's missing.
        // TODO: this might not be the behaviour expected
        guard let account = self.account(request: request, address: address) else {
            throw Cosmos.Error.unknownAddress(reason: "account \(address) does not exist")
        }
        
        do {
            let value = AnyProtocolCodable(account)
            return try codec.marshalJSONIndent(value: value)
        } catch {
            throw Cosmos.Error.jsonMarshal(error: error)
        }
    }
}
