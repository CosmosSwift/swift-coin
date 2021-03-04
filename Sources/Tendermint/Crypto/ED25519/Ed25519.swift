import Foundation
import ABCIMessages
import Crypto

public struct Ed25519PrivateKey: PrivateKey {
    public static var metaType: MetaType = Self.metaType(
        key: "tendermint/PrivKeyEd25519"
    )
    
    private let key: Curve25519.Signing.PrivateKey
    
    public var data: Data {
        key.rawRepresentation
    }
    
    public init(data: Data) throws {
        self.key = try Curve25519.Signing.PrivateKey(rawRepresentation: data)
    }
    
    init(key: Curve25519.Signing.PrivateKey) {
        self.key = key
    }
    
    init() {
        self.key = Curve25519.Signing.PrivateKey()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        try self.init(data: data[0..<32]) // CurveE25519 take the seed tendermint encodes the private key as the seed (firstr 32 bytes) + the pub key (last 32 bytes)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
    
    public func sign(message: Data) throws -> Data {
        try key.signature(for: message)
    }
    
    public var publicKey: PublicKey {
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

public struct Ed25519PublicKey: PublicKey {
    public static var metaType: MetaType = Self.metaType(
        key: "tendermint/PubKeyEd25519"
    )
    
    private let key: Curve25519.Signing.PublicKey
    
    public var address: Address {
        Crypto.addressHash(data: data)
    }
    
    public var data: Data {
        key.rawRepresentation
    }
    
    init(data: Data) throws {
        self.key = try Curve25519.Signing.PublicKey(rawRepresentation: data)
    }

    init(key: Curve25519.Signing.PublicKey) {
        self.key = key
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        try self.init(data: data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
    
    public func verify(message: Data, signature: Data) -> Bool {
        key.isValidSignature(signature, for: message)
    }
}
