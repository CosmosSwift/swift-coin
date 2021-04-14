import Cosmos

// Handle a message to buy name
func handleBuyNameMessage(request: Request, keeper: NameServiceKeeper, message: BuyNameMessage) throws -> Result {
    // TODO: first check if name is present
    
    if let price = keeper.getPrice(request: request, name: message.name)  {
        // In this case, the name is owned already
        print("\(message.name) is already owned, checking if we can buy")
        // Checks if the the bid price is greater than the price paid by the current owner
        if price.isAllGreaterThan(coins: message.bid) {
            // If not, throw an error
            throw Cosmos.Error.insufficientFunds(reason: "Bid not high enough")
        }
        
        guard let owner = keeper.getOwner(request: request, key: message.name) else {
            // TODO: Check what's the best error to throw
            throw Cosmos.Error.unknownRequest(reason: "Could not find owner")
        }
        try keeper.coinKeeper.sendCoins(
            request: request,
            fromAddress: message.buyer,
            toAddress: owner,
            amount: message.bid
        )
        print("Sent \(message.bid) from \(message.buyer) to \(owner)")
        try keeper.setOwner(request: request, name: message.name, owner: message.buyer)
        try keeper.setPrice(request: request, name: message.name, price: message.bid)

    } else {
        try keeper.setWhois(request: request, name: message.name, whois: Whois(value: message.name, owner: message.buyer, price:message.bid))
    }
    // If so, deduct the Bid amount from the sender
    try keeper.coinKeeper.subtractCoins(
        request: request,
        address: message.buyer,
        amount: message.bid
    )
    let attribute = Attribute(
        key: AttributeKey.module,
        value: "buy-name"
    )

    let event = Event(
        type: EventType.message,
        attributes: [attribute]
    )

    request.eventManager.emit(event: event)
    return Result(events: request.eventManager.events)
}
