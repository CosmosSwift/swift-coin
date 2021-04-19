import Cosmos

// Handle a message to set name
func handleSetNameMessage(
    request: Request,
    keeper: NameServiceKeeper,
    message: SetNameMessage
) throws -> Cosmos.Result {
    // TODO: Implement
    if keeper.hasOwner(request: request, name: message.name)  {
        try keeper.setName(request: request, name: message.name, value: message.value)
        return Result()
    } else {
        // If not, throw an error
        throw Cosmos.Error.insufficientFunds(reason: "Name \(message.name) not found.")
    }

    
//    // Checks if the the msg sender is the same as the current owner
//    if message.owner != keeper.getOwner(request: request, key: message.name) {
//        // If not, throw an error
//        throw Cosmos.Error.unauthorized(reason: "Incorrect Owner")
//    }
//    // If so, set the name to the value specified in the message.
//    try keeper.setName(request: request, name: message.name, value: message.value)
//    return .success
}
