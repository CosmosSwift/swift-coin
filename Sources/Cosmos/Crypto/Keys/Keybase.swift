import Foundation
import Tendermint
import Database
import DataConvertible

// Language is a language to create the BIP 39 mnemonic in.
// Currently, only english is supported though.
// Find a list of all supported languages in the BIP 39 spec (word lists).
public enum Language: Int {
    // English is the default language to create a mnemonic.
    // It is the only supported language by this package.
    case english = 1
}

// ErrUnsupportedSigningAlgo is raised when the caller tries to use a
// different signing scheme than secp256k1.
struct UnsupportedSigningAlgorithmError: Swift.Error, CustomStringConvertible {
    let description: String = "unsupported signing algo"
}

// ErrUnsupportedLanguage is raised when the caller tries to use a
// different language than english for creating a mnemonic sentence.
struct UnsupportedLanguageError: Swift.Error, CustomStringConvertible {
    let description: String = "unsupported language: only english is supported"
}

// dbKeybase combines encryption and storage implementation to provide a
// full-featured key manager.
//
// NOTE: dbKeybase will be deprecated in favor of keyringKeybase.
struct DatabaseKeybase: Keybase, KeyWriter {
    static let addressSuffix = "address"
    static let infoSuffix = "info"

    let base: BaseKeybase
    let database: Database
    
    // newDBKeybase creates a new dbKeybase instance using the provided DB for
    // reading and writing keys.
    init(database: Database, options: [KeybaseOption] = []) {
        self.base = BaseKeybase(options: options)
        self.database = database
    }
}

extension DatabaseKeybase {
    // CreateMnemonic generates a new key and persists it to storage, encrypted
    // using the provided password. It returns the generated mnemonic and the key Info.
    // It returns an error if it fails to generate a key for the given key algorithm
    // type, or if another key is already stored under the same name.
    func createMnemonic(
        name: String,
        language: Language,
        password: String,
        algorithm: SigningAlgorithm
    ) throws -> (info: KeyInfo, seed: String) {
        // TODO: Implement
        fatalError()
//        return kb.base.CreateMnemonic(kb, name, language, passwd, algo)
    }

    // CreateAccount converts a mnemonic to a private key and persists it, encrypted
    // with the given password.
    func createAccount(
        name: String,
        mnemonic: String,
        bip39Password: String,
        encryptPassword: String,
        hdPath: String,
        algorithm: SigningAlgorithm
    ) throws -> KeyInfo {
         try base.createAccount(
            keyWriter: self,
            name: name,
            mnemonic: mnemonic,
            bip39Passphrase: bip39Password,
            encryptPassword: encryptPassword,
            hdPath: hdPath,
            algorithm: algorithm
         )
    }

    // CreateLedger creates a new locally-stored reference to a Ledger keypair.
    // It returns the created key info and an error if the Ledger could not be queried.
    func createLedger(
        name: String,
        algorithm: SigningAlgorithm,
        humanReadablePart: String,
        account: UInt32,
        index: UInt32
    ) throws -> KeyInfo {
        // TODO: Implement
        fatalError()
//        return kb.base.CreateLedger(kb, name, algo, hrp, account, index)
    }

    // CreateOffline creates a new reference to an offline keypair. It returns the
    // created key info.
    func createOffline(
        name: String,
        publicKey: PublicKeyProtocol,
        algorithm: SigningAlgorithm
    ) throws -> KeyInfo {
        // TODO: Implement
        fatalError()
//        return kb.base.writeOfflineKey(kb, name, pub, algo), nil
    }

    // CreateMulti creates a new reference to a multisig (offline) keypair. It
    // returns the created key info.
    func createMulti(
        name: String,
        publicKey: PublicKeyProtocol
    ) throws -> KeyInfo {
        // TODO: Implement
        fatalError()
//        return kb.base.writeMultisigKey(kb, name, pub), nil
    }

