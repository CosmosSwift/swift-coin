import Foundation

// ConsensusParams contains consensus critical parameters that determine the
// validity of blocks.
struct ConsensusParameters: Codable {
    // MaxBlockSizeBytes is the maximum permitted size of the blocks.
    static let maximumBlockSizeBytes = 104857600 // 100MB

    // BlockPartSizeBytes is the size of one block part.
    static let blockPartSizeBytes = 65536 // 64kB

    // MaxBlockPartsCount is the maximum number of block parts.
    static let maximumBlockPartsCount = (maximumBlockSizeBytes / blockPartSizeBytes) + 1

    let block: BlockParameters
    let evidence: EvidenceParameters
    let validator: ValidatorParameters
}

// BlockParams define limits on the block size and gas plus minimum time
// between blocks.
struct BlockParameters: Codable {
    let maximumBytes: Int64
    let maximumGas: Int64
    
    // Minimum time increment between consecutive blocks (in milliseconds)
    // Not exposed to the application.
    let timeIotaMilliseconds: Int64
    
    private enum CodingKeys: String, CodingKey {
        case maximumBytes = "max_bytes"
        case maximumGas = "max_gas"
        case timeIotaMilliseconds = "time_iota_ms"
    }
    
    init(
        maximumBytes: Int64,
        maximumGas: Int64,
        timeIotaMilliseconds: Int64
    ) {
        self.maximumBytes = maximumBytes
        self.maximumGas = maximumGas
        self.timeIotaMilliseconds = timeIotaMilliseconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let maximumBytesString = try container.decode(String.self, forKey: .maximumBytes)
        let maximumGasString = try container.decode(String.self, forKey: .maximumGas)
        let timeIotaMillisecondsString = try container.decode(String.self, forKey: .timeIotaMilliseconds)
        
        guard let maximumBytes = Int64(maximumBytesString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .maximumBytes,
                in: container,
                debugDescription: "Invalid maximumBytes value: \(maximumBytesString)"
            )
        }
        
        guard let maximumGas = Int64(maximumGasString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .maximumGas,
                in: container,
                debugDescription: "Invalid maximumGas value: \(maximumGasString)"
            )
        }
        
        guard let timeIotaMilliseconds = Int64(timeIotaMillisecondsString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .timeIotaMilliseconds,
                in: container,
                debugDescription: "Invalid maximumGas value: \(timeIotaMillisecondsString)"
            )
        }
        
        self.maximumBytes = maximumBytes
        self.maximumGas = maximumGas
        self.timeIotaMilliseconds = timeIotaMilliseconds
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(maximumBytes)", forKey: .maximumBytes)
        try container.encode("\(maximumGas)", forKey: .maximumGas)
        try container.encode("\(timeIotaMilliseconds)", forKey: .timeIotaMilliseconds)
    }
}

// EvidenceParams determine how we handle evidence of malfeasance.
struct EvidenceParameters: Codable {
    // only accept new evidence more recent than this
    let maximumAgeNumberBlocks: Int64
    let maximumAgeDuration: Int64
    
    private enum CodingKeys: String, CodingKey {
        case maximumAgeNumberBlocks = "max_age_num_blocks"
        case maximumAgeDuration = "max_age_duration"
    }
    
    init(
        maximumAgeNumberBlocks: Int64,
        maximumAgeDuration: Int64
    ) {
        self.maximumAgeNumberBlocks = maximumAgeNumberBlocks
        self.maximumAgeDuration = maximumAgeDuration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let maximumAgeNumberBlocksString = try container.decode(String.self, forKey: .maximumAgeNumberBlocks)
        let maximumAgeDurationString = try container.decode(String.self, forKey: .maximumAgeDuration)

        guard let maximumAgeNumberBlocks = Int64(maximumAgeNumberBlocksString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .maximumAgeNumberBlocks,
                in: container,
                debugDescription: "Invalid maximumAgeNumberBlocks value: \(maximumAgeNumberBlocksString)"
            )
        }
        
        guard let maximumAgeDuration = Int64(maximumAgeDurationString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .maximumAgeDuration,
                in: container,
                debugDescription: "Invalid maximumAgeDuration value: \(maximumAgeDurationString)"
            )
        }
        
        self.maximumAgeNumberBlocks = maximumAgeNumberBlocks
        self.maximumAgeDuration = maximumAgeDuration
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(maximumAgeNumberBlocks)", forKey: .maximumAgeNumberBlocks)
        try container.encode("\(maximumAgeDuration)", forKey: .maximumAgeDuration)
    }
}

