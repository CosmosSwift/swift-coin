import Foundation

public protocol Iterator {
    // The start & end (exclusive) limits to iterate over.
    // If end < start, then the Iterator goes in reverse order.
    //
    // A domain of ([]byte{12, 13}, []byte{12, 14}) will iterate
    // over anything with the prefix []byte{12, 13}.
    //
    // The smallest key is the empty byte array []byte{} - see BeginningKey().
    // The largest key is the nil byte array []byte(nil) - see EndingKey().
    // CONTRACT: start, end readonly []byte
    var domain: (start: Data, end: Data) { get }

    // isValid returns whether the current position is valid.
    // Once invalid, an Iterator is forever invalid.
    var isValid: Bool { get }

    // Next moves the iterator to the next sequential key in the database, as
    // defined by order of iteration.
    // If Valid returns false, this method will panic.
    func next()

    // Key returns the key of the cursor.
    // If Valid returns false, this method will panic.
    // CONTRACT: key readonly []byte
    var key: Data { get }

    // Value returns the value of the cursor.
    // If Valid returns false, this method will panic.
    // CONTRACT: value readonly []byte
    var value: Data { get }

    var error: Error { get }

    // Close releases the Iterator.
    func close()
}
