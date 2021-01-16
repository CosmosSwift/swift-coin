// AccountKeeper encodes/decodes accounts using the go-amino (binary)
// encoding/decoding library.
public struct AccountKeeper {
    // The (unexposed) key used to access the store from the Context.
    let key: StoreKey

    // The prototypical Account constructor.
    let proto: () -> Account

    // The codec codec for binary encoding/decoding of accounts.
    let codec: Codec

    let paramSubspace: Subspace
    
    // NewAccountKeeper returns a new sdk.AccountKeeper that uses go-amino to
    // (binary) encode and decode concrete sdk.Accounts.
    // nolint
    public init(
        codec: Codec,
        key: StoreKey,
        paramstore: Subspace,
        proto: @escaping () -> Account
    ) {
        self.key = key
        self.proto = proto
        self.codec = codec
        self.paramSubspace = paramstore.with(keyTable: .paramKeyTable)
    }

    public func accountWithAddress(request: Request, address: AccountAddress) -> Account? {
        // TODO: Implement
        fatalError()
//        let account = proto()
//
//        do {
//            try account.set(address: address)
//            return self.account(request: request, address: address)
//        } catch {
//            fatalError("\(error)")
//        }
    }
    
    public func account(request: Request, address: AccountAddress) -> Account? {
        fatalError()
//        let store = request.keyValueStore(key: key)
//
//        guard let data = store.get(key: AddressStoreKey(address)) else {
//            return nil
//        }
//
//        return decodeAccount(data: data)
    }
    
    public func allAccounts(request: Request) -> [Account] {
        // TODO: Implement
        fatalError()
    }
    
    public func setAccount(request: Request, account: Account) {
        // TODO: Implement
        fatalError()
    }
    
    public func iterateAccounts(request: Request, process: (Account) -> Bool) {
        // TODO: Implement
        fatalError()
    }
}

