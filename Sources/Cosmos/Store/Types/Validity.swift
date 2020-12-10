import Foundation

// Check if the key is valid(key is not nil)
func assertValid(key: Data?) {
    if key == nil {
        fatalError("key is nil")
    }
}

// Check if the value is valid(value is not nil)
func assertValid(value: Data?) {
    if value == nil {
        fatalError("value is nil")
    }
}
