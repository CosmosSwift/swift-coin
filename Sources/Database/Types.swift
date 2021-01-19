import Foundation

// Databases are goroutine safe.
public protocol Database {
    // Get returns nil if key doesn't exist.
    // A nil key is interpreted as an empty byteslice.
    // CONTRACT: key, value readonly []byte
    func get(key: Data) throws -> Data?

    // Has checks if a key exists.
    // A nil key is interpreted as an empty byteslice.
    // CONTRACT: key, value readonly []byte
    func has(key: Data) throws -> Bool

    // Set sets the key.
    // A nil key is interpreted as an empty byteslice.
    // CONTRACT: key, value readonly []byte
    func set(key: Data, value: Data) throws
    func setSync(key: Data, value: Data) throws

    // Delete deletes the key.
    // A nil key is interpreted as an empty byteslice.
    // CONTRACT: key readonly []byte
    func delete(key: Data) throws
    func deleteSync(key: Data) throws

    // TODO: We could use empty Data to signal nil in the iterators.
    // Think about it.
    
    // Iterate over a domain of keys in ascending order. End is exclusive.
    // Start must be less than end, or the Iterator is invalid.
    // A nil start is interpreted as an empty byteslice.
    // If end is nil, iterates up to the last item (inclusive).
    // CONTRACT: No writes may happen within a domain while an iterator exists over it.
    // CONTRACT: start, end readonly []byte
    func iterator(start: Data, end: Data) throws -> Iterator

    // Iterate over a domain of keys in descending order. End is exclusive.
    // Start must be less than end, or the Iterator is invalid.
    // If start is nil, iterates up to the first/least item (inclusive).
    // If end is nil, iterates from the last/greatest item (inclusive).
    // CONTRACT: No writes may happen within a domain while an iterator exists over it.
    // CONTRACT: start, end readonly []byte
    func reverseIterator(start: Data, end: Data) throws -> Iterator

    // Closes the connection.
    func close() throws

    // Creates a batch for atomic updates. The caller must call Batch.Close.
    func makeBatch() -> Batch

    // For debugging
    func print() throws

    // Stats returns a map of property values for all keys and the size of the cache.
    func stats() -> [String: String]
}

// Batch Close must be called when the program no longer needs the object.
public protocol Batch: SetDeleter {
    // Write writes the batch, possibly without flushing to disk. Only Close() can be called after,
    // other methods will panic.
    func write() throws

    // WriteSync writes the batch and flushes it to disk. Only Close() can be called after, other
    // methods will panic.
    func writeSync() throws

    // Close closes the batch. It is idempotent, but any other calls afterwards will panic.
    func close()
}

public protocol SetDeleter {
    // Set sets a key/value pair.
    // CONTRACT: key, value readonly []byte
    func set(key: Data, value: Data)

    // Delete deletes a key/value pair.
    // CONTRACT: key readonly []byte
    func delete(key: Data)
}


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
    mutating func next()

    // Key returns the key of the cursor.
    // If Valid returns false, this method will panic.
    // CONTRACT: key readonly []byte
    var key: Data { get }

    // Value returns the value of the cursor.
    // If Valid returns false, this method will panic.
    // CONTRACT: value readonly []byte
    var value: Data { get }

    var error: Error? { get }

    // Close releases the Iterator.
    mutating func close()
}
