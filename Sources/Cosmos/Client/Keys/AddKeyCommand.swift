import Foundation
import ArgumentParser
import BIP39

// AddKeyCommand defines a keys command to add a generated or recovered private key to keybase.
public struct AddKeyCommand: ParsableCommand {
    // DefaultKeyPass contains the default key password for genesis transactions
    private static let defaultKeyPassword = "12345678"
    private static let mnemonicEntropySize = 256

    @OptionGroup
    private var clientOptions: ClientOptions
    
    @OptionGroup
    private var keysOptions: KeysOptions
    
    public static var configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add an encrypted private key (either newly generated or recovered), encrypt it, and save to disk",
        discussion:
        """
        Derive a new private key and encrypt to disk.
        Optionally specify a BIP39 mnemonic, a BIP39 passphrase to further secure the mnemonic,
        and a bip32 HD path to derive a specific account. The key will be stored under the given name
        and encrypted with the given password. The only input that is required is the encryption password.

        If run with -i, it will prompt the user for BIP44 path, BIP39 mnemonic, and passphrase.
        The flag --recover allows one to recover a key from a seed passphrase.
        If run with --dry-run, a key would be generated (or recovered) but not stored to the
        local keystore.
        Use the --pubkey flag to add arbitrary public keys to the keystore for constructing
        multisig transactions.

        You can add a multisig key by passing the list of key names you want the public
        key to be composed of to the --multisig flag and the minimum number of signatures
        required through --multisig-threshold. The keys are sorted by address, unless
        the flag --nosort is set.
        """
    )
    
    @Option(
        name: .customLong("multisig"),
        help: "Construct and store a multisig public key (implies --pubkey)"
    )
    var multiSignatureKeys: [String] = []
    
    @Option(
        name: .customLong("multisig-threshold"),
        help: "K out of N required signatures. For use in conjunction with --multisig"
    )
    var multiSignatureThreshold: UInt = 1
    
    @Flag(
        name: .customLong("nosort"),
        help: "Keys passed to --multisig are taken in the order they're supplied"
    )
    var isNoSortEnabled: Bool = false
    
    @Option(
        name: .customLong("pubkey"),
        help: "Parse a public key in bech32 format and save it to disk"
    )
    var publicKey: String = ""
    
    @Flag(
        name: [.customShort("i"), .customLong("interactive")],
        help: "Interactively prompt user for BIP39 passphrase and mnemonic"
    )
    var isInteractiveEnabled: Bool = false
    
    @Flag(
        name: .customLong("ledger"),
        help: "Store a local reference to a private key on a Ledger device"
    )
    var isUseLedgerEnabled: Bool = false
    
    @Flag(
        name: .customLong("recover"),
        help: "Provide seed phrase to recover existing key instead of creating"
    )
    var isRecoverEnabled: Bool = false
    
    @Flag(
        name: .customLong("no-backup"),
        help: "Don't print out seed phrase (if others are watching the terminal)"
    )
    var isNoBackupEnabled: Bool = false
    
    @Flag(
        name: .customLong("dry-run"),
        help: "Perform action, but don't add key to local keystore"
    )
    var isDryRunEnabled: Bool = false
    
    @Option(
        name: .customLong("hd-path"),
        help: "Manual HD Path derivation (overrides BIP44 config)"
    )
    var hdPath: String = ""
    
    @Option(
        name: .customLong("account"),
        help: "Account number for HD derivation"
    )
    var account: UInt32 = 0
    
    @Option(
        name: .customLong("index"),
        help: "Address index number for HD derivation"
    )
    var index: UInt32 = 0
    
    @Flag(
        name: .customLong("indent"),
        help: "Add indent to JSON response"
    )
    var isIndentResponseEnabled: Bool = false
    
    @Option(
        name: .customLong("algo"),
        help: "Key signing algorithm to generate keys for"
    )
    var keyAlgorithm: SigningAlgorithm = .ed25519

    @Argument
    var name: String
    
    public init() {}
    
    public func run() throws {
//        inBuf := bufio.NewReader(cmd.InOrStdin())
        let keybase = try self.keybase(transient: isDryRunEnabled) //, buffer: inBuf)
        try addKey(keybase: keybase) //, inBuf)
    }
    
    func keybase(transient: Bool) throws -> Keybase { //, buffer: Reader) throws -> Keybase {
        if transient {
            return DatabaseKeybase.inMemory()
        }

        return try makeKeyring(
            appName: Configuration.keyringServiceName,
            backend: keysOptions.keyringBackend,
            rootDirectory: clientOptions.home
            // buffer: buffer
        )
    }
    
    /*
    input
        - bip39 mnemonic
        - bip39 passphrase
        - bip44 path
        - local encryption password
    output
        - armor encrypted private key (saved to file)
    */
    func addKey(keybase: Keybase) throws { //, buffer: Reader) throws {
        let showMnemonic = !isNoBackupEnabled
        let algorithm = keyAlgorithm

        guard keybase.isSupported(algorithm: algorithm) else {
            throw UnsupportedSigningAlgorithmError()
        }

        if !isDryRunEnabled {
            do {
                let k = try keybase.get(name: name)
                // TODO: Implement
                fatalError()
//                // account exists, ask for user confirmation
//                let response = try input.getConfirmation(fmt.Sprintf("override the existing name %s", name), inBuf)
//
//                if !response {
//                    return errors.New("aborted")
//                }
            } catch {
                // Noop
            }

            if !multiSignatureKeys.isEmpty {
                // TODO: Implement
                fatalError()
//                var pks []crypto.PubKey
//
//                multisigThreshold := viper.GetInt(flagMultiSigThreshold)
//                if err := validateMultisigThreshold(multisigThreshold, len(multisigKeys)); err != nil {
//                    return err
//                }
//
//                for _, keyname := range multisigKeys {
//                    k, err := kb.Get(keyname)
//                    if err != nil {
//                        return err
//                    }
//                    pks = append(pks, k.GetPubKey())
//                }
//
//                // Handle --nosort
//                if !viper.GetBool(flagNoSort) {
//                    sort.Slice(pks, func(i, j int) bool {
//                        return bytes.Compare(pks[i].Address(), pks[j].Address()) < 0
//                    })
//                }
//
//                pk := multisig.NewPubKeyMultisigThreshold(multisigThreshold, pks)
//                if _, err := kb.CreateMulti(name, pk); err != nil {
//                    return err
//                }
//
//                cmd.PrintErrf("Key %q saved to disk.\n", name)
//                return nil
            }
        }
        
        if !publicKey.isEmpty {
            // TODO: Implement
            fatalError()
//            pk, err := sdk.GetPubKeyFromBech32(sdk.Bech32PubKeyTypeAccPub, viper.GetString(FlagPublicKey))
//            if err != nil {
//                return err
//            }
//            _, err = kb.CreateOffline(name, pk, algo)
//            if err != nil {
//                return err
//            }
//            return nil
        }

        let useBIP44 = !hdPath.isEmpty
        let hdPath: String

        if useBIP44 {
            hdPath = createHDPath(account: account, index: index).description
        } else {
            hdPath = self.hdPath
        }

        // If we're using ledger, only thing we need is the path and the bech32 prefix.
        if isUseLedgerEnabled {
            // TODO: Implement
            fatalError()
//            if !useBIP44 {
//                return errors.New("cannot set custom bip32 path with ledger")
//            }
//
//            if !keys.IsSupportedAlgorithm(kb.SupportedAlgosLedger(), algo) {
//                return keys.ErrUnsupportedSigningAlgo
//            }
//
//            bech32PrefixAccAddr := sdk.GetConfig().GetBech32AccountAddrPrefix()
//            info, err := kb.CreateLedger(name, keys.Secp256k1, bech32PrefixAccAddr, account, index)
//            if err != nil {
//                return err
//            }
//
//            return printCreate(cmd, info, false, "")
        }
//
        // Get bip39 mnemonic
        var mnemonic: String = ""
        var bip39Passphrase: String = ""

        if isInteractiveEnabled || isRecoverEnabled {
            // TODO: Implment
            fatalError()
//            bip39Message := "Enter your bip39 mnemonic"
//            if !viper.GetBool(flagRecover) {
//                bip39Message = "Enter your bip39 mnemonic, or hit enter to generate one."
//            }
//
//            mnemonic, err = input.GetString(bip39Message, inBuf)
//            if err != nil {
//                return err
//            }
//
//            if !bip39.IsMnemonicValid(mnemonic) {
//                return errors.New("invalid mnemonic")
//            }
        }

        // TODO: Implement
        if mnemonic.isEmpty {
            // read entropy seed straight from crypto.Rand and convert to mnemonic
            let entropySeed = try BIP39.makeEntropy(bitSize: Self.mnemonicEntropySize)
            mnemonic = try BIP39.makeMnemonic(entropy: entropySeed)
        }

        // override bip39 passphrase
        if isInteractiveEnabled {
            // TODO: Implement
            fatalError()
//            bip39Passphrase, err = input.GetString(
//                "Enter your bip39 passphrase. This is combined with the mnemonic to derive the seed. "+
//                    "Most users should just hit enter to use the default, \"\"", inBuf)
//            if err != nil {
//                return err
//            }
//
//            // if they use one, make them re-enter it
//            if len(bip39Passphrase) != 0 {
//                p2, err := input.GetString("Repeat the passphrase:", inBuf)
//                if err != nil {
//                    return err
//                }
//
//                if bip39Passphrase != p2 {
//                    return errors.New("passphrases don't match")
//                }
//            }
        }

        let info = try keybase.createAccount(
            name: name,
            mnemonic: mnemonic,
            bip39Password: bip39Passphrase,
            encryptPassword: Self.defaultKeyPassword,
            hdPath: hdPath,
            algorithm: algorithm
        )

        // Recover key from seed passphrase
        if isRecoverEnabled {
//            // Hide mnemonic from output
//            showMnemonic = false
//            mnemonic = ""
        }

        try printOutput(
            info: info,
            showMnemonic: showMnemonic,
            mnemonic: mnemonic
        )
    }
    
    func printOutput(info: KeyInfo, showMnemonic: Bool, mnemonic: String) throws {
        switch clientOptions.output {
        case .text:
            print("", to: &OutputStream.standardError)
            
            printKeyInfo(
                keyInfo: info,
                bechKeyOutput: bech32KeyOutput,
                output: clientOptions.output
            )

            // print mnemonic unless requested not to.
            if showMnemonic {
                print("\n**Important** write this mnemonic phrase in a safe place.", to: &OutputStream.standardError)
                print("It is the only way to recover your account if you ever forget your password.", to: &OutputStream.standardError)
                print(mnemonic, to: &OutputStream.standardError)
            }
        case .json:
            // TODO: Implement
            fatalError()
            
//            let out = try keys.bech32KeyOutput(info)
//
//            if showMnemonic {
//                out.mnemonic = mnemonic
//            }
//
//            let jsonString: Data
//
//            if isIndentResponseEnabled {
//                jsonString = try KeysCdc.MarshalJSONIndent(out, "", "  ")
//            } else {
//                jsonString = try KeysCdc.MarshalJSON(out)
//            }
//
//            print(jsonString.string, to: &OutputStream.standardError)
        }
    }
}

// TODO: Move this into a separate module

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public enum OutputStream {
    public static var standardError = StandardErrorOutputStream()
}

public struct StandardErrorOutputStream: TextOutputStream {
    public mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}
