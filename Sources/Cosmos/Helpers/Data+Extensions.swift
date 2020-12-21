import Foundation

extension Data {
    public var string: String {
        String(data: self, encoding: .utf8)!
    }
}
