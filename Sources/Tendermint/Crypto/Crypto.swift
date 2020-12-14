import Foundation

// An address is a []byte, but hex-encoded even in JSON.
// []byte leaves us the option to change the address length.
// Use an alias so Unmarshal methods (with ptr receivers) are available too.
public typealias Address = Data

public protocol PublicKey: Codable {
    var address: Address { get }
    var bytes: Data { get }
    func verifyBytes(message: Data, signature: Data) -> Bool
    func equals(other: PublicKey) -> Bool
}

public protocol PrivateKey {
    var bytes: Data { get }
    func sign(message: Data) throws -> Data
    var publicKey: PublicKey { get }
    func equals(other: PrivateKey) -> Bool
}
