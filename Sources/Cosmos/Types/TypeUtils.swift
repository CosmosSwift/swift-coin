import Foundation
import Database

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
    try! sortJSON(data: data)
}

let formatter: DateFormatter = {
    let formatter = DateFormatter()
    // Slight modification of the RFC3339Nano but it right pads all zeros and drops the time zone info
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000000000"
    return formatter
}()

// Formats a time.Time into a []byte that can be sorted
public func formatDateData(date: Date) -> Data {
    // TODO: This code used to do some more stuff, UTC and Round.
    // return []byte(t.UTC().Round(0).Format(SortableTimeFormat))
    formatter.string(from: date).data
}
