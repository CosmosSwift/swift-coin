// Constants defined here are the defaults value for address.
// You can use the specific values for your project.
// Add the follow lines to the `main()` of your server.
//
//    config := sdk.GetConfig()
//    config.SetBech32PrefixForAccount(yourBech32PrefixAccAddr, yourBech32PrefixAccPub)
//    config.SetBech32PrefixForValidator(yourBech32PrefixValAddr, yourBech32PrefixValPub)
//    config.SetBech32PrefixForConsensusNode(yourBech32PrefixConsAddr, yourBech32PrefixConsPub)
//    config.SetCoinType(yourCoinType)
//    config.SetFullFundraiserPath(yourFullFundraiserPath)
//    config.Seal()

// AddrLen defines a valid address length
let addressLength = 20

// Atom in https://github.com/satoshilabs/slips/blob/master/slip-0044.md
let coinType = 118

// BIP44Prefix is the parts of the BIP44 HD path that are fixed by
// what we used during the fundraiser.
let fullFundraiserPath = "44'/118'/0'/0/0"

public enum Prefix {
    // PrefixAccount is the prefix for account keys
    static let account = "acc"
    // PrefixValidator is the prefix for validator keys
    static let validator = "val"
    // PrefixConsensus is the prefix for consensus keys
    static let consensus = "cons"
    // PrefixPublic is the prefix for public keys
    static let publicKey = "pub"
    // PrefixOperator is the prefix for operator keys
    static let `operator` = "oper"

    // PrefixAddress is the prefix for addresses
    static let address = "addr"
}

public enum Bech32Prefix {
    // Bech32PrefixAccAddr defines the Bech32 prefix of an account's address
    static let main = "cosmos"
    // Bech32PrefixAccAddr defines the Bech32 prefix of an account's address
    static let accountAddress = main
    // Bech32PrefixAccPub defines the Bech32 prefix of an account's public key
    static let accountPublicKey = main + Prefix.publicKey
    // Bech32PrefixValAddr defines the Bech32 prefix of a validator's operator address
    static let validatorOperatorAddress = main + Prefix.validator + Prefix.operator
    // Bech32PrefixValPub defines the Bech32 prefix of a validator's operator public key
    static let validatorOperatorPublicKey = main + Prefix.validator + Prefix.operator + Prefix.publicKey
    // Bech32PrefixConsAddr defines the Bech32 prefix of a consensus node address
    static let consensusNodeAddress = main + Prefix.validator + Prefix.consensus
    // Bech32PrefixConsPub defines the Bech32 prefix of a consensus node public key
    static let consensNodePublicKey = main + Prefix.validator + Prefix.consensus + Prefix.publicKey
}
