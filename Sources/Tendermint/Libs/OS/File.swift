import Foundation

extension FileManager {
    public func ensureDirectoryExists(atPath path: String, mode: Int16) throws {
        do {
            try createDirectory(
                atPath: path,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: NSNumber(value: mode)]
            )
        } catch {
            struct Error: Swift.Error, CustomStringConvertible {
                var description: String
            }

            throw Error(description: "could not create directory \(path): \(error)")
        }
    }
}