    // List returns the keys from storage in alphabetical order.
    func list() throws -> [KeyInfo] {
        // TODO: Implement
        fatalError()
//        var res []Info
//
//        iter, err := kb.db.Iterator(nil, nil)
//        if err != nil {
//            return nil, err
//        }
//
//        defer iter.Close()
//
//        for ; iter.Valid(); iter.Next() {
//            key := string(iter.Key())
//
//            // need to include only keys in storage that have an info suffix
//            if strings.HasSuffix(key, infoSuffix) {
//                info, err := unmarshalInfo(iter.Value())
//                if err != nil {
//                    return nil, err
//                }
//
//                res = append(res, info)
//            }
//        }
//
//        return res, nil
    }

    // Get returns the public information about one key.
    func get(name: String) throws -> KeyInfo {
        let key = Self.infoKey(name: name)
        
        guard let data = try database.get(key: key) else {
            throw KeyNotFoundError(name: name)
        }

        return try unmarshalInfo(data: data)
    }

    // GetByAddress returns Info based on a provided AccAddress. An error is returned
    // if the address does not exist.
    func getByAddress(address: AccountAddress) throws -> KeyInfo {
        let key = Self.addressKey(address: address)
        
        guard let name = try database.get(key: key), let data = try database.get(key: name.data) else {
            throw Cosmos.Error.generic(reason: "Address not found: \(address)")
        }

        return try unmarshalInfo(data: data)

//        ik, err := kb.db.Get(addrKey(address))
//        if err != nil {
//            return nil, err
//        }
//
//        if len(ik) == 0 {
//            return nil, fmt.Errorf("key with address %s not found", address)
//        }
//
//        bs, err := kb.db.Get(ik)
//        if err != nil {
//            return nil, err
//        }
//
//        return unmarshalInfo(bs)
    }

    // Sign signs the msg with the named key. It returns an error if the key doesn't
    // exist or the decryption fails.
    func sign(
        name: String,
        passphrase: String,
        message: Data
    ) throws -> (Data, PublicKeyProtocol) {
        
        let infoKey = try self.get(name: name)
        
        switch infoKey.type {
        case .local:
            guard let localInfo = infoKey as? LocalInfo else {
                throw Cosmos.Error.generic(reason: "LocalInfo key malformed: \(infoKey)")
            }
            
            guard let privateKey = MintKey.decryptArmorPrivateKey(armoredKey: localInfo.privateKeyArmor, passphrase: passphrase, algorithm: localInfo.algorithm.rawValue) else {
                throw Cosmos.Error.generic(reason: "Not able to decrypt private key for \(localInfo.name)")
            }
            
            let sig = try privateKey.sign(message: message)
            
            return (sig, privateKey.publicKey)
        case .ledger:
            fatalError()
        //            return kb.base.SignWithLedger(info, msg)
        case .offline, .multi:
            fatalError()
        //            return kb.base.DecodeSignature(info, msg)

        }
        
//        info, err := kb.Get(name)
//        if err != nil {
//            return
//        }
//
//        var priv tmcrypto.PrivKey
//
//        switch i := info.(type) {
//        case localInfo:
//            if i.PrivKeyArmor == "" {
//                err = fmt.Errorf("private key not available")
//                return
//            }
//
//            priv, _, err = mintkey.UnarmorDecryptPrivKey(i.PrivKeyArmor, passphrase)
//            if err != nil {
//                return nil, nil, err
//            }
//
//        case ledgerInfo:
//            return kb.base.SignWithLedger(info, msg)
//
//        case offlineInfo, multiInfo:
//            return kb.base.DecodeSignature(info, msg)
//        }
//
//        sig, err = priv.Sign(msg)
//        if err != nil {
//            return nil, nil, err
//        }
//
//        return sig, priv.PubKey(), nil
    }

    // ExportPrivateKeyObject returns a PrivKey object given the key name and
    // passphrase. An error is returned if the key does not exist or if the Info for
    // the key is invalid.
    func exportPrivateKeyObject(
        name: String,
        passphrase: String
    ) throws -> PrivateKey {
        // TODO: Implement
        fatalError()
//        info, err := kb.Get(name)
//        if err != nil {
//            return nil, err
//        }
//
//        var priv tmcrypto.PrivKey
//
//        switch i := info.(type) {
//        case localInfo:
//            linfo := i
//            if linfo.PrivKeyArmor == "" {
//                err = fmt.Errorf("private key not available")
//                return nil, err
//            }
//
//            priv, _, err = mintkey.UnarmorDecryptPrivKey(linfo.PrivKeyArmor, passphrase)
//            if err != nil {
//                return nil, err
//            }
//
//        case ledgerInfo, offlineInfo, multiInfo:
//            return nil, errors.New("only works on local private keys")
//        }
//
//        return priv, nil
    }

