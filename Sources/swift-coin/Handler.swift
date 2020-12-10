import Cosmos

extension Keeper {
    // NewHandler ...
    var handler: Handler {
        return { request, message in
            var request = request
            request.eventManager = EventManager()
           
            switch message {
        // this line is used by starport scaffolding # 1
            case let message as BuyNameMessage:
                return try handleBuyNameMessage(request: request, keeper: self, message: message)
            case let message as SetNameMessage:
                return try handleSetNameMessage(request: request, keeper: self, message: message)
            case let message as DeleteNameMessage:
                return try handleDeleteNameMessage(request: request, keeper: self, message: message)
            default:
                throw Cosmos.Error.unknownRequest(reason: "unrecognized \(moduleName) message type: \(message)")
            }
        }
    }
}
