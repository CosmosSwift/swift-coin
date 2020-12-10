import Foundation
import SwiftUI

enum PathComponentType {
    case pathComponent(String)
    case parameter
}

public struct Route<Destination> : PathComponentMatchable {
    let pathComponent: PathComponentType
    let buildDestination: (String, [URLQueryItem]) -> Destination?
    let buildChildren: (String) -> [Route]
    
    public init(
        _ pathComponent: String,
        destination: Destination? = nil,
        @RouteBuilder buildChildren: @escaping () -> [Route]
    ) {
        self.pathComponent = .pathComponent(pathComponent)
        self.buildDestination = { _, _ in destination }
        self.buildChildren = { _ in buildChildren() }
    }

    public init<T : LosslessStringConvertible>(
        _ parameter: T.Type,
        destination: @escaping (T) -> Destination? = { _ in nil },
        @RouteBuilder buildChildren: @escaping (T) -> [Route]
    ) {
        self.pathComponent = .parameter
        self.buildDestination = { p, _ in T(p).flatMap(destination) }
        self.buildChildren = { T($0).map(buildChildren) ?? [] }
    }
}

extension Route {
    public init(
        _ pathComponent: String,
        destination: Destination
    ) {
        self.pathComponent = .pathComponent(pathComponent)
        self.buildDestination = { _, _ in destination }
        self.buildChildren = { _ in [] }
    }

    public init<T : LosslessStringConvertible>(
        _ parameter: T.Type,
        destination: @escaping (T) -> Destination
    ) {
        self.pathComponent = .parameter
        self.buildDestination = { p, _ in T(p).map({ destination($0) }) }
        self.buildChildren = { _ in [] }
    }
}

extension Route {
    public init(
        _ pathComponent: String,
        query: String,
        destination: @escaping (String) -> Destination
    ) {
        self.pathComponent = .pathComponent(pathComponent)
        
        self.buildDestination = { _, queryItems in
            queryItems.first(where: { $0.name == query })?.value.map {
                destination($0)
            }
        }
        
        self.buildChildren = { _ in [] }
    }
}

extension Route : Routable {
    func child(pathComponent: String, parentPathComponent: String?) -> Route? {
        let routes = buildChildren(parentPathComponent!)
        return routes.child(for: pathComponent)
    }

    func destination(parentPathComponent: String?, queryItems: [URLQueryItem]) -> Destination? {
        buildDestination(parentPathComponent!, queryItems)
    }
}

protocol PathComponentMatchable {
    var pathComponent: PathComponentType { get }
}

extension Array where Element : PathComponentMatchable {
    func child(for pathComponent: String) -> Element? {
        for route in self {
            guard case let .pathComponent(routePathComponent) = route.pathComponent else {
                continue
            }
            
            guard routePathComponent == pathComponent else {
                continue
            }
            
            return route
        }
        
        for route in self {
            guard case .parameter = route.pathComponent else {
                continue
            }
        
            return route
        }
        
        return nil
    }
}
