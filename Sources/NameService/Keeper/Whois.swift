import Foundation
import Cosmos
import Database

extension Keeper {
    // GetWhois returns the whois information
    func getWhois(request: Request, key: String) throws -> Whois? {
        let store = request.keyValueStore(key: storeKey)
        
        guard let key = (Keys.whoisPrefix + key).data(using: .utf8) else {
            // TODO: throw a specific error
            throw Cosmos.Error.unknownRequest(reason: "invalid key")
        }
        
        guard let data = store.get(key: key) else {
            return nil
        }
        
        return try codec.unmarshalBinaryLengthPrefixed(data: data)
    }
    
    // SetWhois sets a whois. We modified this function to use the `name` value as the key instead of msg.ID
    func setWhois(request: Request, name: String, whois: Whois) throws {
        let store = request.keyValueStore(key: storeKey)
        let data = try codec.mustMarshalBinaryLengthPrefixed(value: whois)
        
        guard let key = (Keys.whoisPrefix + name).data(using: .utf8) else {
            // TODO: throw a specific error
            throw Cosmos.Error.unknownRequest(reason: "invalid key")
        }
        
        store.set(key: key, value: data)
    }
    
    // DeleteWhois deletes a whois
    func deleteWhois(request: Request, key: String) {
        let store = request.keyValueStore(key: storeKey)
        store.delete(key: (Keys.whoisPrefix + key).data)
    }

    // MARK: Functions used by querier

    func listWhois(request: Request) -> Data {
        var whoisList: [Whois] = []
        let store = request.keyValueStore(key: storeKey)
        let iterator = store.prefixIterator(prefix: Keys.whoisPrefix.data)
        
        while iterator.isValid {
            defer {
                iterator.next()
            }
            
            guard let data = store.get(key: iterator.key) else {
                // TODO: Figure out what to do here.
                continue
            }
            
            let whois: Whois = codec.mustUnmarshalBinaryLength(data: data)
            whoisList.append(whois)
        }
        
        return codec.mustMarshalJSONIndent(value: whoisList)
    }
    
    func getWhois(request: Request, path: [String]) throws -> Data {
        let key = path[0]
        let whois = try getWhois(request: request, key: key)

        do {
            return try codec.marshalJSONIndent(value: whois)
        } catch {
            throw Cosmos.Error.jsonMarshal(error: error)
        }
    }

    // Resolves a name, returns the value
    func resolveName(request: Request, path: [String]) throws -> Data {
        guard let value = resolveName(request: request, name: path[0]) else {
            throw Cosmos.Error.unknownRequest(reason: "could not resolve name")
        }

        if value.isEmpty {
            throw Cosmos.Error.unknownRequest(reason: "could not resolve name")
        }

        do {
            return try codec.marshalJSONIndent(value: QueryResultResolve(value: value))
        } catch {
            throw Cosmos.Error.jsonMarshal(error: error)
        }
    }
    
    // Get owner of the item
    func getOwner(request: Request, key: String) -> AccountAddress? {
        try? getWhois(request: request, key: key)?.owner
    }
    
    // Check if the key exists in the store
    func exists(request: Request, key: String) -> Bool {
        let store = request.keyValueStore(key: storeKey)
        return store.has(key: (Keys.whoisPrefix + key).data)
    }

    // ResolveName - returns the string that the name resolves to
    func resolveName(request: Request, name: String) -> String? {
        let whois = try? getWhois(request: request, key: name)
        return whois?.value
    }

    // SetName - sets the value string that a name resolves to
    func setName(request: Request, name: String, value: String) throws {
        // TODO: Decide what to actually do when there is no whois mapped to
        // the given hame.
        guard var whois = try getWhois(request: request, key: name) else {
            return
        }
        
        whois.value = value
        try setWhois(request: request, name: name, whois: whois)
    }
    // HasOwner - returns whether or not the name already has an owner
    func hasOwner(request: Request, name: String) -> Bool {
        guard let whois = try? getWhois(request: request, key: name) else {
            return false
        }
        
        return !whois.owner.isEmpty
    }

    // SetOwner - sets the current owner of a name
    func setOwner(request: Request, name: String, owner: AccountAddress) throws {
        // TODO: Decide what to actually do when there is no whois mapped to
        // the given hame.
        guard var whois = try getWhois(request: request, key: name) else {
           return
        }
        
        whois.owner = owner
        try setWhois(request: request, name: name, whois: whois)
    }
    
    // GetPrice - gets the current price of a name
    func getPrice(request: Request, name: String) -> Coins? {
        let whois = try? getWhois(request: request, key: name)
        return whois?.price
    }
    
    // SetPrice - sets the current price of a name
    func setPrice(request: Request, name: String, price: Coins) throws {
        // TODO: Decide what to actually do when there is no whois mapped to
        // the given hame.
        guard var whois = try getWhois(request: request, key: name) else {
            return
        }
        
        whois.price = price
        try setWhois(request: request, name: name, whois: whois)
    }

    // Check if the name is present in the store or not
    func isNamePresent(request: Request, name: String) -> Bool {
        let store = request.keyValueStore(key: storeKey)
        return store.has(key: name.data)
    }

    // Get an iterator over all names in which the keys are the names and the values are the whois
    func getNamesIterator(request: Request) -> Iterator {
        let store = request.keyValueStore(key: storeKey)
        return store.prefixIterator(prefix: Keys.whoisPrefix.data)
    }
    


    
    

}
