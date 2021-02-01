import CryptoKit
import Foundation
import iAVLPlusCore
import Merkle






extension Data: InitialisableProtocol {}

public struct TestHasher: HasherProtocol {
    public typealias Coder = TestWire

    public typealias Hash = Foundation.Data

    static var size: Int = 32

    public static func hash<Data>(_ value: Data) -> Hash where Data: DataProtocol {
        return SHA256.hash(data: value).withUnsafeBytes { Hash($0) }
    }

    public var hash: Hash {
        Self.Hash(data)
    }

    private var data: Data

    public init?<Data>(bytes: Data) where Data: DataProtocol {
        guard bytes.count <= 32 else {
            return nil
        }
        data = Foundation.Data(bytes)
    }
}

//extension TestHasher.Hash: Comparable {
//    public static func < (lhs: TestHasher.Hash, rhs: TestHasher.Hash) -> Bool {
//        let size = Swift.min(lhs.count, rhs.count)
//        for i in 0 ..< lhs.count - size where lhs[lhs.count - 1 - i] != 0 {
//            return false
//        }
//        for i in 0 ..< size where lhs[size - 1 - i] >= rhs[size - 1 - i] {
//            return false
//        }
//        return true
//    }
//}

public struct TestWire: CoderProtocol, CoderType {
    public static func decode<T: Decodable>(_: T.Type, from: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: from)
    }

    public static func encode<T: Encodable>(_ object: T) throws -> Data {
        return try JSONEncoder().encode(object)
    }
    
    public static func encode(_ to: inout Data, int64: Int64) {
        to.append(withUnsafeBytes(of: int64.bigEndian) { Data($0) })
    }

    public static func encode(_ to: inout Data, int8: Int8) {
        to.append(withUnsafeBytes(of: int8.bigEndian) { Data($0) })
    }

    public static func encode<Bytes>(_ to: inout Data, bytes: Bytes) where Bytes: DataProtocol {
        to.append(contentsOf: bytes)
    }
    
    public static func mustMarshalBinaryLengthPrefixed<ProofOperator: ProofOperatorProtocol>(_: ProofOperator) -> Data {
        // TODO: implement properly
        fatalError("Not implemented")
        // Data()
    }
}
