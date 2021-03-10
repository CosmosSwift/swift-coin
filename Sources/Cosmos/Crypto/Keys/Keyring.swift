import Foundation
import ArgumentParser
import Tendermint

// TODO: This was inside a dependency called 99designs/keyring
// Check where is the best place to put this

struct KeyringItem: Codable {
    let key: String
    let data: Data
}

// Keyring provides the uniform interface over the underlying backends
protocol Keyring {
    // Returns an Item matching the key or ErrKeyNotFound
    func get(key: String) throws -> KeyringItem
    // Returns the non-secret parts of an Item
//    func metadata(key: String) throws -> Metadata
    // Stores an Item on the keyring
    func set(item: KeyringItem) throws
    // Removes the item with matching key
//    func remove(key: String) throws
    // Provides a slice of all keys stored on the keyring
    func keys() throws -> [String]
}

struct FileKeyring: Keyring {
    let rootDirectory: String
   
    var path: String {
        rootDirectory + "/file-keyring"
    }

    init(rootDirectory: String) throws {
        self.rootDirectory = rootDirectory
        
        try FileManager.default.createDirectory(
            atPath: path,
            withIntermediateDirectories: true
        )
    }
    
    func get(key: String) throws -> KeyringItem {
        let url = URL(fileURLWithPath: path + "/" + key)
        let data = try Data(contentsOf: url)
        return KeyringItem(key: key, data: data)
    }
     
    func set(item: KeyringItem) throws {
        let url = URL(fileURLWithPath: path + "/" + item.key)
        try item.data.write(to: url)
    }
    
    func keys() throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: path)
    }
}

public enum KeyringBackend: String, ExpressibleByArgument {
    case file = "file"
    case os = "os"
    case keyWallet = "kwallet"
    case pass = "pass"
    case test = "test"
}

// keyringKeybase implements the Keybase interface by using the Keyring library
// for account key persistence.
struct KeyringKeybase: Keybase, KeyWriter {
    static let maxPassphraseEntryAttempts = 3
    
    let base: BaseKeybase
    let database: Keyring
    
    init(database: Keyring, options: [KeybaseOption]) {
        self.base = BaseKeybase(options: options)
        self.database = database
    }
}

// NewKeyring creates a new instance of a keyring. Keybase
// options can be applied when generating this new Keybase.
// Available backends are "os", "file", "test".
public func makeKeyring(
    appName: String,
    backend: KeyringBackend,
    rootDirectory: String,
//    userInput: Reader,
    options: [KeybaseOption] = []
) throws -> Keybase {
    let database: Keyring

    switch backend {
    case .test:
        // TODO: Implement
        fatalError()
//        database = try open(lkbToKeyringConfig(appName, rootDir, nil, true))
    case .file:
        // TODO: Implement
        fatalError()
//        database = try open(newFileBackendKeyringConfig(appName, rootDir, userInput))
    case .os:
        database = try FileKeyring(rootDirectory: rootDirectory)
        // TODO: Implement
//        database = try open(lkbToKeyringConfig(appName, rootDir, userInput, false))
    case .keyWallet:
        // TODO: Implement
        fatalError()
//        database = try open(newKWalletBackendKeyringConfig(appName, rootDir, userInput))
    case .pass:
        // TODO: Implement
        fatalError()
//        database = try open(newPassBackendKeyringConfig(appName, rootDir, userInput))
    }
    
    return KeyringKeybase(database: database, options: options)
}

