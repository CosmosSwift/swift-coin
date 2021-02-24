import ABCIMessages

extension ABCIMessages.PublicKey {
    // XXX: panics on nil or unknown pubkey type
    // TODO: add cases when new pubkey types are added to crypto
    public init(_ publicKey: PublicKey) {
        switch publicKey {
        case is Ed25519PublicKey:
            self = .ed25519(publicKey.data)
//        case is Sr25519PublicKey:
//            self = .sr25515(publicKey.data)
        // TODO: Implement
//        case is Secp256k1PublicKey:
//            self = .ed25519(publicKey.data)
        default:
            fatalError("unknown pubkey type: \(publicKey) \(type(of: publicKey))")
        }
    }
}
