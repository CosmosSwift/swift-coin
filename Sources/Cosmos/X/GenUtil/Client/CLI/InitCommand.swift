import Foundation
import JSON
import ArgumentParser
import Tendermint

struct InitCommandError: Swift.Error, CustomStringConvertible {
    var description: String
}

struct PrintInfo: Codable {
    let moniker: String
    let chainID: String
    let nodeID: String
    let genesisTransactionsDirectory: String
    let appState: JSON
    
    private enum CodingKeys: String, CodingKey {
        case moniker
        case chainID = "chain_id"
        case nodeID = "node_id"
        case genesisTransactionsDirectory = "gentxs_dir"
        case appState = "app_message"
    }
}


// InitCmd returns a command that initializes all files needed for Tendermint
// and the respective application.
public struct InitCommand: ParsableCommand {
    public static var defaultHome: String!
    public static var codec: Codec!
    public static var moduleBasicManager: BasicManager!
    
    public static var configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize private validator, p2p, genesis, and application configuration files",
        discussion: "Initialize validators's and node's configuration files."
    )
    
    @Option(help: "node's home directory")
    var home: String = Self.defaultHome
    
    @Flag(name: .shortAndLong, help: "overwrite the genesis.json file")
    var overwrite: Bool = false
    
    @Option(name: .customLong("chain-id"), help: "genesis file chain-id, if left blank will be randomly created")
    var chainID: String = ""

    @Argument
    var moniker: String
    
    public init() {}
    
    public func run() throws {
        var configuration = ServerContext.configuration
        configuration.set(rootDirectory: home)
        var chainID = self.chainID

        if chainID == "" {
            chainID = "test-chain-\(Random.string(count: 6))"
        }

        let nodeID: String
        let vpk: PublicKey? // TODO: this should be replaced when we can properly unserialize a PublicKey from an Ed25519PublicKey
        let validatorPublicKey: Ed25519PublicKey
        
        do {
            (nodeID, vpk) = try configuration.initializeNodeValidatorFiles()
            validatorPublicKey = vpk as! Ed25519PublicKey
        } catch {
            throw error
        }

        configuration.moniker = moniker
        let genesisFilePath = configuration.genesisFilePath
        
        if !overwrite && FileManager.default.fileExists(atPath: genesisFilePath) {
            throw InitCommandError(description: "genesis.json file already exists: \(genesisFilePath)")
        }
        
        let appState = Self.moduleBasicManager.defaultGenesis()

        guard FileManager.default.fileExists(atPath: genesisFilePath) else {
            throw InitCommandError(description: "genesisFile does not exist")
        }
        
        var genesisDocument: GenesisDocument
        
        do {
            genesisDocument = try GenesisDocument(fileAtPath: genesisFilePath)
        } catch {
            throw CosmosError.wrap(
                error: error,
                description: "Failed to read genesis doc from file"
            )
        }

        genesisDocument.chainID = chainID
        
        genesisDocument.validators = [GenesisValidator(address: validatorPublicKey.address, publicKey: validatorPublicKey, power: 100, name: "LocalValidator_\(chainID)")] // TODO: here, should put the validator provided
        genesisDocument.appState = appState
        
        do {
            try genesisDocument.exportGenesisFile(atPath: genesisFilePath)
        } catch {
            throw CosmosError.wrap(
                error: error,
                description: "Failed to export genesis file"
            )
        }

        let printInfo = PrintInfo(
            moniker: configuration.moniker,
            chainID: chainID,
            nodeID: nodeID,
            genesisTransactionsDirectory: "",
            appState: appState
        )
        
        let configurationFilePath = configuration.rootDirectory + "/config/config.toml"
        configuration.writeConfigurationFile(atPath: configurationFilePath)
        try display(info: printInfo)
    }
    
    private func display(info: PrintInfo) throws {
        let encoder = JSONEncoder()
       
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        
        let data = try encoder.encode(info)
        print(data.string)
    }
}
