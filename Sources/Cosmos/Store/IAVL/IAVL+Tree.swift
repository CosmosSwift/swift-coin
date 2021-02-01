import Foundation
import iAVLPlusCore
import InMemoryNodeDB
import Merkle
import Database

public typealias ImmutableTree = InMemoryNode<Data,Data,TestHasher>
public typealias Node = InMemoryNode<Data,Data,TestHasher>
public typealias MutableTree = InMemoryNodeStorage<Data,Data,TestHasher>


// Tree defines an interface that both mutable and immutable IAVL trees
// must implement. For mutable IAVL trees, the interface is directly
// implemented by an iavl.MutableTree. For an immutable IAVL tree, a wrapper
// must be made.
public protocol Tree {
    func has(_ key: Data) throws -> Bool
    func get(_ key: Data) -> (index: Int64, value: Data?)
    var version: Int64 { get }
    var hash: Data { get }
  }

public protocol MTree {
    func has(key: Data) throws -> Bool
    func get(key: Data) -> (index: Int64, value: Data?)
    @discardableResult
    func set(key: Data, value: Data) throws -> Bool
    @discardableResult
    func remove(key: Data) -> (Data?, Bool)
    // func saveVersion() throws -> (Data, Int64)
    func deleteVersion(version: Int64) throws
    func deleteVersions(versions: [Int64]) throws
    var version: Int64 { get }
    var hash: Data { get }
    func versionExists(version: Int64) -> Bool
    func getVersioned(key: Data, version: Int64) throws -> (index: Int64, value: Data?)
    func getVersionedWithProof(_ key: Data, _ version: Int64) throws -> (Data?, RangeProof<Node>)
    func getImmutable(version: Int64) throws -> ImmutableTree
}

// immutableTree is a simple wrapper around a reference to an iavl.ImmutableTree
// that implements the Tree interface. It should only be used for querying
// and iteration, specifically at previous heights.
extension ImmutableTree: Tree {}


extension MutableTree: MTree {
    
    public func deleteVersion(version: Int64) throws {
        // TODO: this will delete all versions above a certain version
        // TODO: check if it is sensical to delete only a version and not later versions
        // TODO: there might be some sense in doing this when it comes to pruning
        try self.deleteAll(from: version)
    }
    
    public func deleteVersions(versions: [Int64]) throws {
        // TODO: this will delete all versions above a certain version
        // TODO: check if it is sensical to delete only a version and not later versions
        // TODO: there might be some sense in doing this when it comes to pruning
        try self.deleteAll(from: versions.min() ?? 0)
    }
    
    public var hash: Data {
        self.root.hash
    }
    
    public func versionExists(version: Int64) -> Bool {
        self.versions.contains(version)
    }
    
    public func getVersioned(key: Data, version: Int64) throws -> (index: Int64, value: Data?) {
        try self.get(key: key, at: version)
    }
    
    public func getImmutable(version: Int64) throws -> ImmutableTree {
        guard let root = try? self.root(at: version) else {
            throw IAVLErrors.generic(identifier: "getImmutable(version: \(version))", reason: "no ImmutableTree with this version")
        }
        return root
    }
    
    public func get(key: Data) -> (index: Int64, value: Data?) {
        self.get(key: key)
    }
    

    
//    func set(key: Data, value: Data) -> Bool {
//        fatalError("cannot call 'Set' on an immutable IAVL tree")
//    }
//
//    func remove(key: Data) -> (Data, Bool) {
//        fatalError("cannot call 'Remove' on an immutable IAVL tree")
//    }
//
//    func saveVersion() throws -> (Data, Int64) {
//        fatalError("cannot call 'SaveVersion' on an immutable IAVL tree")
//    }
//
//    func deleteVersion(version: Int64) throws {
//        fatalError("cannot call 'DeleteVersion' on an immutable IAVL tree")
//    }
//
//    func deleteVersions(versions: [Int64]) throws {
//        fatalError("cannot call 'DeleteVersions' on an immutable IAVL tree")
//    }
//
//    func versionExists(version: Int64) -> Bool {
//        self.version == version
//    }
//
//    func getVersioned(key: Data, version: Int64) -> (index: Int64, value: Data?) {
//        guard self.version == version else {
//            return (-1, nil)
//        }
//
//        // TODO: Implement
//        fatalError()
////        return get(key: key)
//    }
//
//
//    func getImmutable(version: Int64) throws -> ImmutableTree {
//        guard self.version == version else {
//            throw Cosmos.Error.generic(reason: "version mismatch on immutable IAVL tree; got: \(version), expected: \(self.version)")
//        }
//
//        return self
//    }
}
