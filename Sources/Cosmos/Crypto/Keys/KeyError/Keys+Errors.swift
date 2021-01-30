struct KeyNotFoundError: Swift.Error {
    static let keyNotFoundCode = 1
    
    let code: Int
    let name: String
    
    // NewErrKeyNotFound returns a standardized error reflecting that the specified key doesn't exist
    init(name: String) {
        self.code = Self.keyNotFoundCode
        self.name = name
    }
}
