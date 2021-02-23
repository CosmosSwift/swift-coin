import ArgumentParser

// ShowKeysCmd shows key information for a given key name.
struct ShowKeysCommand: ParsableCommand {
    @OptionGroup
    private var clientOptions: ClientOptions
    
    @OptionGroup
    private var keysOptions: KeysOptions
    
    public static var configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show key info for the given name",
        discussion:
        """
        Return public details of a single local key. If multiple names are
        provided, then an ephemeral multisig key will be created under the name "multi"
        consisting of all the keys provided by name and multisig threshold.
        """
    )
    
    @Option(
        name: .customLong("bech"),
        help: "The Bech32 prefix encoding for a key (acc|val|cons)"
    )
    var bechPrefix: Prefix = .account

    @Flag(
        name: [.customShort("a"), .customLong("address")],
        help: "Output the address only (overrides --output)"
    )
    var isShowAddressEnabled: Bool = false

    @Flag(
        name: [.customShort("p"), .customLong("pubkey")],
        help: "Output the public key only (overrides --output)"
    )
    var isShowPublicKeyEnabled: Bool = false
    
    @Flag(
        name: [.customShort("d"), .customLong("device")],
        help: "Output the address in a ledger device"
    )
    var isShowDeviceEnabled: Bool = false
    
    @Option(
        name: .customLong("multisig-threshold"),
        help: "K out of N required signatures"
    )
    var multiSignatureThreshold: UInt = 1

    @Flag(
        name: [.customLong("indent")],
        help: "Add indent to JSON response"
    )
    var isIndentEnabled: Bool = false
    
    @Argument
    var names: [String]

    public init() {}
    
    func run() throws {
        let info: KeyInfo
//
        let keybase = try makeKeyring(
            appName: Configuration.keyringServiceName,
            backend: keysOptions.keyringBackend,
            rootDirectory: clientOptions.home
//            cmd.InOrStdin()
        )

        if names.count == 1 {
            info = try keybase.get(name: names[0])
        } else {
            // TODO: Implement
            fatalError()
//            pks := make([]tmcrypto.PubKey, len(args))
//            for i, keyName := range args {
//                info, err := kb.Get(keyName)
//                if err != nil {
//                    return err
//                }
//
//                pks[i] = info.GetPubKey()
//            }
//
//            multisigThreshold := viper.GetInt(flagMultiSigThreshold)
//            err = validateMultisigThreshold(multisigThreshold, len(args))
//            if err != nil {
//                return err
//            }
//
//            multikey := multisig.NewPubKeyMultisigThreshold(multisigThreshold, pks)
//            info = keys.NewMultiInfo(defaultMultiSigKeyName, multikey)
        }

//        if isShowAddr && isShowPubKey {
//            return errors.New("cannot use both --address and --pubkey at once")
//        }
//
//        if isOutputSet && (isShowAddr || isShowPubKey) {
//            return errors.New("cannot use --output with --address or --pubkey")
//        }
//
        let bechKeyOutput = try Self.bechKeyOutput(bechPrefix: bechPrefix)
        
        if isShowAddressEnabled {
            printKeyAddress(
                info: info,
                bechKeyOutput: bechKeyOutput
            )
        } else if isShowPublicKeyEnabled {
            // TODO: Implement
            fatalError()
//            printPubKey(info, bechKeyOutput)
        } else {
            printKeyInfo(
                keyInfo: info,
                bechKeyOutput: bechKeyOutput,
                output: clientOptions.output
            )
        }
//
        if isShowDeviceEnabled {
//            if isShowPubKey {
//                return fmt.Errorf("the device flag (-d) can only be used for addresses not pubkeys")
//            }
//            if viper.GetString(FlagBechPrefix) != "acc" {
//                return fmt.Errorf("the device flag (-d) can only be used for accounts")
//            }
//            // Override and show in the device
//            if info.GetType() != keys.TypeLedger {
//                return fmt.Errorf("the device flag (-d) can only be used for accounts stored in devices")
//            }
//
//            hdpath, err := info.GetPath()
//            if err != nil {
//                return nil
//            }
//
//            return crypto.LedgerShowAddress(*hdpath, info.GetPubKey())
        }
    }
    
    static func validateMultiSignatureThreshold(k: Int, nKeys: Int) throws {
        struct InvalidThresholdError: Swift.Error, CustomStringConvertible {
            var description: String
        }
        
        if k <= 0 {
            throw InvalidThresholdError(description: "threshold must be a positive integer")
        }
        
        if nKeys < k {
            throw InvalidThresholdError(description: "threshold k of n multisignature: \(nKeys) < \(k)")
        }
    }

    static func bechKeyOutput(bechPrefix: Prefix) throws -> BechKeyOutput {
        switch bechPrefix {
        case .account:
            return bech32KeyOutput
        case .validator:
            // TODO: Implement
            fatalError()
//            return bech32ValKeyOutput
        case .consensus:
            // TODO: Implement
            fatalError()
//            return bech32ConsKeyOutput
        default:
            struct InvalidPrefixError: Swift.Error, CustomStringConvertible {
                var description: String
            }
            
            throw InvalidPrefixError(description: "invalid Bech32 prefix encoding provided: \(bechPrefix)")
        }
    }
}
