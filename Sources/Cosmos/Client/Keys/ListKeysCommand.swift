import ArgumentParser

// ListKeysCmd lists all keys in the key store.
struct ListKeysCommand: ParsableCommand {
    @OptionGroup
    private var clientOptions: ClientOptions
    
    @OptionGroup
    private var keysOptions: KeysOptions
    
    public static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all keys",
        discussion:
        """
        Show key info for the given name.
        """
    )

    @Flag(
        name: [.customLong("indent")],
        help: "Add indent to JSON response"
    )
    var isIndentEnabled: Bool = false
    
    @Flag(
        name: [.customShort("n"), .customLong("list-names")],
        help: "List names only"
    )
    var isListNamesEnabled: Bool = false
    
    public init() {}
    
    func run() throws {
        let keybase = try makeKeyring(
            appName: Configuration.keyringServiceName,
            backend: keysOptions.keyringBackend,
            rootDirectory: clientOptions.home
            // buffer: buffer
        )

        let infos = try keybase.list()
        
        guard isListNamesEnabled else {
            return printInfos(infos: infos, output: clientOptions.output)
        }

        for info in infos {
            print(info.name)
        }
    }
}
