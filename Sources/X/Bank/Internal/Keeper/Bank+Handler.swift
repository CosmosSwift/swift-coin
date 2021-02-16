import ABCI
import Cosmos

extension BankKeeper {
    // NewHandler returns a handler for "bank" type messages.
    func makeHandler() -> Handler {
        return { request, message in
            var request = request
            request.eventManager = EventManager()

            switch message {
            case let sendMessage as SendMessage:
                return try handleSendMessage(
                    request: request,
                    message: sendMessage
                )
            case let multiSendMessage as MultiSendMessage:
                return try handleMultiSendMessage(
                    request: request,
                    message: multiSendMessage
                )
            default:
                throw Cosmos.Error.unknownRequest(reason: "unrecognized bank message type: \(message.type)")
            }
        }
    }

    // Handle MsgSend.
    func handleSendMessage(request: Request, message: SendMessage) throws -> Result {
        if !isSendEnabled(request: request) {
            throw Cosmos.Error.sendDisabled
        }

        if isBlacklisted(address: message.destinationAddress) {
            throw Cosmos.Error.unauthorized(reason: "\(message.destinationAddress) is not allowed to receive transactions")
        }

        try sendCoins(
            request: request,
            fromAddress: message.senderAddress,
            toAddress: message.destinationAddress,
            amount: message.amount
        )
         
        let attribute = Attribute(
            key: AttributeKey.module,
            value: AttributeValue.category
        )

        let event = Event(
            type: EventType.message,
            attributes: [attribute]
        )

        request.eventManager.emit(event: event)
        return Result(events: request.eventManager.events)
    }

    // Handle MsgMultiSend.
    func handleMultiSendMessage(request: Request, message: MultiSendMessage) throws -> Result {
        // NOTE: totalIn == totalOut should already have been checked
        if !isSendEnabled(request: request) {
            throw Cosmos.Error.sendDisabled
        }

        for output in message.outputs {
            if isBlacklisted(address: output.address) {
                throw Cosmos.Error.unauthorized(reason: "'\(output.address) is not allowed to receive transactions")
            }
        }

        try inputOutputCoins(
            request: request,
            inputs: message.inputs,
            outputs: message.outputs
        )
        
        let attribute = Attribute(
            key: AttributeKey.module,
            value: AttributeValue.category
        )
        
        let event = Event(
            type: EventType.message,
            attributes: [attribute]
        )

        request.eventManager.emit(event: event)
        return Result(events: request.eventManager.events)
    }
}
