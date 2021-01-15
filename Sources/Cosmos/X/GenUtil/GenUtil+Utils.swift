import Foundation
import Tendermint

extension GenesisDocument {
    // ExportGenesisFile creates and writes the genesis configuration to disk. An
    // error is returned if building or writing the configuration to file fails.
    mutating func exportGenesisFile(atPath genesisFilePath: String) throws {
        try validateAndComplete()
        try save(atFilePath: genesisFilePath)
    }
}

extension Tendermint.Configuration {
    // InitializeNodeValidatorFiles creates private validator and p2p configuration files.
    func initializeNodeValidatorFiles() throws -> (nodeID: String, validatorPublicKey: PublicKey?) {
        try FileManager.default.ensureDirectoryExists(
            atPath: FilePath.directoryPath(for: nodeKeyFilePath),
            mode: 0o777
        )

        let nodeKey = try P2P.loadOrGenerateNodeKey(atPath: nodeKeyFilePath)
        let nodeID = nodeKey.id

        try FileManager.default.ensureDirectoryExists(
            atPath: FilePath.directoryPath(for: privateValidatorKeyFile),
            mode: 0o777
        )

        try FileManager.default.ensureDirectoryExists(
            atPath: FilePath.directoryPath(for: privateValidatorStateFile),
            mode: 0o777
        )

        let validatorPublicKey = try FilePrivateValidator.loadOrGenerateFilePrivateValidatorKey(atPath: privateValidatorKeyFile).publicKey
        try FilePrivateValidator.loadOrGenerateFilePrivateValidatorState(atPath: privateValidatorStateFile)
        return (nodeID, validatorPublicKey)
    }
}
