import SwiftUI

protocol Routable {
    associatedtype Destination
    func child(pathComponent: String, parentPathComponent: String?) -> Route<Destination>?
    func destination(parentPathComponent: String?, queryItems: [URLQueryItem]) -> Destination?
}

final class AnyRoutable<Destination> : Routable {
    let child: (String, String?) -> Route<Destination>?
    let destination: (String?, [URLQueryItem]) -> Destination?
    
    init<R : Routable>(_ routable: R) where R.Destination == Destination {
        self.child = routable.child
        self.destination = routable.destination
    }
    
    func child(pathComponent: String, parentPathComponent: String?) -> Route<Destination>? {
        child(pathComponent, parentPathComponent)
    }
    
    func destination(parentPathComponent: String?, queryItems: [URLQueryItem]) -> Destination? {
        destination(parentPathComponent, queryItems)
    }
}
