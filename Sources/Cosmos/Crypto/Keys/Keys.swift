import ArgumentParser

// SigningAlgo defines an algorithm to derive key-pairs which can be used for cryptographic signing.
enum SigningAlgorithm: String, ExpressibleByArgument, Codable {
    // MultiAlgo implies that a pubkey is a multisignature
    case multi = "multi"
    // Secp256k1 uses the Bitcoin secp256k1 ECDSA parameters.
    case secp256k1 = "secp256k1"
    // Ed25519 represents the Ed25519 signature system.
    // It is currently not supported for end-user keys (wallets/ledgers).
    case ed25519 = "ed25519"
    // Sr25519 represents the Sr25519 signature system.
    case sr25519 = "sr25519"
}
