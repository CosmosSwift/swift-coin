import Foundation

//------------------------------------------------------------------------------
// Persistent peer ID
// TODO: encrypt on disk

// NodeKey is the persistent peer key.
// It contains the nodes private key for authentication.
public struct NodeKey: Codable {
    let privateKey: PrivateKey
    
    private enum CodingKeys: String, CodingKey {
        case privateKey = "priv_key"
    }
    
    init(privateKey: PrivateKey) {
        self.privateKey = privateKey
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let privateKeyCodable = try container.decode(AnyProtocolCodable.self, forKey: .privateKey)
        
        guard let privateKey = privateKeyCodable.value as? PrivateKey else {
            throw DecodingError.dataCorruptedError(
                forKey: .privateKey,
                in: container,
                debugDescription: "Invalid type for private key"
            )
        }
        
        self.privateKey = privateKey
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(AnyProtocolCodable(privateKey), forKey: .privateKey)
    }
}

extension NodeKey {
    // ID is a hex-encoded crypto.Address
    public typealias ID = String
    
    // ID returns the peer's canonical ID - the hash of its public key.
    public var id: ID {
        Self.id(from: privateKey.publicKey)
    }
    
    // PubKeyToID returns the ID corresponding to the given PubKey.
    // It's the hex-encoding of the pubKey.Address().
    static func id(from publicKey: PublicKey) -> ID {
        publicKey.address.rawValue.hexEncodedString()
    }
}

public enum P2P {
    // LoadOrGenNodeKey attempts to load the NodeKey from the given filePath.
    // If the file does not exist, it generates and saves a new NodeKey.
    public static func loadOrGenerateNodeKey(atPath path: String) throws -> NodeKey {
        if FileManager.default.fileExists(atPath: path) {
            return try loadNodeKey(atPath: path)
        }
        
        return try generateNodeKey(atPath: path)
    }

    private static func loadNodeKey(atPath path: String) throws -> NodeKey {
        let url = URL(fileURLWithPath: path)
        let jsonData = try Data(contentsOf: url)

        do {
            return try JSONDecoder().decode(NodeKey.self, from: jsonData)
        } catch {
            struct DecodingError: Error, CustomStringConvertible {
                var description: String
            }
            
            throw DecodingError(description: "error reading NodeKey from \(path): \(error)")
        }
    }

    private static func generateNodeKey(atPath path: String) throws -> NodeKey {
        let privateKey = Ed25519PrivateKey.generate()
        let nodeKey = NodeKey(privateKey: privateKey)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let jsonData = try encoder.encode(nodeKey)
        let url = URL(fileURLWithPath: path)
        try jsonData.write(to: url)

        // Check if this is required
//        try! FileManager.default.setAttributes(
//            [.posixPermissions: NSNumber(value: Int16(0600))],
//            ofItemAtPath: path
//        )

        return nodeKey
    }
}
