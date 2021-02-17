import Foundation
import ABCIMessages
import Cosmos

extension BankKeys {
    // query balance path
    static let queryBalance = "balances"
}

extension BankKeeper {
    // NewQuerier returns a new sdk.Keeper instance.
    func makeQuerier() -> Querier {
        return { request, path, queryRequest in
            switch path[0] {
            case BankKeys.queryBalance:
                return try queryBalance(request: request, queryRequest: queryRequest)
            default:
                throw Cosmos.Error.unknownRequest(reason: "unknown query path: \(path[0])")
            }
        }
    }

    // queryBalance fetch an account's balance for the supplied height.
    // Height and account address are passed as first and second path components respectively.
    func queryBalance(request: Request, queryRequest: RequestQuery<Data>) throws -> Data {
        do {
            let params: QueryBalanceParams = try Codec.bankCodec.unmarshalJSON(data: queryRequest.data)
            let coins = self.coins(request: request, address: params.address) ?? Coins()
            
            do {
                return try Codec.bankCodec.marshalJSONIndent(value: coins)
            } catch {
                throw Cosmos.Error.jsonMarshal(error: error)
            }
        } catch {
            throw Cosmos.Error.jsonUnmarshal(error: error)
            
        }
    }
}
