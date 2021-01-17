extension AccountKeeper {
    // NewAccountWithAddress implements sdk.AccountKeeper.
    public func makeAccountWithAddress(request: Request, address: AccountAddress) -> Account? {
        // TODO: Implement
        fatalError()
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
        // TODO: Implement
        fatalError()
    }
}