// ValidatorParams restrict the public key types validators can use.
// NOTE: uses ABCI pubkey naming, not Amino names.
struct ValidatorParameters: Codable {
    enum PublicKeyType: String, Codable {
        case ed25519
        case sr25519
        case secp256k1
    }

    let publicKeyTypes: [PublicKeyType]
    
    private enum CodingKeys: String, CodingKey {
        case publicKeyTypes = "pub_key_types"
    }
}

extension ConsensusParameters {
    // DefaultConsensusParams returns a default ConsensusParams.
    static var `default`: ConsensusParameters {
        ConsensusParameters(
            block: .default,
            evidence: .default,
            validator: .default
        )
    }
}

extension BlockParameters {
    // DefaultBlockParams returns a default BlockParams.
    static var `default`: BlockParameters {
        BlockParameters(
            maximumBytes: 22020096, // 21MB
            maximumGas: -1,
            timeIotaMilliseconds: 1000 // 1s
        )
    }
}

enum Time: RawRepresentable, Codable, CustomStringConvertible {
    case nanoSecond(TimeInterval)
    case microSecond(TimeInterval)
    case milliSecond(TimeInterval)
    case second(TimeInterval)
    case minute(TimeInterval)
    case hour(TimeInterval)
    
    init?(rawValue: Double) {
        self = .nanoSecond(rawValue)
    }
    
    var rawValue: TimeInterval {
        switch self {
        case .nanoSecond(let value):
            return value
        case .microSecond(let value):
            return value * 1000
        case .milliSecond(let value):
            return value * 1000 * 1000
        case .second(let value):
            return value * 1000 * 1000 * 1000
        case .minute(let value):
            return value * 1000 * 1000 * 1000 * 60
        case .hour(let value):
            return value * 1000 * 1000 * 1000 * 60 * 60
        }
    }
    
    var description: String {
        switch self {
        case .nanoSecond(let value):
            return "\(value)ns"
        case .microSecond(let value):
            return "\(value)us"
        case .milliSecond(let value):
            return "\(value)ms"
        case .second(let value):
            return "\(value)s"
        case .minute(let value):
            return "\(value)m"
        case .hour(let value):
            return "\(value)h"
        }
    }
}

extension EvidenceParameters {
    // DefaultEvidenceParams Params returns a default EvidenceParams.
    static var `default`: EvidenceParameters {
        EvidenceParameters(
            maximumAgeNumberBlocks: 100000, // 27.8 hrs at 1block/s,
            maximumAgeDuration: 48 * 60 * 60 * 1000 // 48 hours in millisecs
        )
    }
}

// DefaultValidatorParams returns a default ValidatorParams, which allows
// only ed25519 pubkeys.
extension ValidatorParameters {
    static var `default`: ValidatorParameters {
        ValidatorParameters(publicKeyTypes: [.ed25519])
    }
}

extension ConsensusParameters {
    // Validate validates the ConsensusParams to ensure all values are within their
    // allowed limits, and returns an error if they are not.
    func validate() throws {
        struct ValidationError: Error, CustomStringConvertible {
            let description: String
        }
        
        if block.maximumBytes <= 0 {
            throw ValidationError(description: "block.MaxBytes must be greater than 0. Got \(block.maximumBytes)")
        }
        
        if block.maximumBytes > Self.maximumBlockSizeBytes {
            throw ValidationError(description: "block.MaxBytes is too big. \(block.maximumBytes) > \(Self.maximumBlockSizeBytes)")
        }

        if block.maximumGas < -1 {
            throw ValidationError(description: "block.MaxGas must be greater or equal to -1. Got \(block.maximumGas)")
        }

        if block.timeIotaMilliseconds <= 0 {
            throw ValidationError(description: "block.TimeIotaMs must be greater than 0. Got \(block.timeIotaMilliseconds)")
        }

        if evidence.maximumAgeNumberBlocks <= 0 {
            throw ValidationError(description: "evidenceParams.MaxAgeNumBlocks must be greater than 0. Got \(evidence.maximumAgeNumberBlocks)")
        }

        if evidence.maximumAgeDuration <= 0 {
            throw ValidationError(description: "evidenceParams.MaxAgeDuration must be grater than 0 if provided, Got \(evidence.maximumAgeDuration)")
        }

        if validator.publicKeyTypes.count == 0 {
            throw ValidationError(description: "len(Validator.PubKeyTypes) must be greater than 0")
        }
    }
}