extension KeyringKeybase {
    // CreateMnemonic generates a new key and persists it to storage, encrypted
    // using the provided password. It returns the generated mnemonic and the key Info.
    // An error is returned if it fails to generate a key for the given algo type,
    // or if another key is already stored under the same name.
    func createMnemonic(
        name: String,
        language: Language,
        password: String,
        algorithm: SigningAlgorithm
    ) throws -> (info: KeyInfo, seed: String) {
        // TODO: Implement
        fatalError()
//        base.createMnemonic(
//            keyWriter: self,
//            name: name,
//            language: language,
//            password: password,
//            algorithm: algorithm
//        )
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
//        base.createLedger(
//            keyWriter: self,
//            name: name,
//            algorithm: algorithm,
//            humanReadablePart: humanReadablePart,
//            account: account,
//            index: index
//        )
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
//        base.createOffline(
//            keyWriter: self,
//            name: name,
//            publicKey: publicKey,
//            algorithm: algorithm
//        )
    }

    // CreateMulti creates a new reference to a multisig (offline) keypair. It
    // returns the created key Info object.
    func createMulti(
        name: String,
        publicKey: PublicKeyProtocol
    ) throws -> KeyInfo {
        // TODO: Implement
        fatalError()
//        base.writeMultiSignatureKey(
//            keyWriter: self,
//            name: name,
//            publicKey: publicKey
//        )
    }

    // List returns the keys from storage in alphabetical order.
    func list() throws -> [KeyInfo] {
        try database.keys().sorted().reduce(into: []) { result, key in
            guard key.hasSuffix(DatabaseKeybase.infoSuffix) else {
               return
            }
            
            let rawInfo = try database.get(key: key)

            guard !rawInfo.data.isEmpty else {
                return
                // TODO: throw error
                // throw KeyNotFound
            }

            let info = try unmarshalInfo(data: rawInfo.data)
            result.append(info)
        }
    }

    // Get returns the public information about one key.
    func get(name: String) throws -> KeyInfo {
        let key = DatabaseKeybase.infoKey(name: name)
        let info = try database.get(key: key.string)
        return try unmarshalInfo(data: info.data)
    }

    // GetByAddress fetches a key by address and returns its public information.
    func getByAddress(address: AccountAddress) throws -> KeyInfo {
        let key = DatabaseKeybase.addressKey(address: address)
        if let infoStr = String(data: try database.get(key: key.string).data, encoding: .utf8) {
            let info = try database.get(key: infoStr)
            return try unmarshalInfo(data: info.data)
        }
        throw Cosmos.Error.generic(reason: "Can't find address: \(address) in Keyring.")
    }

