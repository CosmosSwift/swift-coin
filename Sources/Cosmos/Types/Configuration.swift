import Foundation

// Config is the structure that holds the SDK configuration parameters.
// This could be used to initialize certain configuration parameters for the SDK.
public class Configuration: Sealable {
    // DefaultKeyringServiceName defines a default service name for the keyring.
    public static let defaultKeyringServiceName = "cosmos"
    
//    fullFundraiserPath  string
    var bech32AddressPrefix: [String: String]
//    txEncoder           TxEncoder
    public var addressVerifier: ((Data) throws -> Void)?
//    mtx                 sync.RWMutex
    var coinType: UInt32 = Configuration.coinType
    var sealed: Bool = false
//    sealedch            chan struct{}
    
    // cosmos-sdk wide global singleton
    public static let configuration = Configuration()
    
    public enum Bech32AddressPrefixKeys {
        static let accountAddress = "account_address"
        static let validatorOperatorAddress = "validator_operator_address"
        static let consensusNodeAddress = "consensus_node_address"
        static let accountPublicKey = "account_public_key"
        static let validatorOperatorPublicKey = "validator_operator_public_key"
        static let consensusNodePublicKey = "consensus_node_public_key"
    }
    
    // New returns a new Config with default values.
    init() {
        self.bech32AddressPrefix = [
            Bech32AddressPrefixKeys.accountAddress: Bech32Prefix.accountAddress,
            Bech32AddressPrefixKeys.validatorOperatorAddress: Bech32Prefix.validatorOperatorAddress,
            Bech32AddressPrefixKeys.consensusNodeAddress: Bech32Prefix.consensusNodeAddress,
            Bech32AddressPrefixKeys.accountPublicKey: Bech32Prefix.accountPublicKey,
            Bech32AddressPrefixKeys.validatorOperatorPublicKey: Bech32Prefix.validatorOperatorPublicKey,
            Bech32AddressPrefixKeys.consensusNodePublicKey: Bech32Prefix.consensNodePublicKey,
        ]
//                coinType:           CoinType,
//                fullFundraiserPath: FullFundraiserPath,
//                txEncoder:          nil,
//            }
//        }
    }
    
    // SetBech32PrefixForAccount builds the Config with Bech32 addressPrefix and publKeyPrefix for accounts
    // and returns the config instance
    public static func setBech32PrefixForAccount(addressPrefix: String, publicKeyPrefix: String) {
        configuration.assertUnsealed("Configuraton is sealed")
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.accountAddress] = addressPrefix
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.accountPublicKey] = publicKeyPrefix
    }

    // SetBech32PrefixForValidator builds the Config with Bech32 addressPrefix and publKeyPrefix for validators
    //  and returns the config instance
    public static func setBech32PrefixForValidator(addressPrefix: String, publicKeyPrefix: String) {
        configuration.assertUnsealed("Configuraton is sealed")
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.validatorOperatorAddress] = addressPrefix
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.validatorOperatorPublicKey] = publicKeyPrefix
    }

    // SetBech32PrefixForConsensusNode builds the Config with Bech32 addressPrefix and publKeyPrefix for consensus nodes
    // and returns the config instance
    public static func setBech32PrefixForConsensusNode(addressPrefix: String, publicKeyPrefix: String) {
        configuration.assertUnsealed("Configuraton is sealed")
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.consensusNodeAddress] = addressPrefix
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.consensusNodePublicKey] = publicKeyPrefix
    }
    
    public static func seal() {
        configuration.sealed = true
    }
    
    // GetBech32AccountAddrPrefix returns the Bech32 prefix for account address
    public static var bech32AccountAddressPrefix: String {
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.accountAddress]!
    }

    // GetBech32ValidatorAddrPrefix returns the Bech32 prefix for validator address
    public static var bech32ValidatorAddressPrefix: String {
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.validatorOperatorAddress]!
    }

    // GetBech32ConsensusAddrPrefix returns the Bech32 prefix for consensus node address
    public static var bech32ConsensusAddressPrefix: String {
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.consensusNodeAddress]!
    }

    // GetBech32AccountPubPrefix returns the Bech32 prefix for account public key
    public static var bech32AccountPublicKeyPrefix: String {
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.accountPublicKey]!
    }

    // GetBech32ValidatorPubPrefix returns the Bech32 prefix for validator public key
    public static var bech32ValidatorPublicKeyPrefix: String {
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.validatorOperatorPublicKey]!
    }

    // GetBech32ConsensusPubPrefix returns the Bech32 prefix for consensus node public key
    public static var bech32ConsensusPublicKeyPrefix: String {
        configuration.bech32AddressPrefix[Bech32AddressPrefixKeys.consensusNodePublicKey]!
    }
    
    public static var keyringServiceName: String {
        // TODO: Check this
//        if len(version.Name) == 0 {
            return defaultKeyringServiceName
//        }
//
//        return version.Name
    }

}

