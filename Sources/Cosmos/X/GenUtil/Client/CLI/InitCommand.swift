import Foundation
import ArgumentParser
import Tendermint

struct InitCommandError: Swift.Error, CustomStringConvertible {
    var description: String
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
        
        do {
            (nodeID, _) = try configuration.initializeNodeValidatorFiles()
        } catch {
            throw error
        }

        configuration.moniker = moniker
        let genesisFilePath = configuration.genesisFilePath
        
        if !overwrite && FileManager.default.fileExists(atPath: genesisFilePath) {
            throw InitCommandError(description: "genesis.json file already exists: \(genesisFilePath)")
        }
        
        let appState: Data
        
        do {
            appState = try Self.codec.marshalJSONIndent(value: Self.moduleBasicManager.defaultGenesis())
        } catch {
            throw CosmosError.wrap(
                error: error,
                description: "Failed to marshall default genesis state"
            )
        }

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
        genesisDocument.validators = []
        genesisDocument.appState = appState
        
        do {
            try genesisDocument.exportGenesisFile(atPath: genesisFilePath)
        } catch {
            throw CosmosError.wrap(
                error: error,
                description: "Failed to export genesis file"
            )
        }

//        let toPrint = newPrintInfo(Config.moniker, chainID, nodeID, "", appState)
        let configurationFilePath = configuration.rootDirectory + "/config/config.toml"
        configuration.writeConfigurationFile(atPath: configurationFilePath)
//        return displayInfo(cdc, toPrint)
    }
}
