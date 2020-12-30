import Foundation
import IAVL

extension ImmutableTree: Tree {}

// Tree defines an interface that both mutable and immutable IAVL trees
// must implement. For mutable IAVL trees, the interface is directly
// implemented by an iavl.MutableTree. For an immutable IAVL tree, a wrapper
// must be made.
protocol Tree {
    func has(key: Data) -> Bool
    func get(key: Data) -> (index: Int64, value: Data?)
    @discardableResult
    func set(key: Data, value: Data) -> Bool
    @discardableResult
    func remove(key: Data) -> (Data, Bool)
    func saveVersion() throws -> (Data, Int64)
    func deleteVersion(version: Int64) throws
    func deleteVersions(versions: [Int64]) throws
    var version: Int64 { get }
    var hash: Data? { get }
    func versionExists(version: Int64) -> Bool
    func getVersioned(key: Data, version: Int64) -> (index: Int64, value: Data?)
    func getVersionedWithProof(key: Data, version: Int64) throws -> (Data, ProofRange)
    func getImmutable(version: Int64) throws -> ImmutableTree
}

// immutableTree is a simple wrapper around a reference to an iavl.ImmutableTree
// that implements the Tree interface. It should only be used for querying
// and iteration, specifically at previous heights.

extension ImmutableTree {
    func set(key: Data, value: Data) -> Bool {
        fatalError("cannot call 'Set' on an immutable IAVL tree")
    }

    func remove(key: Data) -> (Data, Bool) {
        fatalError("cannot call 'Remove' on an immutable IAVL tree")
    }

    func saveVersion() throws -> (Data, Int64) {
        fatalError("cannot call 'SaveVersion' on an immutable IAVL tree")
    }

    func deleteVersion(version: Int64) throws {
        fatalError("cannot call 'DeleteVersion' on an immutable IAVL tree")
    }

    func deleteVersions(versions: [Int64]) throws {
        fatalError("cannot call 'DeleteVersions' on an immutable IAVL tree")
    }

    func versionExists(version: Int64) -> Bool {
        self.version == version
    }

    func getVersioned(key: Data, version: Int64) -> (index: Int64, value: Data?) {
        guard self.version == version else {
            return (-1, nil)
        }

        // TODO: Implement
        fatalError()
//        return get(key: key)
    }

    func getVersionedWithProof(key: Data, version: Int64) throws -> (Data, ProofRange) {
        guard self.version == version else {
            throw Cosmos.Error.generic(reason: "version mismatch on immutable IAVL tree; got: \(version), expected: \(self.version)")
        }

        // TODO: Implement
        fatalError()
//        return getWithProof(key: key)
    }

    func getImmutable(version: Int64) throws -> ImmutableTree {
        guard self.version == version else {
            throw Cosmos.Error.generic(reason: "version mismatch on immutable IAVL tree; got: \(version), expected: \(self.version)")
        }

        return self
    }
}
