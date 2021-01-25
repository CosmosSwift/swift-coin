import Foundation
import Tendermint
import Bech32

// Constants defined here are the defaults value for address.
// You can use the specific values for your project.
// Add the follow lines to the `main()` of your server.
//
//    config := sdk.GetConfig()
//    config.SetBech32PrefixForAccount(yourBech32PrefixAccAddr, yourBech32PrefixAccPub)
//    config.SetBech32PrefixForValidator(yourBech32PrefixValAddr, yourBech32PrefixValPub)
//    config.SetBech32PrefixForConsensusNode(yourBech32PrefixConsAddr, yourBech32PrefixConsPub)
//    config.SetCoinType(yourCoinType)
//    config.SetFullFundraiserPath(yourFullFundraiserPath)
//    config.Seal()

// AddrLen defines a valid address length
let addressLength = 20

// Atom in https://github.com/satoshilabs/slips/blob/master/slip-0044.md
let coinType = 118

// BIP44Prefix is the parts of the BIP44 HD path that are fixed by
// what we used during the fundraiser.
let fullFundraiserPath = "44'/118'/0'/0/0"

public enum Prefix {
    // PrefixAccount is the prefix for account keys
    static let account = "acc"
    // PrefixValidator is the prefix for validator keys
    static let validator = "val"
    // PrefixConsensus is the prefix for consensus keys
    static let consensus = "cons"
    // PrefixPublic is the prefix for public keys
    static let publicKey = "pub"
    // PrefixOperator is the prefix for operator keys
    static let `operator` = "oper"

    // PrefixAddress is the prefix for addresses
    static let address = "addr"
}

public enum Bech32Prefix {
    // Bech32PrefixAccAddr defines the Bech32 prefix of an account's address
    static let main = "cosmos"
    // Bech32PrefixAccAddr defines the Bech32 prefix of an account's address
    static let accountAddress = main
    // Bech32PrefixAccPub defines the Bech32 prefix of an account's public key
    static let accountPublicKey = main + Prefix.publicKey
    // Bech32PrefixValAddr defines the Bech32 prefix of a validator's operator address
    static let validatorOperatorAddress = main + Prefix.validator + Prefix.operator
    // Bech32PrefixValPub defines the Bech32 prefix of a validator's operator public key
    static let validatorOperatorPublicKey = main + Prefix.validator + Prefix.operator + Prefix.publicKey
    // Bech32PrefixConsAddr defines the Bech32 prefix of a consensus node address
    static let consensusNodeAddress = main + Prefix.validator + Prefix.consensus
    // Bech32PrefixConsPub defines the Bech32 prefix of a consensus node public key
    static let consensNodePublicKey = main + Prefix.validator + Prefix.consensus + Prefix.publicKey
}

// Address is a common interface for different types of addresses used by the SDK
public protocol Address: Codable, CustomStringConvertible {
    func equals(_ other: Address) -> Bool
    var isEmpty: Bool { get }
    func marshal() throws -> Data
    func marshalJSON() throws -> Data
    var data: Data { get }
}

extension Address {
    // VerifyAddressFormat verifies that the provided bytes form a valid address
    // according to the default address rules or a custom address verifier set by
    // GetConfig().SetAddressVerifier()
    static func verifyAddressFormat(data: Data) throws {
        if let verifier = Configuration.configuration.addressVerifier {
            return try verifier(data)
        }

        if data.count != addressLength {
            throw Cosmos.Error.generic(reason: "incorrect address length")
        }
    }
}

// ----------------------------------------------------------------------------
// account
// ----------------------------------------------------------------------------

// AccAddress a wrapper around bytes meant to represent an account address.
// When marshaled to a string or JSON, it uses Bech32.
public struct AccountAddress: Equatable, Address {
    public let data: Data
    
    public init(data: Data = Data()) {
        self.data = data
    }

    // TODO: Simplify all of this codebase based only on the prefix,
    // which seems to be the only thing that differs between all the addresses.
    // AccAddressFromHex creates an AccAddress from a hex string.
    public init(hexEncoded: String) throws {
        guard !hexEncoded.isEmpty else {
            throw Cosmos.Error.generic(reason: "Decoding Bech32 address failed: must provide an address")
        }

        guard let data = Data(hexEncoded: hexEncoded) else {
            throw Cosmos.Error.generic(reason: "Decoding Bech32 address failed")
        }

        self.data = data
    }


