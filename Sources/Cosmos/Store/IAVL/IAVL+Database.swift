import Foundation
import iAVLPlusCore
import Database


public struct NodeStorageDBWrapper<Storage: NodeStorageProtocol>: Database where Storage.Node.Key == Data, Storage.Node.Value == Data {
    public func has(key: Data) throws -> Bool {
        try storage.has(key: key)
    }
    
    public var storage: Storage
    
    public init(_ storage: Storage) {
        self.storage = storage
    }

    public func get(key: Data) throws -> Data? {
        (try storage.get(key: key)).1
    }
    
    public func set(key: Data, value: Data) throws {
        _ = try storage.set(key: key, value: value)
    }
    
    public func setSync(key: Data, value: Data) throws {
        _ = try storage.set(key: key, value: value)
        try storage.commit()
    }
    
    public func delete(key: Data) throws {
        _ = storage.remove(key: key)
    }
    
    public func deleteSync(key: Data) throws {
        _ = storage.remove(key: key)
        try storage.commit()
    }
    
    public func iterator(start: Data, end: Data) throws -> Iterator {
        return IAVLIterator(storage, start, end, true)
    }
    
    public func reverseIterator(start: Data, end: Data) throws -> Iterator {
        return IAVLIterator(storage, start, end, false)
    }
    
    public func close() throws {
        // TODO: Implement
        fatalError()
    }
    
    public func makeBatch() -> Batch {
        // TODO: Implement
//        return newMemDBBatch(db)
        fatalError()
    }
    
    public func print() throws {
        storage.root.iterate { (key, value) -> Bool in
            Swift.print("[\(key)]:\t[\(value)]\n")
            return true
        }
    }
    
    public func stats() -> [String : String] {
        [
            "database.type": "iavl-database",
            // TODO: handle when multiple versions?
            "database.size": "\(storage.root.size)",
        ]
    }
    
    
}
