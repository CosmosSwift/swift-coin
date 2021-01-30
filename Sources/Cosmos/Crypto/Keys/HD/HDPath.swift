// BIP44Params wraps BIP 44 params (5 level BIP 32 path).
// To receive a canonical string representation ala
// m / purpose' / coinType' / account' / change / addressIndex
// call String() on a BIP44Params instance.
struct BIP44Params: Codable, CustomStringConvertible {
    let purpose: UInt32
    let coinType: UInt32
    let account: UInt32
    let change: Bool
    let addressIndex: UInt32
}

extension BIP44Params {
    var description: String {
        // m / Purpose' / coin_type' / Account' / Change / address_index
        "\(purpose)'/\(coinType)'/\(account)'/\(change ? "1" : "0")/\(addressIndex)"
    }
}

extension BIP44Params {
    // NewFundraiserParams creates a BIP 44 parameter object from the params:
    // m / 44' / coinType' / account' / 0 / address_index
    // The fixed parameters (purpose', coin_type', and change) are determined by what was used in the fundraiser.
    static func fundraiser(
        account: UInt32,
        coinType: UInt32,
        addressIndex: UInt32
    ) -> BIP44Params {
        BIP44Params(
            purpose: 44,
            coinType: coinType,
            account: account,
            change: false,
            addressIndex: addressIndex
        )
    }
}
