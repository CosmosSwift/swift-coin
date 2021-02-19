import Foundation
import ABCIMessages
import Cosmos

extension SupplyKeeper {
    // NewQuerier creates a querier for supply REST endpoints
    public func makeQuerier() -> Querier {
        return { request, path, queryRequest in
            switch path[0] {
            case SupplyKeys.queryTotalSupply:
                return try queryTotalSupply(request: request, queryRequest: queryRequest)
            case SupplyKeys.querySupplyOf:
                return try querySupplyOf(request: request, queryRequest: queryRequest)
            default:
                throw Cosmos.Error.unknownRequest(reason: "unknown \(SupplyKeys.moduleName) query endpoint: \(path[0])")
            }
        }
    }

    func queryTotalSupply(request: Request, queryRequest: RequestQuery<Data>) throws -> Data {
        do {
            let params: QueryTotalSupplyParams = try codec.unmarshalJSON(data: queryRequest.data)
            var totalSupply = supply(request: request).total

            let (start, end) = paginate(
                count: totalSupply.count,
                page: params.page,
                limit: params.limit,
                definitiveLimit: 100
            )
            
            if start < 0 || end < 0 {
                totalSupply = []
            } else {
                // TODO: Implement Coins slicing
                totalSupply = Array(totalSupply[start..<end])
            }
            
            do {
                return try totalSupply.marshalJSON()
            } catch {
                throw Cosmos.Error.jsonMarshal(error: error)
            }
        } catch {
            throw Cosmos.Error.jsonUnmarshal(error: error)
        }
    }

    func querySupplyOf(request: Request, queryRequest: RequestQuery<Data>) throws -> Data {
        do {
            let params: QuerySupplyOfParams = try codec.unmarshalJSON(data: queryRequest.data)
            let supply = self.supply(request: request).total.amountOf(denomination: params.denomination)

            do {
                return try supply.marshalJSON()
            } catch {
                throw Cosmos.Error.jsonMarshal(error: error)
            }
        } catch {
            throw Cosmos.Error.jsonUnmarshal(error: error)
        }
    }
}
