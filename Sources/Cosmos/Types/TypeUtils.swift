import Foundation

// SortedJSON takes any JSON and returns it sorted by keys. Also, all white-spaces
// are removed.
// This method can be used to canonicalize JSON to be returned by GetSignBytes,
// e.g. for the ledger integration.
// If the passed JSON isn't valid it will return an error.
public func sortJSON(data: Data) throws -> Data {
    let value = try JSONSerialization.jsonObject(with: data)
    return try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys])
}

// MustSortJSON is like SortJSON but panic if an error occurs, e.g., if
// the passed JSON isn't valid.
public func mustSortJSON(data: Data) -> Data {
    do {
        return try sortJSON(data: data)
    } catch {
       fatalError("\(error)")
    }
}
