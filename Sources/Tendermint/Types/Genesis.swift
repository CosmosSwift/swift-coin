import Foundation
import JSON

//------------------------------------------------------------
// core types for a genesis definition
// NOTE: any changes to the genesis definition should
// be reflected in the documentation:
// docs/tendermint-core/using-tendermint.md

// GenesisValidator is an initial validator.
public struct GenesisValidator: Codable {
    var address: Address
    let publicKey: PublicKey // TODO: should be an abstract PublicKey, but need to work out how to make it codable
    let power: Int64
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case address
        case publicKey = "pub_key"
        case power
        case name
    }
    public init(address: Address, publicKey: PublicKey, power: Int64, name: String) {
        self.address = address
        self.publicKey = publicKey
        self.power = power
        self.name = name
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address = try container.decode(HexadecimalData.self, forKey: .address)
        let publicKeyCodable = try container.decode(AnyProtocolCodable.self, forKey: .publicKey)
        guard let publicKey = publicKeyCodable.value as? PublicKey else {
            throw DecodingError.dataCorruptedError(
                forKey: .publicKey,
                in: container,
                debugDescription: "Invalid type for public key"
            )
        }

        let powerString = try container.decode(String.self, forKey: .power)
        let name = try container.decode(String.self, forKey: .name)
        
        guard let power = Int64(powerString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .power,
                in: container,
                debugDescription: "Invalid power"
            )
        }

        self.address = address
        self.publicKey = publicKey
        self.power = power
        self.name = name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(AnyProtocolCodable(publicKey), forKey: .publicKey)
        try container.encode("\(power)", forKey: .power)
        try container.encode(name, forKey: .name)
    }
}

struct ReadError: Error, CustomStringConvertible {
    var description: String
}

struct DecodeError: Error, CustomStringConvertible {
    var description: String
}

struct ValidationError: Error, CustomStringConvertible {
    let description: String
}

// GenesisDoc defines the initial conditions for a tendermint blockchain, in particular its validator set.
public struct GenesisDocument<AppState: Codable>: Codable {
    // MaxChainIDLen is a maximum length of the chain ID.
    static var maximumChainIDLength: Int { 50 }
    
    let genesisTime: Date
    public var chainID: String
    var consensusParameters: ConsensusParameters?
    public var validators: [GenesisValidator]?
    let appHash: Data
    public var appState: AppState?
    
    private enum CodingKeys: String, CodingKey {
        case genesisTime = "genesis_time"
        case chainID = "chain_id"
        case consensusParameters = "consensus_params"
        case validators
        case appHash = "app_hash"
        case appState = "app_state"
    }
    
    //------------------------------------------------------------
    // Make genesis state from file

    // GenesisDocFromJSON unmarshalls JSON data into a GenesisDoc.
    public init(jsonData: Data) throws {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        var genesisDocument = try decoder.decode(GenesisDocument.self, from: jsonData)
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
            throw ReadError(description: "Couldn't read GenesisDoc file: \(error)")
        }
        
        let genesisDocument: GenesisDocument<AppState>
        
        do {
            genesisDocument = try GenesisDocument<AppState>(jsonData: jsonData)
        } catch {
            throw DecodeError(description: "Error reading GenesisDoc at \(path): \(error)")
        }
        
        self = genesisDocument
    }
}

extension GenesisDocument {
    // SaveAs is a utility method for saving GenensisDoc as a JSON file.
    public func save(atFilePath path: String) throws {
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        let data = try encoder.encode(self)
        let url = URL(fileURLWithPath: path)
        try data.write(to: url)
        
        // TODO: Check if this is required
//        try! FileManager.default.setAttributes(
//            [.posixPermissions: NSNumber(value: Int16(0644))],
//            ofItemAtPath: path
//        )
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
    public mutating func validateAndComplete() throws {
        if chainID == "" {
            throw ValidationError(description: "genesis doc must include non-empty chain_id")
        }
        
        if chainID.count > Self.maximumChainIDLength {
            throw ValidationError(description: "chain_id in genesis doc is too long (max: \(Self.maximumChainIDLength)")
        }

        if let consensusParameters = self.consensusParameters {
            try consensusParameters.validate()
        } else {
            self.consensusParameters = .default
        }
        
    var validators = self.validators ?? []

        for (i, validator) in validators.enumerated() {
            if validator.power == 0 {
                throw ValidationError(description: "the genesis file cannot contain validators with no voting power: \(validator)")
            }
            
//            if validator.address.count > 0 && validator.publicKey.address != validator.address {
//                throw ValidationError(description: "incorrect address for validator \(validator) in the genesis file, should be \(validator.publicKey.address)")
//            }
//
//            if validator.address.isEmpty {
//                validators[i].address = validator.publicKey.address
//            }
        }
        
        self.validators = validators

        // TODO: Check if this is necessary
//        if genesisTime == 0 {
//            genesisTime = Date()
//        }
    }
}
