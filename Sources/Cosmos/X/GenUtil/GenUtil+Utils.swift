import Foundation
import Tendermint

extension GenesisDocument {
    // ExportGenesisFile creates and writes the genesis configuration to disk. An
    // error is returned if building or writing the configuration to file fails.
    func exportGenesisFile(atPath genesisFilePath: String) throws {
        try validateAndComplete()
        try save(atFilePath: genesisFilePath)
    }
}

extension Tendermint.Configuration {
    // InitializeNodeValidatorFiles creates private validator and p2p configuration files.
    // TODO: Make validatorPublicKey not optional
    func initializeNodeValidatorFiles() throws -> (nodeID: String, validatorPublicKey: PublicKey?) {
        let nodeKey = try P2P.loadOrGenerateNodeKey(atPath: nodeKeyFilePath)
        let nodeID = nodeKey.id

        try FileManager.default.ensureDirectoryExists(
            atPath: FilePath.directoryPath(for: privateValidatorKeyFile),
            mode: 0777
        )

        try FileManager.default.ensureDirectoryExists(
            atPath: FilePath.directoryPath(for: privateValidatorStateFile),
            mode: 0777
        )

        // TODO: Implement
//        let validatorPublicKey = try FilePrivateValidator.loadOrGenerate(
//            privateValidatorKeyFile,
//            privateValidatorStateFile
//        ).publicKey
        // TODO: Return validatorPublicKey
        return (nodeID, nil)
    }
}