    func export(name: String) throws -> String {
        // TODO: Implement
        fatalError()
//        bz, err := kb.db.Get(infoKey(name))
//        if err != nil {
//            return "", err
//        }
//
//        if bz == nil {
//            return "", fmt.Errorf("no key to export with name %s", name)
//        }
//
//        return mintkey.ArmorInfoBytes(bz), nil
    }

    // ExportPubKey returns public keys in ASCII armored format. It retrieves a Info
    // object by its name and return the public key in a portable format.
    func exportPublicKey(name: String) throws -> String {
        // TODO: Implement
        fatalError()
//        bz, err := kb.db.Get(infoKey(name))
//        if err != nil {
//            return "", err
//        }
//
//        if bz == nil {
//            return "", fmt.Errorf("no key to export with name %s", name)
//        }
//
//        info, err := unmarshalInfo(bz)
//        if err != nil {
//            return
//        }
//
//        return mintkey.ArmorPubKeyBytes(info.GetPubKey().Bytes(), string(info.GetAlgo())), nil
    }

    // ExportPrivKey returns a private key in ASCII armored format.
    // It returns an error if the key does not exist or a wrong encryption passphrase
    // is supplied.
    func exportPrivateKey(
        name: String,
        decryptPassphrase: String,
        encryptPassphrase: String
    ) throws -> String {
        // TODO: Implement
        fatalError()
//        priv, err := kb.ExportPrivateKeyObject(name, decryptPassphrase)
//        if err != nil {
//            return "", err
//        }
//
//        info, err := kb.Get(name)
//        if err != nil {
//            return "", err
//        }
//
//        return mintkey.EncryptArmorPrivKey(priv, encryptPassphrase, string(info.GetAlgo())), nil
    }

    // ImportPrivKey imports a private key in ASCII armor format. It returns an
    // error if a key with the same name exists or a wrong encryption passphrase is
    // supplied.
    func importPrivateKey(
        name: String,
        armor: String,
        passphrase: String
    ) throws {
        // TODO: Implement
        fatalError()
//        if _, err := kb.Get(name); err == nil {
//            return errors.New("Cannot overwrite key " + name)
//        }
//
//        privKey, algo, err := mintkey.UnarmorDecryptPrivKey(armor, passphrase)
//        if err != nil {
//            return errors.Wrap(err, "couldn't import private key")
//        }
//
//        kb.writeLocalKey(name, privKey, passphrase, SigningAlgo(algo))
//        return nil
    }

    
    func `import`(name: String, armor: String) throws {
        // TODO: Implement
        fatalError()
//        bz, err := kb.db.Get(infoKey(name))
//        if err != nil {
//            return err
//        }
//
//        if len(bz) > 0 {
//            return errors.New("cannot overwrite data for name " + name)
//        }
//
//        infoBytes, err := mintkey.UnarmorInfoBytes(armor)
//        if err != nil {
//            return
//        }
//
//        kb.db.Set(infoKey(name), infoBytes)
//        return nil
    }

    // ImportPubKey imports ASCII-armored public keys. Store a new Info object holding
    // a public key only, i.e. it will not be possible to sign with it as it lacks the
    // secret key.
    func importPublicKey(name: String, armor: String) throws {
        // TODO: Implement
        fatalError()
//        bz, err := kb.db.Get(infoKey(name))
//        if err != nil {
//            return err
//        }
//
//        if len(bz) > 0 {
//            return errors.New("cannot overwrite data for name " + name)
//        }
//
//        pubBytes, algo, err := mintkey.UnarmorPubKeyBytes(armor)
//        if err != nil {
//            return
//        }
//
//        pubKey, err := cryptoAmino.PubKeyFromBytes(pubBytes)
//        if err != nil {
//            return
//        }
//
//        kb.base.writeOfflineKey(kb, name, pubKey, SigningAlgo(algo))
//        return
    }

