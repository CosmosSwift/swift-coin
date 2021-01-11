import Foundation
import Crypto

public class Ed25519PrivateKey: PrivateKey {
    let key: Curve25519.Signing.PrivateKey
    
    override var data: Data {
        key.rawRepresentation
    }
    
    init(key: Curve25519.Signing.PrivateKey) {
        self.key = key
        super.init()
    }
    
    override init() {
        self.key = Curve25519.Signing.PrivateKey()
        super.init()
    }

    struct WrappedValue: Codable {
        let type: String
        let value: Data
    }
    
    static let type = "tendermint/PrivKeyEd25519"
    
    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let wrappedValue = try container.decode(WrappedValue.self)
        
        guard wrappedValue.type == Self.type else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "invalid type"
            )
        }
        
        let key = try Curve25519.Signing.PrivateKey(rawRepresentation: wrappedValue.value[0..<32])
        self.init(key: key)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        let wrappedValue = WrappedValue(
            type: Self.type,
            value: key.rawRepresentation
        )
        
        try container.encode(wrappedValue)
    }
    
    override func sign(message: Data) throws -> Data {
        try key.signature(for: message)
    }
    
    override var publicKey: PublicKey {
        Ed25519PublicKey(key: key.publicKey)
    }
}

extension Ed25519PrivateKey {
    // GenPrivKey generates a new ed25519 private key.
    // It uses OS randomness in conjunction with the current global random seed
    // in tendermint/libs/common to generate the private key.
    static func generate() -> Ed25519PrivateKey {
        Ed25519PrivateKey()
    }
}

public class Ed25519PublicKey: PublicKey {
    let key: Curve25519.Signing.PublicKey
    
    override var address: Address {
        Crypto.addressHash(data: data)
    }
    
    override var data: Data {
        key.rawRepresentation
    }

    init(key: Curve25519.Signing.PublicKey) {
        self.key = key
        super.init()
    }
    
    struct WrappedValue: Codable {
        let type: String
        let value: Data
    }
    
    static let type = "tendermint/PubKeyEd25519"

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let wrappedValue = try container.decode(WrappedValue.self)
        
        guard wrappedValue.type == Self.type else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "invalid type"
            )
        }
        let key = try Curve25519.Signing.PublicKey(rawRepresentation: wrappedValue.value)
        self.init(key: key)
    }
    
    override func verify(message: Data, signature: Data) -> Bool {
        key.isValidSignature(signature, for: message)
    }
}
