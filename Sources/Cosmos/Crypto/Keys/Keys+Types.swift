import Foundation
import Tendermint

// Keybase exposes operations on a generic keystore
public protocol Keybase {
    // CRUD on the keystore
    func list() throws -> [KeyInfo]
    // Get returns the public information about one key.
    func get(name: String) throws -> KeyInfo
    // Get performs a by-address lookup and returns the public
    // information about one key if there's any.
    func getByAddress(address: AccountAddress) throws -> KeyInfo
    // Delete removes a key.
    func delete(name: String, passphrase: String, skipPass: Bool) throws
    // Sign bytes, looking up the private key to use.
    func sign(name: String, passphrase: String, message: Data) throws -> (Data, PublicKeyProtocol)

    // CreateMnemonic generates a new mnemonic, derives a hierarchical deterministic
    // key from that. and persists it to storage, encrypted using the provided password.
    // It returns the generated mnemonic and the key Info. It returns an error if it fails to
    // generate a key for the given algo type, or if another key is already stored under the
    // same name.
    func createMnemonic(
        name: String,
        language: Language,
        password: String,
        algorithm: SigningAlgorithm
    ) throws -> (info: KeyInfo, seed: String)

    // CreateAccount converts a mnemonic to a private key and BIP 32 HD Path
    // and persists it, encrypted with the given password.
    func createAccount(
        name: String,
        mnemonic: String,
        bip39Password: String,
        encryptPassword: String,
        hdPath: String,
        algorithm: SigningAlgorithm
    ) throws -> KeyInfo

    // CreateLedger creates, stores, and returns a new Ledger key reference
    func createLedger(
        name: String,
        algorithm: SigningAlgorithm,
        humanReadablePart: String,
        account: UInt32,
        index: UInt32
    ) throws -> KeyInfo

    // CreateOffline creates, stores, and returns a new offline key reference
    func createOffline(
        name: String,
        publicKey: PublicKeyProtocol,
        algorithm: SigningAlgorithm
    ) throws -> KeyInfo

    // CreateMulti creates, stores, and returns a new multsig (offline) key reference
    func createMulti(
        name: String,
        publicKey: PublicKeyProtocol
    ) throws -> KeyInfo

    // The following operations will *only* work on locally-stored keys
    func update(
        name: String,
        oldPassword: String,
        getNewPassword: () throws -> String
    ) throws

    // Import imports ASCII armored Info objects.
    func `import`(name: String, armor: String) throws

    // ImportPrivKey imports a private key in ASCII armor format.
    // It returns an error if a key with the same name exists or a wrong encryption passphrase is
    // supplied.
    func importPrivateKey(
        name: String,
        armor: String,
        passphrase: String
    ) throws

    // ImportPubKey imports ASCII-armored public keys.
    // Store a new Info object holding a public key only, i.e. it will
    // not be possible to sign with it as it lacks the secret key.
    func importPublicKey(
        name: String,
        armor: String
    ) throws

    // Export exports an Info object in ASCII armored format.
    func export(name: String) throws -> String

    // ExportPubKey returns public keys in ASCII armored format.
    // Retrieve a Info object by its name and return the public key in
    // a portable format.
    func exportPublicKey(name: String) throws -> String

    // ExportPrivKey returns a private key in ASCII armored format.
    // It returns an error if the key does not exist or a wrong encryption passphrase is supplied.
    func exportPrivateKey(
        name: String,
        decryptPassphrase: String,
        encryptPassphrase: String
    ) throws -> String

    // ExportPrivateKeyObject *only* works on locally-stored keys. Temporary method until we redo the exporting API
    func exportPrivateKeyObject(
        name: String,
        passphrase: String
    ) throws -> PrivateKey

    // SupportedAlgos returns a list of signing algorithms supported by the keybase
    var supportedAlgorithms: [SigningAlgorithm] { get }

    // SupportedAlgosLedger returns a list of signing algorithms supported by the keybase's ledger integration
    var supportedAlgorithmsLedger: [SigningAlgorithm] { get }

    // CloseDB closes the database.
    func closeDatabase()
}

extension Keybase {
    func isSupported(algorithm: SigningAlgorithm) -> Bool {
        supportedAlgorithms.contains(algorithm)
    }
}

// KeyType reflects a human-readable type for key listing.
public enum KeyType: UInt, CustomStringConvertible {
    case local = 0
    case ledger = 1
    case offline = 2
    case multi = 3
    
    public var description: String {
        switch self {
        case .local:
            return "local"
        case .ledger:
            return "ledger"
        case .offline:
            return "offline"
        case .multi:
            return "multi"
        }
    }
    
}

// Info is the publicly exposed information about a keypair
public protocol KeyInfo: ProtocolCodable {
    // Human-readable type for key listing
    var type: KeyType { get }
    // Name of the key
    var name: String { get }
    // Public key
    var publicKey: PublicKeyProtocol { get }
    // Address
    var address: AccountAddress { get }
    // Bip44 Path
    func path() throws -> BIP44Params
    // Algo
    var algorithm: SigningAlgorithm { get }
}

