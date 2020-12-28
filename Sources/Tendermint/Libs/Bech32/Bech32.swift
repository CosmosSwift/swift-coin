import Foundation
import Bech32

extension Bech32 {
    //ConvertAndEncode converts from a base64 encoded byte string to base32 encoded byte string and then to bech32
    public static func convertAndEncode(humanReadablePart: String, data: Data) throws -> String {
        let converted = try Bech32.convertBits(data, from: 8, to: 5, pad: true)
        return Bech32.encode(humanReadablePart: humanReadablePart, data: converted)
    }

    //DecodeAndConvert decodes a bech32 encoded string and converts to base64 encoded bytes
    public static func decodeAndConvert(_ string: String) throws -> (String, Data) {
        let (hrp, data) = try Bech32.decode(string)
        let converted = try Bech32.convertBits(data, from: 5, to: 8, pad: false)
        return (hrp, converted)
    }
}
