import Foundation

public protocol Writer {
    func write(data: Data) throws
}

public class FileWriter: Writer {
    private let fileHandle: FileHandle

    public init(path: String) throws {
        let url = URL(fileURLWithPath: path)
        let fileHandle = try FileHandle(forWritingTo: url)
        self.fileHandle = fileHandle
    }

    public func write(data: Data) throws {
        fileHandle.write(data)
    }
}
