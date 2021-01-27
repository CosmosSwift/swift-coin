import Foundation
import Tendermint

// Transactions messages must fulfill the `Message`
public protocol Message: ProtocolCodable {
    // Return the message type.
    // Must be alphanumeric or empty.
    var route: String { get }

    // Returns a human-readable string for the message, intended for utilization
    // within tags
    var type: String { get }

    // ValidateBasic does a simple validation check that
    // doesn't require access to any other information.
    func validateBasic() throws

    // Get the canonical byte representation of the Msg.
    var signedData: Data { get }

    // Returns the addresses of signers that must sign.
    // CONTRACT: All signatures must be present to be valid.
    // CONTRACT: Returns addrs in some deterministic order.
    var signers: [AccountAddress] { get }
}

//__________________________________________________________

// Transactions objects must fulfill the Tx
public protocol Transaction: ProtocolCodable {
    // Gets the all the transaction's messages.
    var messages: [Message] { get }

    // ValidateBasic does a simple and lightweight validation check that doesn't
    // require access to any other information.
    func validateBasic() throws
}

//__________________________________________________________

// TxDecoder unmarshals transaction bytes
public typealias TransactionDecoder = (_ transactionBytes: Data) throws -> Transaction

// TxEncoder marshals transaction to bytes
public typealias TransactionEncoder = (_ transaction: Transaction) throws -> Data
