protocol Sealable {
    var sealed: Bool { get }
}
    
extension Sealable {
    func assertUnsealed(_ message: String) {
        guard !sealed else {
            fatalError(message)
        }
    }
}
