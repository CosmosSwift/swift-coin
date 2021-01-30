import ArgumentParser

public struct KeysOptions: ParsableArguments {
    @Option(name: .customLong("keyring-backend"), help: "Select keyring's backend (os|file|test)")
    public var keyringBackend: KeyringBacked = .os

    public init() {}
}

// Commands registers a sub-tree of commands to interact with
// local private key storage.
public struct KeysCommand: ParsableCommand {
    public static var defaultHome: String!
    public static var codec: Codec!
    public static var moduleBasicManager: BasicManager!
    
    public static var configuration = CommandConfiguration(
        commandName: "keys",
        abstract: "Add or view local private keys",
        discussion:
        """
        Keys allows you to manage your local keystore for tendermint.
        
        These keys may be in any format supported by go-crypto and can be
        used by light-clients, full nodes, or any other application that
        needs to sign with a private key.
        """,
        subcommands: [
//            MnemonicKeyCommand.self,
            AddKeyCommand.self,
//            ExportKeyCommand.self,
//            ImportKeyCommand.self,
//            ListKeysCommand.self,
//            ShowKeysCommand.self,
//            DeleteKeyCommand.self,
//            UpdateKeyCommand.self,
//            ParseKeyStringCommand.self,
//            MigrateCommand.self,
        ]
    )

    public init() {}
}
