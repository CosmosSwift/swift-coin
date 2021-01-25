import Foundation

extension AccountKeeper {
    // NewAccountWithAddress implements sdk.AccountKeeper.
    public func makeAccountWithAddress(request: Request, address: AccountAddress) -> BaseAccount {
        // TODO: Implement
        let account = BaseAccount(address: address)
        setAccount(request: request, account: account)
        return account
        //fatalError()
//        let account = proto()
//
//        try! account.set(address: address)
//        return self.account(request: request, address: address)
    }
    
    // NewAccount sets the next account number to a given account interface
    public func makeAccount(request: Request, account: Account) -> Account {
        try! account.set(accountNumber: nextAccountNumber(request: request))
        return account
    }

    // GetAccount implements sdk.AccountKeeper.
    public func account<A: Account>(request: Request, address: AccountAddress) -> A? {
        let store = request.keyValueStore(key: key)

        guard let data = store.get(key: addressStoreKey(address: address)) else {
            return nil
        }

        return decodeAccount(data: data)
    }
    
    // GetAccount implements sdk.AccountKeeper.
    public func baseAccount(request: Request, address: AccountAddress) -> BaseAccount? {
        let store = request.keyValueStore(key: key)

        guard let data = store.get(key: addressStoreKey(address: address)) else {
            return makeAccountWithAddress(request: request, address: address) 
        }

        return decodeAccount(data: data)
    }
    
    // GetAllAccounts returns all accounts in the accountKeeper.
    public func allAccounts(request: Request) -> [Account] {
        // TODO: Implement
        fatalError()
    }
    
    // SetAccount implements sdk.AccountKeeper.
    public func setAccount<A: Account>(request: Request, account: A) {
        let address = account.address
        let store = request.keyValueStore(key: key)
        let data = try! codec.marshalBinaryBare(value: account)
        
        store.set(
            key: addressStoreKey(address: address),
            value: data
        )
    }
    
    // IterateAccounts iterates over all the stored accounts and performs a callback function
    public func iterateAccounts(request: Request, process: (Account) -> Bool) {
        let store = request.keyValueStore(key: key)
        var iterator = store.iterator(start: Data(), end: Data())
        
        while iterator.isValid {
            defer {
                iterator.next()
            }
            
            let account: BaseAccount = self.decodeAccount(data: iterator.value)
            
            if process(account) {
                break
            }
        }
    }
}
