import Cosmos

// Handle a message to delete name
func handleDeleteNameMessage(request: Request, keeper: NameServiceKeeper, message: DeleteNameMessage) throws -> Result {
    if !keeper.exists(request: request, key: message.name) {
        throw Cosmos.Error.keyNotFound(key: message.name)
    }

    if message.owner != keeper.getOwner(request: request, key: message.name) {
        throw Cosmos.Error.unauthorized(reason: "Incorrect Owner")
    }

    keeper.deleteWhois(request: request, key: message.name)
    return .success
}
