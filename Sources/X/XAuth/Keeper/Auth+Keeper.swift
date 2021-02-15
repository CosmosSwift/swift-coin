import Foundation
import Tendermint
import Cosmos
import XParams

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
        self.paramSubspace = paramstore.with(keyTable: KeyTable(pairs: AuthParameters.default.parameterSetPairs))
    }
}

extension AccountKeeper {
    // GetNextAccountNumber returns and increments the global account number counter.
    // If the global account number is not set, it initializes it with value 0.
    func nextAccountNumber(request: Request) -> UInt64 {
        var accountNumber: UInt64
        let store = request.keyValueStore(key: key)
        
        if let data = store.get(key: globalAccountNumberKey) {
            accountNumber = try! codec.unmarshalBinaryLengthPrefixed(data: data)
        } else {
            // initialize the account numbers
            accountNumber = 0
        }

        let data = codec.mustMarshalBinaryLengthPrefixed(value: accountNumber + 1)
        store.set(key: globalAccountNumberKey, value: data)
        return accountNumber
    }
    
    func setParams(request: Request, parameters: AuthParameters) {
        self.paramSubspace.setParameterSet(request: request, parameterSet: parameters)
    }
}

// -----------------------------------------------------------------------------
// Misc.

extension AccountKeeper {
    func decodeAccount(data: Data) -> Account {
        let account: AnyProtocolCodable = try! codec.unmarshalBinaryBare(data: data)
        return account.value as! Account
    }
}