    // Delete removes key forever, but we must present the proper passphrase before
    // deleting it (for security). It returns an error if the key doesn't exist or
    // passphrases don't match. Passphrase is ignored when deleting references to
    // offline and Ledger / HW wallet keys.
    func delete(name: String, passphrase: String, skipPass: Bool) throws {
        // TODO: Implement
        fatalError()
//        // verify we have the proper password before deleting
//        info, err := kb.Get(name)
//        if err != nil {
//            return err
//        }
//
//        if linfo, ok := info.(localInfo); ok && !skipPass {
//            if _, _, err = mintkey.UnarmorDecryptPrivKey(linfo.PrivKeyArmor, passphrase); err != nil {
//                return err
//            }
//        }
//
//        kb.db.DeleteSync(addrKey(info.GetAddress()))
//        kb.db.DeleteSync(infoKey(name))
//
//        return nil
    }

    // Update changes the passphrase with which an already stored key is
    // encrypted.
    //
    // oldpass must be the current passphrase used for encryption,
    // getNewpass is a function to get the passphrase to permanently replace
    // the current passphrase
    func update(
        name: String,
        oldPassword: String,
        getNewPassword: () throws -> String
    ) throws {
        // TODO: Implement
        fatalError()
//        info, err := kb.Get(name)
//        if err != nil {
//            return err
//        }
//
//        switch i := info.(type) {
//        case localInfo:
//            linfo := i
//
//            key, _, err := mintkey.UnarmorDecryptPrivKey(linfo.PrivKeyArmor, oldpass)
//            if err != nil {
//                return err
//            }
//
//            newpass, err := getNewpass()
//            if err != nil {
//                return err
//            }
//
//            kb.writeLocalKey(name, key, newpass, i.GetAlgo())
//            return nil
//
//        default:
//            return fmt.Errorf("locally stored key required. Received: %v", reflect.TypeOf(info).String())
//        }
    }

    // CloseDB releases the lock and closes the storage backend.
    func closeDatabase() {
        try? database.close()
    }

    // SupportedAlgos returns a list of supported signing algorithms.
    var supportedAlgorithms: [SigningAlgorithm] {
        base.supportedAlgorithms
    }

    // SupportedAlgosLedger returns a list of supported ledger signing algorithms.
    var supportedAlgorithmsLedger: [SigningAlgorithm] {
        // TODO: Implement
        fatalError()
//        return kb.base.SupportedAlgosLedger()
    }

    func writeLocalKey(
        name: String,
        privateKey: PrivateKey,
        passphrase: String,
        algorithm: SigningAlgorithm
    ) -> KeyInfo {
        // encrypt private key using passphrase
        let privateKeyArmor = MintKey.encryptArmorPrivateKey(
            privateKey: privateKey,
            passphrase: passphrase,
            algorithm: algorithm.rawValue
        )

        // make Info
        let publicKey = privateKey.publicKey
        
        let info = LocalInfo(
            name: name,
            publicKey: publicKey,
            privateKeyArmor: privateKeyArmor,
            algorithm: algorithm
        )

        writeInfo(name: name, info: info)
        return info
    }

    func writeInfo(name: String, info: KeyInfo) {
        // write the info by key
        let key = Self.infoKey(name: name)
        let serializedInfo = marshal(info: info)

        try? database.setSync(key: key, value: serializedInfo)
        // store a pointer to the infokey by address for fast lookup
        let addressKey = Self.addressKey(address: info.address)
        try? database.setSync(key: addressKey, value: key)
    }

    static func addressKey(address: AccountAddress) -> Data {
        "\(address.description).\(addressSuffix)".data
    }
    
    static func infoKey(name: String) -> Data {
        "\(name).\(infoSuffix)".data
    }
}

extension DatabaseKeybase {
    // NewInMemory creates a transient keybase on top of in-memory storage
    // instance useful for testing purposes and on-the-fly key generation.
    // Keybase options can be applied when generating this new Keybase.
    static func inMemory(options: [KeybaseOption] = []) -> DatabaseKeybase {
        DatabaseKeybase(
            database: InMemoryDatabase(),
            options: options
        )
    }
}
