// Inspired by https://stackoverflow.com/a/44473156

import Foundation

public protocol Meta: Codable {
    associatedtype Element
    static func metatype(for element: Element) -> String
}

public struct MetaSet<M: Meta>: Codable, ExpressibleByArrayLiteral {
    // TODO: this should implement all the normal Set stuff
    public var set: [M.Element]

    public init(array: [M.Element]) {
        self.set = array
    }

    public init(arrayLiteral elements: M.Element...) {
        self.set = elements
    }

    struct ElementKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ElementKey.self)

        var elements: [M.Element] = []
        
        for key in container.allKeys {
            //let nested = try container.nestedContainer(keyedBy: ElementKey.self)
            //guard let key = nested.allKeys.first else { continue }
            
            //let metatype = M(rawValue: key.stringValue)
            
            let superDecoder = try container.superDecoder(forKey: key)
            let object = try AppStateMetatype.typeMap[key.stringValue]?.init(from: superDecoder)
            
            if let element = object as? M.Element {
                elements.append(element)
            }
        }
        set = elements
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ElementKey.self)
        try set.forEach { object in
            let metatype = M.metatype(for: object)
            if let key = ElementKey(stringValue: metatype) {
                let superEncoder = container.superEncoder(forKey: key)
                let encodable = object as? Encodable
                try encodable?.encode(to: superEncoder)
            }
        }
    }
}

public protocol AppState: Codable {
    static var metatype: String { get }
    
    //static var `default`: Self { get }
    init(default: Void)
}

public struct AppStateMetatype: Meta, Hashable {
    public typealias Element = AppState

    public static var typeMap: [String: Element.Type] = [:]

    public static func metatype(for element: AppState) -> String {
        return type(of:element).metatype
    }
    
    public static func register(_ type: AppState.Type) {
        typeMap[type.metatype] = type
    }
}


