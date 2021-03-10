import Foundation
import Crypto
import Bcrypt
import Tendermint
import DataConvertible

enum MintKey {}

//-----------------------------------------------------------------
// encrypt/decrypt with armor

extension MintKey {
    static let blockTypePrivateKey = "TENDERMINT PRIVATE KEY"
    static let headerType = "type"
    
    // Encrypt and armor the private key.
    static func encryptArmorPrivateKey(
        privateKey: PrivateKey,
        passphrase: String,
        algorithm: String
    ) -> String {
        let (salt, encryptedData) = encrypt(
            privateKey: privateKey,
            passphrase: passphrase
        )

        var headers: [String: String] = [
            "kdf": "bcrypt",
            "salt": salt.string
        ]

        if algorithm != "" {
            headers[headerType] = algorithm
        }

        return Armor.encodeArmor(
            blockType: blockTypePrivateKey,
            headers: headers,
            data: encryptedData
        )
    }
    
    // encrypt the given privKey with the passphrase using a randomly
    // generated salt and the xsalsa20 cipher. returns the salt and the
    // encrypted priv key.
    static func encrypt(privateKey: PrivateKey, passphrase: String) -> (salt: Data, encryptedData: Data) {
        let salt = Bcrypt.generateSalt(cost: 12)
        var key: Data
        
        do {
            key = try Bcrypt.hash(passphrase, salt: salt).data
        } catch {
            fatalError("Error generating bcrypt key from passphrase: \(error)")
        }
        
        key = Data(SHA256.hash(data: key)) // get 32 bytes
        
        return (salt.data, key)
        #warning("Private keys are not encrypted")
        // TODO: Actually encrypt the key (and adjust decryption below)
//        return (salt.data, xsalsa20symmetric.encryptSymmetric(privateKey.data, key))
    }
    
    static func decryptArmorPrivateKey(armoredKey: String,
                                       passphrase: String,
                                       algorithm: String) -> PrivateKey? {
        #warning("Private keys are not encrypted")
        // TODO: when encryption is performed, effectively decrypt the key]
        guard let data = Data(hexEncoded: armoredKey) else {
            return nil
        }
        return try? Ed25519PrivateKey(data: data)
    }

}

