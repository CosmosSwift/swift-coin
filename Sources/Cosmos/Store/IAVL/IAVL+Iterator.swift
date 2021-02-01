//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 01/02/2021.
//

import Foundation
import Database
import iAVLPlusCore


public struct IAVLIteratorError: Swift.Error, CustomStringConvertible {
    public var description: String
}



extension NodeProtocol {
    func previous(key: Key) -> Key? {
        var previous: Key?
        iterate ({ (k, _) -> Bool in
            if k < key {
                previous = key
                return true
            } else {
                return false
            }
        }, false)
        return previous
    }
}

extension NodeStorageProtocol {
    func previous(key: Key) throws -> Key? {
        if let root = try self.root(at: version) {
            return root.previous(key: key)
        }
        throw IAVLErrors.generic(identifier: "NodeStorageProtocol().previous()", reason: "no root for version \(version)")
    }
}

public struct IAVLIterator<Storage: NodeStorageProtocol>: Iterator where Storage.Key == Data, Storage.Value == Data {
    
    typealias Key = Storage.Key
    typealias Value = Storage.Value
    typealias Hasher = Storage.Hasher
    
    public var error: Swift.Error? {
        guard isValid else {
            
        return IAVLIteratorError(description: "Invalid iavl+ iterator.")
    }

    return nil}
    
    public var domain: (start: Data, end: Data)
    
    public var isValid: Bool =  false
    
    public var key: Data
    
    public var value: Data

    private var tree: Storage

    public init(_ tree: Storage, _ start: Data, _ end: Data, _ ascending: Bool) {
        // TODO: very inefficient - we should also move to a proper IteratorProtocol compliance
        self.tree = tree
        self.domain = (start, end)
        self.key = start
        guard let (_, v) = try? tree.get(key: start) else {
            self.isValid = false
            self.value = Data()
            return
        }

        if let value = v {
            self.isValid = true
            self.value = value
        } else {
            self.isValid = false
            self.value = Data()
        }
    }
    
    
    public mutating func next() {
        guard let key = try? self.tree.next(key: key) else {
            self.isValid = false
            return
        }
        self.key = key
        guard let (_, v) = try? tree.get(key: key) else {
            self.isValid = false
            self.value = Data()
            return
        }
        if let value = v {
            self.isValid = true
            self.value = value
        } else {
            self.isValid = false
            self.value = Data()
        }
        
        return
    }
    

    public mutating func close() {
        self.isValid = false
    }
    
}
