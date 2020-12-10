import Foundation

// Transactions messages must fulfill the `Message`
public protocol Message {
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
    func getSignBytes() -> Data

    // Returns the addresses of signers that must sign.
    // CONTRACT: All signatures must be present to be valid.
    // CONTRACT: Returns addrs in some deterministic order.
    func getSigners() -> [AccountAddress]
}
