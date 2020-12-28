import Foundation

extension Data {
    public var string: String {
        String(data: self, encoding: .utf8)!
    }

    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        public static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    public func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef"
        let utf16Digits = Array(hexDigits.utf16)
        var chars: [unichar] = []
        
        chars.reserveCapacity(2 * count)
        
        for byte in self {
            chars.append(utf16Digits[Int(byte / 16)])
            chars.append(utf16Digits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    
    public init?(hexEncoded hexString: String) {
            // Convert 0 ... 9, a ... f, A ...F to their decimal value,
            // return nil for all other input characters
            func decodeNibble(_ u: UInt16) -> UInt8? {
                switch(u) {
                case 0x30 ... 0x39:
                    return UInt8(u - 0x30)
                case 0x41 ... 0x46:
                    return UInt8(u - 0x41 + 10)
                case 0x61 ... 0x66:
                    return UInt8(u - 0x61 + 10)
                default:
                    return nil
                }
            }
            
            let utf16 = hexString.utf16
            var bytes:[UInt8] = []
            
            var i = utf16.startIndex
            
            while i != utf16.endIndex {
                guard let hi = decodeNibble(utf16[i]),
                    let loIndex = utf16.index(i, offsetBy: 1, limitedBy: utf16.endIndex),
                    let lo = decodeNibble(utf16[loIndex])
                    else {
                        return nil
                }
                let value = hi << 4 + lo
                bytes.append(value)
                i = utf16.index(i, offsetBy: 2, limitedBy: utf16.endIndex) ?? utf16.endIndex
            }
        
            self.init(bytes)
        }
}
