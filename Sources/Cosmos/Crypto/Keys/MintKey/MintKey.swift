import Tendermint

enum MintKey {}

//-----------------------------------------------------------------
// encrypt/decrypt with armor

extension MintKey {
    // Encrypt and armor the private key.
    static func encryptArmorPrivateKey(
        privateKey: PrivateKey,
        passphrase: String,
        algorithm: String
    ) -> String {
        // TODO: Implement
        fatalError()
//        let (saltData, encodedData) = encryptPrivateKey(
//            privateKey: privateKey,
//            passphrase: passphrase
//        )
//
//        let header: [String: String] = [
//            "kdf":  "bcrypt",
//            "salt": "\(saltData)"
//        ]
//
//        if algorithm != "" {
//            header[headerType] = algorithm
//        }
//
//        return Armor.encodeArmor(
//            blockTypePrivKey,
//            header: header,
//            encodedBytes: encodedBytes
//        )
    }
}

