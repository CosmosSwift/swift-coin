import Foundation

//------------------------------------------------------------
// core types for a genesis definition
// NOTE: any changes to the genesis definition should
// be reflected in the documentation:
// docs/tendermint-core/using-tendermint.md

// GenesisValidator is an initial validator.
public struct GenesisValidator: Codable {
    let address: Address
    // TODO: Sort out PublicKey being a protocol or not
//    let publicKey: PublicKey
    let power: Int64
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case address
//        case publicKey = "pub_key"
        case power
        case name
    }
}

// GenesisDoc defines the initial conditions for a tendermint blockchain, in particular its validator set.
public struct GenesisDocument: Codable {
    // MaxChainIDLen is a maximum length of the chain ID.
    static let maxChainIDLength = 50
    
    let genesisTime: Date
    public var chainID: String
//    let consensusParams: ConsensusParams?
    public var validators: [GenesisValidator]
    let appHash: Data
    public var appState: Data
    
    private enum CodingKeys: String, CodingKey {
        case genesisTime = "genesis_time"
        case chainID = "chain_id"
//        case consensusParams = "consensus_params"
        case validators
        case appHash = "app_hash"
        case appState = "app_state"
    }
    
    //------------------------------------------------------------
    // Make genesis state from file

    // GenesisDocFromJSON unmarshalls JSON data into a GenesisDoc.
    public init(jsonData: Data) throws {
        let genesisDocument = try JSONDecoder().decode(GenesisDocument.self, from: jsonData)
        try genesisDocument.validateAndComplete()
        self = genesisDocument
    }

    // GenesisDocFromFile reads JSON data from a file and unmarshalls it into a GenesisDoc.
    public init(fileAtPath path: String) throws {
        let jsonData: Data
        
        do {
            let url = URL(fileURLWithPath: path)
            jsonData = try Data(contentsOf: url)
        } catch {
            struct ReadError: Error, CustomStringConvertible {
                var description: String
            }
            
            throw ReadError(description: "Couldn't read GenesisDoc file: \(error)")
        }
        
        let genesisDocument: GenesisDocument
        
        do {
            genesisDocument = try GenesisDocument(jsonData: jsonData)
        } catch {
            struct DecodeError: Error, CustomStringConvertible {
                var description: String
            }
            
            throw DecodeError(description: "Error reading GenesisDoc at \(path): \(error)")
        }
        
        self = genesisDocument
    }
}

extension GenesisDocument {
    // SaveAs is a utility method for saving GenensisDoc as a JSON file.
    public func save(atFilePath: String) throws {
        // TODO: Implement
        fatalError()
//        genDocBytes, err := cdc.MarshalJSONIndent(genDoc, "", "  ")
//        if err != nil {
//            return err
//        }
//        return tmos.WriteFile(file, genDocBytes, 0644)
    }

    // ValidatorHash returns the hash of the validator set contained in the GenesisDoc
    var validatorHash: Data {
        // TODO: Implement
        fatalError()
//        vals := make([]*Validator, len(genDoc.Validators))
//        for i, v := range genDoc.Validators {
//            vals[i] = NewValidator(v.PubKey, v.Power)
//        }
//        vset := NewValidatorSet(vals)
//        return vset.Hash()
    }

    // ValidateAndComplete checks that all necessary fields are present
    // and fills in defaults for optional fields left empty
    public func validateAndComplete() throws {
        // TODO: Implement
        fatalError()
//        if genDoc.ChainID == "" {
//            return errors.New("genesis doc must include non-empty chain_id")
//        }
//        if len(genDoc.ChainID) > MaxChainIDLen {
//            return errors.Errorf("chain_id in genesis doc is too long (max: %d)", MaxChainIDLen)
//        }
//
//        if genDoc.ConsensusParams == nil {
//            genDoc.ConsensusParams = DefaultConsensusParams()
//        } else if err := genDoc.ConsensusParams.Validate(); err != nil {
//            return err
//        }
//
//        for i, v := range genDoc.Validators {
//            if v.Power == 0 {
//                return errors.Errorf("the genesis file cannot contain validators with no voting power: %v", v)
//            }
//            if len(v.Address) > 0 && !bytes.Equal(v.PubKey.Address(), v.Address) {
//                return errors.Errorf("incorrect address for validator %v in the genesis file, should be %v", v, v.PubKey.Address())
//            }
//            if len(v.Address) == 0 {
//                genDoc.Validators[i].Address = v.PubKey.Address()
//            }
//        }
//
//        if genDoc.GenesisTime.IsZero() {
//            genDoc.GenesisTime = tmtime.Now()
//        }
//
//        return nil
    }
}
