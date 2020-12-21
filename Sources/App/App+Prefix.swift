import Cosmos

enum Prefix {
    static let accountAddress   = "cosmos"
    
    static let accountPublicKey    = accountAddress + "pub"
    static let validatorAddress = accountAddress + "valoper"
    static let validatorPublicKey  = accountAddress + "valoperpub"
    static let consensusNodeAddress  = accountAddress + "valcons"
    static let consensusNodePublicKey   = accountAddress + "valconspub"
}

extension NameServiceApp {
    public static func configure() {
        Configuration.setBech32PrefixForAccount(
            addressPrefix: Prefix.accountAddress,
            publicKeyPrefix: Prefix.accountPublicKey
        )
        
        Configuration.setBech32PrefixForValidator(
            addressPrefix: Prefix.validatorAddress,
            publicKeyPrefix: Prefix.validatorPublicKey
        )
        
        Configuration.setBech32PrefixForConsensusNode(
            addressPrefix: Prefix.consensusNodeAddress,
            publicKeyPrefix: Prefix.consensusNodePublicKey
        )

        Configuration.seal()
    }
}
