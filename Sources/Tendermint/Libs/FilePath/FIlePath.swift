import Foundation

public enum FilePath {
    public static func directoryPath(for path: String) -> String {
        (path as NSString).deletingLastPathComponent
    }
}