    // AccAddressFromBech32 creates an AccAddress from a Bech32 string.
    public init(bech32Encoded: String) throws {
        guard !bech32Encoded.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.data = Data()
            return
        }

        let data = try Data(
            bech32Encoded: bech32Encoded,
            prefix: Configuration.bech32AccountAddressPrefix
        )
        
        try Self.verifyAddressFormat(data: data)
        self.data = data
    }


    // Returns boolean for whether two ValAddresses are Equal
    public func equals(_ other: Address) -> Bool {
        if self.isEmpty && other.isEmpty {
            return true
        }
        
        return data == other.data
    }

    // Returns boolean for whether an AccAddress is empty
    public var isEmpty: Bool {
        data.isEmpty
    }

    // Marshal returns the raw address bytes. It is needed for protobuf
    // compatibility.
    public func marshal() throws -> Data {
        // TODO: Implement
        fatalError()
    }

    // Unmarshal sets the address to the given data. It is needed for protobuf
    // compatibility.
    func unmarshal(data: Data) throws {
        // TODO: Implement
        fatalError()
    }

    // MarshalJSON marshals to JSON using Bech32.
    public func marshalJSON() throws -> Data {
        // TODO: Implement
        fatalError()
    }

    // MarshalYAML marshals to YAML using Bech32.
    func marshalYAML() throws -> Any {
        // TODO: Implement
        fatalError()
    }

    // UnmarshalJSON unmarshals from JSON assuming Bech32 encoding.
    func unmarshalJSON(data: Data) throws {
        // TODO: Implement
        fatalError()
    }

    // UnmarshalYAML unmarshals from YAML assuming Bech32 encoding.
    func unmarshalYAML(data: Data) throws {
        // TODO: Implement
        fatalError()
//        var s string
//
//        err := yaml.Unmarshal(data, &s)
//        if err != nil {
//            return err
//        }
//
//        va2, err := ValAddressFromBech32(s)
//        if err != nil {
//            return err
//        }
//
//        *va = va2
//        return nil
    }

    // String implements the Stringer interface.
    public var description: String {
        guard !data.isEmpty else {
            return ""
        }

        return try! Bech32.convertAndEncode(
            humanReadablePart: Configuration.bech32AccountAddressPrefix,
            data: data
        )
    }
}

// ----------------------------------------------------------------------------
// validator operator
// ----------------------------------------------------------------------------

// ValAddress defines a wrapper around bytes meant to present a validator's
// operator. When marshaled to a string or JSON, it uses Bech32.
public struct ValidatorAddress: Address {
    public let data: Data
    
    public init(data: Data = Data()) {
        self.data = data
    }
    
    // ValAddressFromHex creates a ValAddress from a hex string.
    public init(hexEncoded: String) throws {
        guard !hexEncoded.isEmpty else {
            throw Cosmos.Error.generic(reason: "Decoding Bech32 address failed: must provide an address")
        }

        guard let data = Data(hexEncoded: hexEncoded) else {
            throw Cosmos.Error.generic(reason: "Decoding Bech32 address failed")
        }

        self.data = data
    }

    // ValAddressFromBech32 creates a ValAddress from a Bech32 string.
    public init(bech32Encoded: String) throws {
        guard !bech32Encoded.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.data = Data()
            return
        }

        let data = try Data(
            bech32Encoded: bech32Encoded,
            prefix: Configuration.bech32ValidatorAddressPrefix
        )
        
        try Self.verifyAddressFormat(data: data)
        self.data = data
    }

    // Returns boolean for whether two ValAddresses are Equal
    public func equals(_ other: Address) -> Bool {
        if self.isEmpty && other.isEmpty {
            return true
        }
        
        return data == other.data
    }

    // Returns boolean for whether an AccAddress is empty
    public var isEmpty: Bool {
        data.isEmpty
    }

    // Marshal returns the raw address bytes. It is needed for protobuf
    // compatibility.
    public func marshal() throws -> Data {
        // TODO: Implement
        fatalError()
    }

    // Unmarshal sets the address to the given data. It is needed for protobuf
    // compatibility.
    func unmarshal(data: Data) throws {
        // TODO: Implement
        fatalError()
    }

    // MarshalJSON marshals to JSON using Bech32.
    public func marshalJSON() throws -> Data {
        // TODO: Implement
        fatalError()
    }

    // MarshalYAML marshals to YAML using Bech32.
    func marshalYAML() throws -> Any {
        // TODO: Implement
        fatalError()
    }

    // UnmarshalJSON unmarshals from JSON assuming Bech32 encoding.
    func unmarshalJSON(data: Data) throws {
        // TODO: Implement
        fatalError()
    }

    // UnmarshalYAML unmarshals from YAML assuming Bech32 encoding.
    func unmarshalYAML(data: Data) throws {
        // TODO: Implement
        fatalError()
//        var s string
//
//        err := yaml.Unmarshal(data, &s)
//        if err != nil {
//            return err
//        }
//
//        va2, err := ValAddressFromBech32(s)
//        if err != nil {
//            return err
//        }
//
//        *va = va2
//        return nil
    }

    // String implements the Stringer interface.
    public var description: String {
        guard !data.isEmpty else {
            return ""
        }

        return try! Bech32.convertAndEncode(
            humanReadablePart: Configuration.bech32ValidatorAddressPrefix,
            data: data
        )
    }
}

