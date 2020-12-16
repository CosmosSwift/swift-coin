import Tendermint

extension Supply {
    // NewModuleAddress creates an AccAddress from the hash of the module's name
    public static func moduleAddress(name: String) -> AccountAddress {
        AccountAddress(data: Crypto.addressHash(data: name.data))
    }
}