    // Sign signs an arbitrary set of bytes with the named key. It returns an error
    // if the key doesn't exist or the decryption fails.
    func sign(name: String, passphrase: String, message: Data) throws -> (Data, PublicKeyProtocol) {
        let keyInfo = try self.get(name: name)
            
        switch keyInfo.type {
        case .local:
            guard let localInfo = keyInfo as? LocalInfo else {
                fatalError("Malformed LocalInfo Key: \(keyInfo)")
            }

            guard let privateKey = MintKey.decryptArmorPrivateKey(armoredKey: localInfo.privateKeyArmor, passphrase: passphrase, algorithm: localInfo.algorithm.rawValue) else {
                throw Cosmos.Error.generic(reason: "Invalid Private Key Armor for LocalInfo Key: \(keyInfo)")
            }
            
            let sig = try privateKey.sign(message: message)
            
            return (sig, privateKey.publicKey)
            
            //privateKey
        //            if i.PrivKeyArmor == "" {
        //                return nil, nil, fmt.Errorf("private key not available")
        //            }
        //
        //            priv, err = cryptoAmino.PrivKeyFromBytes([]byte(i.PrivKeyArmor))
        //            if err != nil {
        //                return nil, nil, err
        //            }
        //        sig, err = priv.Sign(msg)
        //        if err != nil {
        //            return nil, nil, err
        //        }
        //
        //        return sig, priv.PubKey(), nil
        case .ledger:
            fatalError()
        //            return kb.base.SignWithLedger(info, msg)

        case .multi, .offline:
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
//                return nil, nil, fmt.Errorf("private key not available")
//            }
//
//            priv, err = cryptoAmino.PrivKeyFromBytes([]byte(i.PrivKeyArmor))
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

    // ExportPrivateKeyObject exports an armored private key object.
    func exportPrivateKeyObject(name: String, passphrase: String) throws -> PrivateKey {
        // TODO: Implement
        fatalError()
//        info, err := kb.Get(name)
//        if err != nil {
//            return nil, err
//        }
//
//        var priv tmcrypto.PrivKey
//
//        switch linfo := info.(type) {
//        case localInfo:
//            if linfo.PrivKeyArmor == "" {
//                err = fmt.Errorf("private key not available")
//                return nil, err
//            }
//
//            priv, err = cryptoAmino.PrivKeyFromBytes([]byte(linfo.PrivKeyArmor))
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

    // Export exports armored private key to the caller.
    func export(name: String) throws -> String {
        // TODO: Implement
        fatalError()
//        bz, err := kb.db.Get(string(infoKey(name)))
//        if err != nil {
//            return "", err
//        }
//
//        if bz.Data == nil {
//            return "", fmt.Errorf("no key to export with name: %s", name)
//        }
//
//        return mintkey.ArmorInfoBytes(bz.Data), nil
    }

    // ExportPubKey returns public keys in ASCII armored format. It retrieves an Info
    // object by its name and return the public key in a portable format.
    func exportPublicKey(name: String) throws -> String {
        // TODO: Implement
        fatalError()
//        bz, err := kb.Get(name)
//        if err != nil {
//            return "", err
//        }
//
//        if bz == nil {
//            return "", fmt.Errorf("no key to export with name: %s", name)
//        }
//
//        return mintkey.ArmorPubKeyBytes(bz.GetPubKey().Bytes(), string(bz.GetAlgo())), nil
    }

    // Import imports armored private key.
    func `import`(name: String, armor: String) throws {
        // TODO: Implement
        fatalError()
//        bz, _ := kb.Get(name)
//
//        if bz != nil {
//            pubkey := bz.GetPubKey()
//
//            if len(pubkey.Bytes()) > 0 {
//                return fmt.Errorf("cannot overwrite data for name: %s", name)
//            }
//        }
//
//        infoBytes, err := mintkey.UnarmorInfoBytes(armor)
//        if err != nil {
//            return err
//        }
//
//        info, err := unmarshalInfo(infoBytes)
//        if err != nil {
//            return err
//        }
//
//        kb.writeInfo(name, info)
//
//        err = kb.db.Set(keyring.Item{
//            Key:  string(addrKey(info.GetAddress())),
//            Data: infoKey(name),
//        })
//        if err != nil {
//            return err
//        }
//
//        return nil
    }

    // ExportPrivKey returns a private key in ASCII armored format. An error is returned
    // if the key does not exist or a wrong encryption passphrase is supplied.
    func exportPrivateKey(name: String, decryptPassphrase: String, encryptPassphrase: String) throws -> String {
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

    // ImportPrivKey imports a private key in ASCII armor format. An error is returned
    // if a key with the same name exists or a wrong encryption passphrase is
    // supplied.
    func importPrivateKey(name: String, armor: String, passphrase: String) throws {
        // TODO: Implement
        fatalError()
//        if kb.HasKey(name) {
//            return fmt.Errorf("cannot overwrite key: %s", name)
//        }
//
//        privKey, algo, err := mintkey.UnarmorDecryptPrivKey(armor, passphrase)
//        if err != nil {
//            return errors.Wrap(err, "failed to decrypt private key")
//        }
//
//        // NOTE: The keyring keystore has no need for a passphrase.
//        kb.writeLocalKey(name, privKey, "", SigningAlgo(algo))
//        return nil
    }

    // HasKey returns whether the key exists in the keyring.
    func hasKey(name: String) -> Bool {
        // TODO: Implement
        fatalError()
//        bz, _ := kb.Get(name)
//        return bz != nil
    }

    // ImportPubKey imports an ASCII-armored public key. It will store a new Info
    // object holding a public key only, i.e. it will not be possible to sign with
    // it as it lacks the secret key.
    func importPublicKey(name: String, armor: String) throws {
        // TODO: Implement
        fatalError()
//        bz, _ := kb.Get(name)
//        if bz != nil {
//            pubkey := bz.GetPubKey()
//
//            if len(pubkey.Bytes()) > 0 {
//                return fmt.Errorf("cannot overwrite data for name: %s", name)
//            }
//        }
//
//        pubBytes, algo, err := mintkey.UnarmorPubKeyBytes(armor)
//        if err != nil {
//            return err
//        }
//
//        pubKey, err := cryptoAmino.PubKeyFromBytes(pubBytes)
//        if err != nil {
//            return err
//        }
//
//        kb.base.writeOfflineKey(kb, name, pubKey, SigningAlgo(algo))
//        return nil
    }

    // Delete removes key forever, but we must present the proper passphrase before
    // deleting it (for security). It returns an error if the key doesn't exist or
    // passphrases don't match. The passphrase is ignored when deleting references to
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
//        err = kb.db.Remove(string(addrKey(info.GetAddress())))
//        if err != nil {
//            return err
//        }
//
//        err = kb.db.Remove(string(infoKey(name)))
//        if err != nil {
//            return err
//        }
//
//        return nil
    }

    // Update changes the passphrase with which an already stored key is encrypted.
    // The oldpass must be the current passphrase used for encryption, getNewpass is
    // a function to get the passphrase to permanently replace the current passphrase.
    func update(name: String, oldPassword: String, getNewPassword: () throws -> String) throws {
        // TODO: Implement
        fatalError()
//        info, err := kb.Get(name)
//        if err != nil {
//            return err
//        }
//
//        switch linfo := info.(type) {
//        case localInfo:
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
//            kb.writeLocalKey(name, key, newpass, linfo.GetAlgo())
//            return nil
//
//        default:
//            return fmt.Errorf("locally stored key required; received: %v", reflect.TypeOf(info).String())
//        }
    }

    // SupportedAlgos returns a list of supported signing algorithms.
    var supportedAlgorithms: [SigningAlgorithm] {
        base.supportedAlgorithms
    }

    // SupportedAlgosLedger returns a list of supported ledger signing algorithms.
    var supportedAlgorithmsLedger: [SigningAlgorithm] {
        // TODO: Implement
        fatalError()
//        base.supportedAlgorithmsLedger
    }

    // CloseDB releases the lock and closes the storage backend.
    func closeDatabase() {}

    func writeLocalKey(name: String, privateKey: PrivateKey, passphrase: String, algorithm: SigningAlgorithm) -> KeyInfo {
        // encrypt private key using keyring
        let publicKey = privateKey.publicKey
        
        let info = LocalInfo(
            name: name,
            publicKey: publicKey,
            // TODO: Check if using hex encoded string is good enough.
            privateKeyArmor: privateKey.data.hexEncodedString(),
            algorithm: algorithm
        )

        writeInfo(name: name, info: info)
        return info
    }

    func writeInfo(name: String, info: KeyInfo) {
        // write the info by key
        let key = DatabaseKeybase.infoKey(name: name)
        let serializedInfo = marshal(info: info)

        try! database.set(item: KeyringItem(
            key: key.string,
            data: serializedInfo
        ))

        try! database.set(item: KeyringItem(
            key: DatabaseKeybase.addressKey(address: info.address).string,
            data: key
        ))
    }

    // TODO: Implement
//    func lkbToKeyringConfig(appName, dir string, buf io.Reader, test bool) keyring.Config {
//        if test {
//            return keyring.Config{
//                AllowedBackends: []keyring.BackendType{keyring.FileBackend},
//                ServiceName:     appName,
//                FileDir:         filepath.Join(dir, fmt.Sprintf(testKeyringDirNameFmt, appName)),
//                FilePasswordFunc: func(_ string) (string, error) {
//                    return "test", nil
//                },
//            }
//        }
//
//        return keyring.Config{
//            ServiceName:      appName,
//            FileDir:          dir,
//            FilePasswordFunc: newRealPrompt(dir, buf),
//        }
//    }
//
//    func newKWalletBackendKeyringConfig(appName, _ string, _ io.Reader) keyring.Config {
//        return keyring.Config{
//            AllowedBackends: []keyring.BackendType{keyring.KWalletBackend},
//            ServiceName:     "kdewallet",
//            KWalletAppID:    appName,
//            KWalletFolder:   "",
//        }
//    }
//
//    func newPassBackendKeyringConfig(appName, dir string, _ io.Reader) keyring.Config {
//        prefix := filepath.Join(dir, fmt.Sprintf(keyringDirNameFmt, appName))
//        return keyring.Config{
//            AllowedBackends: []keyring.BackendType{keyring.PassBackend},
//            ServiceName:     appName,
//            PassPrefix:      prefix,
//        }
//    }
//
//    func newFileBackendKeyringConfig(name, dir string, buf io.Reader) keyring.Config {
//        fileDir := filepath.Join(dir, fmt.Sprintf(keyringDirNameFmt, name))
//        return keyring.Config{
//            AllowedBackends:  []keyring.BackendType{keyring.FileBackend},
//            ServiceName:      name,
//            FileDir:          fileDir,
//            FilePasswordFunc: newRealPrompt(fileDir, buf),
//        }
//    }
//
//    func newRealPrompt(dir string, buf io.Reader) func(string) (string, error) {
//        return func(prompt string) (string, error) {
//            keyhashStored := false
//            keyhashFilePath := filepath.Join(dir, "keyhash")
//
//            var keyhash []byte
//
//            _, err := os.Stat(keyhashFilePath)
//            switch {
//            case err == nil:
//                keyhash, err = ioutil.ReadFile(keyhashFilePath)
//                if err != nil {
//                    return "", fmt.Errorf("failed to read %s: %v", keyhashFilePath, err)
//                }
//
//                keyhashStored = true
//
//            case os.IsNotExist(err):
//                keyhashStored = false
//
//            default:
//                return "", fmt.Errorf("failed to open %s: %v", keyhashFilePath, err)
//            }
//
//            failureCounter := 0
//            for {
//                failureCounter++
//                if failureCounter > maxPassphraseEntryAttempts {
//                    return "", fmt.Errorf("too many failed passphrase attempts")
//                }
//
//                buf := bufio.NewReader(buf)
//                pass, err := input.GetPassword("Enter keyring passphrase:", buf)
//                if err != nil {
//                    fmt.Fprintln(os.Stderr, err)
//                    continue
//                }
//
//                if keyhashStored {
//                    if err := bcrypt.CompareHashAndPassword(keyhash, []byte(pass)); err != nil {
//                        fmt.Fprintln(os.Stderr, "incorrect passphrase")
//                        continue
//                    }
//                    return pass, nil
//                }
//
//                reEnteredPass, err := input.GetPassword("Re-enter keyring passphrase:", buf)
//                if err != nil {
//                    fmt.Fprintln(os.Stderr, err)
//                    continue
//                }
//
//                if pass != reEnteredPass {
//                    fmt.Fprintln(os.Stderr, "passphrase do not match")
//                    continue
//                }
//
//                saltBytes := tmcrypto.CRandBytes(16)
//                passwordHash, err := bcrypt.GenerateFromPassword(saltBytes, []byte(pass), 2)
//                if err != nil {
//                    fmt.Fprintln(os.Stderr, err)
//                    continue
//                }
//
//                if err := ioutil.WriteFile(dir+"/keyhash", passwordHash, 0555); err != nil {
//                    return "", err
//                }
//
//                return pass, nil
//            }
//        }
//    }
}
