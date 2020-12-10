import SwiftUI

public struct Router<Destination> {
    private let destination: Destination?
    private let buildChildren: () -> [Route<Destination>]
    
    public init(
        root destination: Destination? = nil,
        @RouteBuilder buildChildren: @escaping () -> [Route<Destination>]
    ) {
        self.destination = destination
        self.buildChildren = buildChildren
    }
}

extension Router {
    public func destination(for url: URL) -> Destination? {
        let pathComponents = PathComponents(url.path)
        var parentPathComponent: String? = nil
        var route = AnyRoutable(self)

        for pathComponent in pathComponents {
            guard
                let child = route.child(
                    pathComponent: pathComponent,
                    parentPathComponent: parentPathComponent
                )
            else {
                return nil
            }

            parentPathComponent = pathComponent
            route = AnyRoutable(child)
        }

        return route.destination(
            parentPathComponent: parentPathComponent,
            queryItems: URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        )
    }
}

extension Router : Routable {
    func child(pathComponent: String, parentPathComponent: String?) -> Route<Destination>? {
        let children = buildChildren()
        return children.child(for: pathComponent)
    }

    func destination(parentPathComponent: String?, queryItems: [URLQueryItem]) -> Destination? {
        destination
    }
}

fileprivate struct PathComponents : Sequence {
    private var path: String

    fileprivate init(_ path: String) {
        self.path = path
    }
    
    func makeIterator() -> PathComponentsIterator {
        PathComponentsIterator(path)
    }
}

fileprivate struct PathComponentsIterator : IteratorProtocol {
    private var path: Substring

    fileprivate init(_ path: String) {
        self.path = path.dropFirst()
    }

    fileprivate mutating func next() -> String? {
        if path.isEmpty {
            return nil
        }

        var pathComponent = ""

        while let character = path.popFirst() {
            guard character != "/" else {
                break
            }

            pathComponent.append(character)
        }

        return String(pathComponent)
    }
}
