import Foundation
import BIP39
import Tendermint

public struct KeybaseOptions {
    let generateKey: GeneratePrivateKey
    let deriveKey: DeriveKey
    let supportedAlgorithms: [SigningAlgorithm]
    let supportedAlgorithmsLedger: [SigningAlgorithm]
}

protocol KeyWriter: WriteLocalKeyer, InfoWriter {}

protocol WriteLocalKeyer {
    func writeLocalKey(
        name: String,
        privateKey: PrivateKey,
        passphrase: String,
        algorithm: SigningAlgorithm
    ) -> KeyInfo
}

protocol InfoWriter {
    func writeInfo(name: String, info: KeyInfo)
}

// baseKeybase is an auxiliary type that groups Keybase storage agnostic features
// together.
struct BaseKeybase {
    let options: KeybaseOptions
    
    // newBaseKeybase generates the base keybase with defaulting to tendermint SECP256K1 key type
    init(options: [KeybaseOption] = []) {
        // Default options for keybase
        var defaultOptions = KeybaseOptions(
            generateKey: Self.defaultGenerateKey,
            deriveKey: Self.defaultDeriveKey,
            supportedAlgorithms: [.ed25519],
            supportedAlgorithmsLedger: [.ed25519]
        )

        for option in options {
            option(&defaultOptions)
        }
        
        self.options = defaultOptions
    }
    
    // StdPrivKeyGen is the default PrivKeyGen function in the keybase.
    // For now, it only supports Ed15519
    static func defaultGenerateKey(data: Data, algorithm: SigningAlgorithm) throws -> PrivateKey {
        guard algorithm == .ed25519 else {
            throw UnsupportedSigningAlgorithmError()
        }
            
        return try generateEd25519PrivateKey(data: data)
    }

    // EdPrivKeyGen generates a Ed25519 private key from the given bytes
    static func generateEd25519PrivateKey(data: Data) throws -> PrivateKey {
        try Ed25519PrivateKey(data: data)
    }
    
    // StdDeriveKey is the default DeriveKey function in the keybase.
    // For now, it only supports Ed25519
    static func defaultDeriveKey(
        mnemonic: String,
        bip39Passphrase: String,
        hdPath: String,
        algorithm: SigningAlgorithm
    ) throws -> Data {
        guard algorithm == .ed25519 else {
            throw UnsupportedSigningAlgorithmError()
        }

        return try deriveEd25519Key(
            mnemonic: mnemonic,
            bip39Passphrase: bip39Passphrase,
            hdPath: hdPath
        )
    }

    // EdDeriveKey derives and returns the Ed25519 private key for the given seed and HD path.
    static func deriveEd25519Key(
        mnemonic: String,
        bip39Passphrase: String,
        hdPath: String
    ) throws -> Data {
        let seed = try BIP39.makeSeed(
            mnemonic: mnemonic,
            password: bip39Passphrase
        )

        let (masterPrivateKey, chainCode) = HD.computeMasters(fromSeed: seed)

        guard !hdPath.isEmpty else {
            return masterPrivateKey
        }

        return try HD.derivePrivateKey(
            forPath: hdPath,
            privateKey: masterPrivateKey,
            chainCode: chainCode
        )
    }
    
    // CreateAccount creates an account Info object.
    func createAccount(
        keyWriter: KeyWriter,
        name: String,
        mnemonic: String,
        bip39Passphrase: String,
        encryptPassword: String,
        hdPath: String,
        algorithm: SigningAlgorithm
    ) throws -> KeyInfo {
        // create master key and derive first key for keyring
        let derivedPrivateKey = try options.deriveKey(
            mnemonic,
            bip39Passphrase,
            hdPath,
            algorithm
        )

        let privateKey = try options.generateKey(derivedPrivateKey, algorithm)

        guard !encryptPassword.isEmpty else {
            return writeOfflineKey(
                keyWriter: keyWriter,
                name: name,
                publicKey: privateKey.publicKey,
                algorithm: algorithm
            )
        }

        return keyWriter.writeLocalKey(
            name: name,
            privateKey: privateKey,
            passphrase: encryptPassword,
            algorithm: algorithm
        )
    }

    func writeOfflineKey(
        keyWriter: InfoWriter,
        name: String,
        publicKey: PublicKeyProtocol,
        algorithm: SigningAlgorithm
    ) -> KeyInfo {
        let info = OfflineInfo(
            name: name,
            publicKey: publicKey,
            algorithm: algorithm
        )
        
        keyWriter.writeInfo(name: name, info: info)
        return info
    }

    // SupportedAlgos returns a list of supported signing algorithms.
    var supportedAlgorithms: [SigningAlgorithm] {
        options.supportedAlgorithms
    }
}

// CreateHDPath returns BIP 44 object from account and index parameters.
func createHDPath(account: UInt32, index: UInt32) -> BIP44Params {
    .fundraiser(
        account: account,
        coinType: Configuration.configuration.coinType,
        addressIndex: index
    )
}