// ----------------------------------------------------------------------------
// consensus node
// ----------------------------------------------------------------------------

// ConsAddress defines a wrapper around bytes meant to present a consensus node.
// When marshaled to a string or JSON, it uses Bech32.
public struct ConsensusAddress: Address {
    public let data: Data
    
    public init(data: Data = Data()) {
        self.data = data
    }
    
    // ValAddressFromHex creates a ValAddress from a hex string.
    public init(hexEncoded: String) throws {
        guard !hexEncoded.isEmpty else {
            throw Cosmos.Error.generic(reason: "Decoding Bech32 address failed: must provide an address")
        }

        guard let data = Data(hexEncoded: hexEncoded) else {
            throw Cosmos.Error.generic(reason: "Decoding Bech32 address failed")
        }

        self.data = data
    }

    // ValAddressFromBech32 creates a ValAddress from a Bech32 string.
    public init(bech32Encoded: String) throws {
        guard !bech32Encoded.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.data = Data()
            return
        }

        let data = try Data(
            bech32Encoded: bech32Encoded,
            prefix: Configuration.bech32ConsensusAddressPrefix
        )
        
        try Self.verifyAddressFormat(data: data)
        self.data = data
    }

    // Returns boolean for whether two ValAddresses are Equal
    public func equals(_ other: Address) -> Bool {
        if self.isEmpty && other.isEmpty {
            return true
        }
        
        return data == other.data
    }

    // Returns boolean for whether an AccAddress is empty
    public var isEmpty: Bool {
        data.isEmpty
    }

    // Marshal returns the raw address bytes. It is needed for protobuf
    // compatibility.
    public func marshal() throws -> Data {
        // TODO: Implement
        fatalError()
    }

    // Unmarshal sets the address to the given data. It is needed for protobuf
    // compatibility.
    func unmarshal(data: Data) throws {
        // TODO: Implement
        fatalError()
    }

    // MarshalJSON marshals to JSON using Bech32.
    public func marshalJSON() throws -> Data {
        // TODO: Implement
        fatalError()
    }

    // MarshalYAML marshals to YAML using Bech32.
    func marshalYAML() throws -> Any {
        // TODO: Implement
        fatalError()
    }

    // UnmarshalJSON unmarshals from JSON assuming Bech32 encoding.
    func unmarshalJSON(data: Data) throws {
        // TODO: Implement
        fatalError()
    }

    // UnmarshalYAML unmarshals from YAML assuming Bech32 encoding.
    func unmarshalYAML(data: Data) throws {
        // TODO: Implement
        fatalError()
//        var s string
//
//        err := yaml.Unmarshal(data, &s)
//        if err != nil {
//            return err
//        }
//
//        va2, err := ValAddressFromBech32(s)
//        if err != nil {
//            return err
//        }
//
//        *va = va2
//        return nil
    }

    // String implements the Stringer interface.
    public var description: String {
        guard !data.isEmpty else {
            return ""
        }

        return try! Bech32.convertAndEncode(
            humanReadablePart: Configuration.bech32ConsensusAddressPrefix,
            data: data
        )
    }
}

extension Data {
    // GetFromBech32 decodes a bytestring from a Bech32 encoded string.
    init(bech32Encoded: String, prefix: String) throws {
        guard !bech32Encoded.isEmpty else {
            throw Cosmos.Error.generic(reason: "decoding Bech32 address failed: must provide an address")
        }

        let (hrp, data) = try Bech32.decodeAndConvert(bech32Encoded)

        guard hrp == prefix else {
            throw Cosmos.Error.generic(reason: "invalid Bech32 prefix; expected \(prefix), got \(hrp)")
        }

        self = data
    }
}