// localInfo is the public information about a locally stored key
// Note: Algo must be last field in struct for backwards amino compatibility
struct LocalInfo: KeyInfo {
    static let metaType: MetaType = Self.metaType(
        key: "crypto/keys/localInfo"
    )
    
    let name: String
    let publicKey: PublicKeyProtocol
    let privateKeyArmor: String
    let algorithm: SigningAlgorithm
    
    private enum CodingKeys: String, CodingKey {
        case name
        case publicKey = "pubkey"
        case privateKeyArmor = "privkey.armor"
        case algorithm = "algo"
    }
    
    init(
        name: String,
        publicKey: PublicKeyProtocol,
        privateKeyArmor: String,
        algorithm: SigningAlgorithm
    ) {
        self.name = name
        self.publicKey = publicKey
        self.privateKeyArmor = privateKeyArmor
        self.algorithm = algorithm
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        
        let publicKeyCodable = try container.decode(AnyProtocolCodable.self, forKey: .publicKey)
        
        guard let publicKey = publicKeyCodable.value as? PublicKeyProtocol else {
            throw DecodingError.dataCorruptedError(
                forKey: .publicKey,
                in: container,
                debugDescription: "Invalid public key type"
            )
        }
        
        self.publicKey = publicKey
        self.privateKeyArmor = try container.decode(String.self, forKey: .privateKeyArmor)
        self.algorithm = try container.decode(SigningAlgorithm.self, forKey: .algorithm)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(AnyProtocolCodable(publicKey), forKey: .publicKey)
        try container.encode(privateKeyArmor, forKey: .privateKeyArmor)
        try container.encode(algorithm, forKey: .algorithm)
    }
}

extension LocalInfo {
    var type: KeyType {
        .local
    }
    
    var address: AccountAddress {
        AccountAddress(data: publicKey.address.rawValue)
    }
    
    func path() throws -> BIP44Params {
        struct PathNotAvailable: Swift.Error, CustomStringConvertible {
            var description: String
        }
        
        throw PathNotAvailable(description: "BIP44 Paths are not available for this type")
    }
}

// offlineInfo is the public information about an offline key
// Note: Algo must be last field in struct for backwards amino compatibility
struct OfflineInfo: KeyInfo {
    static let metaType: MetaType = Self.metaType(
        key: "crypto/keys/offlineInfo"
    )
    
    let name: String
    let publicKey: PublicKeyProtocol
    let algorithm: SigningAlgorithm
    
    private enum CodingKeys: String, CodingKey {
        case name
        case publicKey = "pubkey"
        case algorithm = "algo"
    }
    
    init(
        name: String,
        publicKey: PublicKeyProtocol,
        algorithm: SigningAlgorithm
    ) {
        self.name = name
        self.publicKey = publicKey
        self.algorithm = algorithm
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        
        let publicKeyCodable = try container.decode(AnyProtocolCodable.self, forKey: .publicKey)
        
        guard let publicKey = publicKeyCodable.value as? PublicKeyProtocol else {
            throw DecodingError.dataCorruptedError(
                forKey: .publicKey,
                in: container,
                debugDescription: "Invalid public key type"
            )
        }
        
        self.publicKey = publicKey
        self.algorithm = try container.decode(SigningAlgorithm.self, forKey: .algorithm)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(AnyProtocolCodable(publicKey), forKey: .publicKey)
        try container.encode(algorithm, forKey: .algorithm)
    }
}

extension OfflineInfo {
    var type: KeyType {
        .offline
    }
    
    var address: AccountAddress {
        // TODO: We might have some issues here
        // with encoding
        AccountAddress(data: publicKey.address.rawValue)
    }
    
    func path() throws -> BIP44Params {
        struct PathNotAvailable: Swift.Error, CustomStringConvertible {
            var description: String
        }
        
        throw PathNotAvailable(description: "BIP44 Paths are not available for this type")
    }
}

// encoding info
func marshal(info: KeyInfo) -> Data {
    let value = AnyProtocolCodable(info)
    return Codec.keysCodec.mustMarshalJSON(value: value)
    // TODO: Check if this is required
//    return Codec.keysCodec.mustMarshalBinaryLengthPrefixed(value: value)
}

// decoding info
func unmarshalInfo(data: Data) throws -> KeyInfo {
    // TODO: Check if this is required
//    let value: AnyProtocolCodable = try Codec.keysCodec.unmarshalBinaryLengthPrefixed(data: data)
    let codable: AnyProtocolCodable = try Codec.keysCodec.unmarshalJSON(data: data)
    return codable.value as! KeyInfo
}

// DeriveKeyFunc defines the function to derive a new key from a seed and hd path
typealias DeriveKey = (
    _ mnemonic: String,
    _ bip39Passphrase: String,
    _ hdPath: String,
    _ algorithm: SigningAlgorithm
) throws -> Data

// PrivKeyGenFunc defines the function to convert derived key bytes to a tendermint private key
typealias GeneratePrivateKey = (
    _ data: Data,
    _ algorithm: SigningAlgorithm
) throws -> PrivateKey

// KeybaseOption overrides options for the db
public typealias KeybaseOption = (inout KeybaseOptions) -> ()
