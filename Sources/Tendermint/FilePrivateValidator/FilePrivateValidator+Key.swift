import Foundation

public struct FilePrivateValidatorKey: Codable {
    public let address: Address
    // TODO: The key below should be an abstract PrivateKey
    // Using PrivateKey as an "abstract" class did not work
    // We should think about what to do later (see P2P/P2P+Key.swift)
    public let publicKey: Ed25519PublicKey
    public let privateKey: Ed25519PrivateKey
    
    private enum CodingKeys: String, CodingKey {
        case address
        case publicKey = "pub_key"
        case privateKey = "priv_key"
    }
}

extension FilePrivateValidatorKey {
    public init(privateKey: Ed25519PrivateKey) {
        self.privateKey = privateKey
        // TODO: this should not fail, but we should describe the public key as associated type to the private key to avoid this.
        self.publicKey = privateKey.publicKey as! Ed25519PublicKey
        self.address = self.publicKey.address
    }
}

public struct FilePrivateValidatorState: Codable {
    public let height: String // Required!!! otherwise tendermint throws: Error reading PrivValidator state from /tendermint/config/priv_validator_state.json: invalid 64-bit integer encoding "0", expected string
    public let round: Int
    public let step: Int
}

public enum FilePrivateValidator {
    /// LoadOrGenFilePrivateValidatorKey attempts to load the FilePrivateValidatorKey from the given filePath.
    /// If the file does not exist, it generates and saves a new FilePrivateValidatorKey.
    public static func loadOrGenerateFilePrivateValidatorKey(atPath path: String) throws -> FilePrivateValidatorKey {
        if FileManager.default.fileExists(atPath: path) {
            return try loadFilePrivateValidatorKey(atPath: path)
        }
        
        return try generateFilePrivateValidatorKey(atPath: path)
    }

    /// LoadOrGenFilePrivateValidatorState attempts to load the FilePrivateValidatorState from the given filePath.
    /// If the file does not exist, it generates and saves a new FilePrivateValidatorState.
    public static func loadOrGenerateFilePrivateValidatorState(atPath path: String) throws -> FilePrivateValidatorState {
        if FileManager.default.fileExists(atPath: path) {
            return try loadFilePrivateValidatorState(atPath: path)
        }
        
        return try generateFilePrivateValidatorState(atPath: path)
    }

    private static func loadFilePrivateValidatorKey(atPath path: String) throws -> FilePrivateValidatorKey {
        let url = URL(fileURLWithPath: path)
        let jsonData = try Data(contentsOf: url)

        do {
            return try JSONDecoder().decode(FilePrivateValidatorKey.self, from: jsonData)
        } catch {
            struct DecodingError: Error, CustomStringConvertible {
                var description: String
            }
            
            throw DecodingError(description: "error reading FilePrivateValidatorKey from \(path): \(error)")
        }
    }

    private static func loadFilePrivateValidatorState(atPath path: String) throws -> FilePrivateValidatorState {
        let url = URL(fileURLWithPath: path)
        let jsonData = try Data(contentsOf: url)

        do {
            return try JSONDecoder().decode(FilePrivateValidatorState.self, from: jsonData)
        } catch {
            struct DecodingError: Error, CustomStringConvertible {
                var description: String
            }
            
            throw DecodingError(description: "error reading FilePrivateValidatorState from \(path): \(error)")
        }
    }
    
    private static func generateFilePrivateValidatorKey(atPath path: String) throws -> FilePrivateValidatorKey {
        let privateKey = Ed25519PrivateKey.generate()
        let filePrivateValidatorKey = FilePrivateValidatorKey(privateKey: privateKey)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let jsonData = try encoder.encode(filePrivateValidatorKey)
        let url = URL(fileURLWithPath: path)
        try jsonData.write(to: url)

        // Check if this is required
//        try! FileManager.default.setAttributes(
//            [.posixPermissions: NSNumber(value: Int16(0600))],
//            ofItemAtPath: path
//        )

        return filePrivateValidatorKey
    }
    
    private static func generateFilePrivateValidatorState(atPath path: String) throws -> FilePrivateValidatorState {
        let filePrivateValidatorState = FilePrivateValidatorState(height: "0", round: 0, step: 0)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let jsonData = try encoder.encode(filePrivateValidatorState)
        let url = URL(fileURLWithPath: path)
        try jsonData.write(to: url)
        return filePrivateValidatorState
    }
}

