// KeyOutput defines a structure wrapping around an Info object used for output
// functionality.
struct KeyOutput: Codable {
    let name: String
    let type: String
    let address: String
    let publicKey: String
    let mnemonic:  String = ""
    let threshold: UInt = 0
    // TODO: Implement
//    let publicKeys [MultisignaturePublicKeyOutput]
    
    private enum CodingKeys: String, CodingKey {
        case name
        case type
        case address
        case publicKey = "pubkey"
        case mnemonic
        case threshold
//        case publicKeys = "pubkeys"
    }
}

// Bech32KeyOutput create a KeyOutput in with "acc" Bech32 prefixes. If the
// public key is a multisig public key, then the threshold and constituent
// public keys will be added.
func bech32KeyOutput(keyInfo: KeyInfo) throws -> KeyOutput {
    let accountAddress = AccountAddress(data: keyInfo.publicKey.address.rawValue)
    let publicKey = keyInfo.publicKey.address.rawValue.hexEncodedString()
    // TODO: Implement
//    let bechPublicKey = try Bech32ifyPublicKey(Bech32PublicKeyTypeAccountPub, keyInfo.publicKey)

    let keyOutput = KeyOutput(
        name: keyInfo.name,
        type: keyInfo.type.description,
        address: accountAddress.description,
        publicKey: publicKey // bechPublicKey
    )

    // TODO: Implement
//    if mInfo, ok := keyInfo.(*multiInfo); ok {
//        pubKeys := make([]multisigPubKeyOutput, len(mInfo.PubKeys))
//
//        for i, pk := range mInfo.PubKeys {
//            accAddr := sdk.AccAddress(pk.PubKey.Address().Bytes())
//
//            bechPubKey, err := sdk.Bech32ifyPubKey(sdk.Bech32PubKeyTypeAccPub, pk.PubKey)
//            if err != nil {
//                return KeyOutput{}, err
//            }
//
//            pubKeys[i] = multisigPubKeyOutput{accAddr.String(), bechPubKey, pk.Weight}
//        }
//
//        ko.Threshold = mInfo.Threshold
//        ko.PubKeys = pubKeys
//    }

    return keyOutput
}
