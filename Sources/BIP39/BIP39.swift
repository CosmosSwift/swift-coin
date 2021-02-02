import Foundation
import Crypto
import CryptoSwift
//import CommonCrypto
import BigInt

public enum BIP39 {
    static let last11BitsMask = 2047
    static let rightShift11BitsDivider = 2048

    // NewEntropy will create random entropy bytes
    // so long as the requested size bitSize is an appropriate size.
    public static func makeEntropy(bitSize: Int) throws -> Data {
        try validateEntropy(bitSize: bitSize)
        return Data((0 ..< bitSize / 8).map({ _ in UInt8.random(in: UInt8.min ... UInt8.max) }))
    }
    
    // NewMnemonic will return a string consisting of the mnemonic words for
    // the given entropy.
    // If the provide entropy is invalid, an error will be returned.
    public static func makeMnemonic(entropy: Data) throws -> String {
        // Compute some lengths for convenience
        let entropyBitLength = entropy.count * 8
        let checksumBitLength = entropyBitLength / 32
        let sentenceLength = (entropyBitLength + checksumBitLength) / 11

        try validateEntropy(bitSize: entropyBitLength)

        // Add checksum to entropy
        let entropy = addChecksum(data: entropy)

        // Break entropy up into sentenceLength chunks of 11 bits
        // For each word AND mask the rightmost 11 bits and find the word at that index
        // Then bitshift entropy 11 bits right and repeat
        // Add to the last empty slot so we can work with LSBs instead of MSB

        // Entropy as an int so we can bitmask without worrying about bytes slices
        var entropyInt = Int(bigEndian: entropy)

        // Slice to hold words in
        var words: [Substring] = Array(repeating: "", count: sentenceLength)

        // Throw away big int for AND masking
        var word = 0

        for i in (0 ..< sentenceLength).reversed() {
            // Get 11 right most bits and bitshift 11 to the right for next time
            word = entropyInt & last11BitsMask
            entropyInt = entropyInt / rightShift11BitsDivider

            // Get the bytes representing the 11 bits as a 2 byte slice
//            let wordData = pad(data: Data(bigEndian: word), length: 2)

            // Convert bytes to an index and add that word to the list
            words[i] = wordList[word] // Int(UInt16(bigEndian: wordData))]
        }

        return words.joined(separator: " ")
    }

    // MnemonicToByteArray takes a mnemonic string and turns it into a byte array
    // suitable for creating another mnemonic.
    // An error is returned if the mnemonic is invalid.
    static func data(from mnemonic: String) throws -> Data {
        guard isValid(mnemonic: mnemonic) else {
            struct InvalidMnemonicError: Error, CustomStringConvertible {
               let description: String
            }
            
            throw InvalidMnemonicError(description: "Invalid mnemonic")
        }
        
        let mnemonics = mnemonic.split(separator: " ")

        let bitSize = mnemonics.count * 11
        try validateEntropy(withChecksumBitSize: bitSize)
        let checksumSize = bitSize % 32

        var b = 0
        var modulo = 2048
        
        for mnemonic in mnemonics {
            guard let index = reverseWordMap[mnemonic] else {
                struct WordNotFound: Error, CustomStringConvertible {
                    let description: String
                }
               
                throw WordNotFound(description: "Word `\(mnemonic)` not found in reverse map")
            }
            
            b *= modulo
            b += index
        }
        
        let hex = Data(bigEndian: b.bigEndian)
        
        let checksumModulo = (pow(2, checksumSize) as NSDecimalNumber).intValue
        let (entropy, _) = b.quotientAndRemainder(dividingBy: checksumModulo)

        let entropyHex = Data(bigEndian: entropy.bigEndian)

        // Add padding (an extra byte is for checksum)
        let byteSize = (bitSize - checksumSize) / 8 + 1
        
        if hex.count != byteSize {
            // TODO: Implement
            fatalError()
//            tmp := make([]byte, byteSize)
//            diff := byteSize - len(hex)
//
//            for i := 0; i < len(hex); i++ {
//                tmp[i+diff] = hex[i]
//            }
//
//            hex = tmp
        }

        // Add padding (no extra byte, entropy itself does not contain checksum)
        let entropyByteSize = (bitSize - checksumSize) / 8
        
        if entropyHex.count != entropyByteSize {
            // TODO: Implement
            fatalError()
//            tmp := make([]byte, entropyByteSize)
//            diff := entropyByteSize - len(entropyHex)
//            for i := 0; i < len(entropyHex); i++ {
//                tmp[i+diff] = entropyHex[i]
//            }
//            entropyHex = tmp
        }

        let validationHex = addChecksum(data: entropyHex)
        
        if validationHex.count != byteSize {
            // TODO: Implement
            fatalError()
//            tmp2 := make([]byte, byteSize)
//            diff2 := byteSize - len(validationHex)
//            for i := 0; i < len(validationHex); i++ {
//                tmp2[i+diff2] = validationHex[i]
//            }
//            validationHex = tmp2
        }

        if hex.count != validationHex.count {
            fatalError("[]byte len mismatch - it shouldn't happen")
        }
        
        for i in validationHex {
            let index = Int(i)
            
            if hex[index] != validationHex[index] {
                // TODO: Implement
                fatalError()
//                return nil, fmt.Errorf("Invalid byte at position %v", i)
            }
        }
        
        return hex
    }

    // NewSeedWithErrorChecking creates a hashed seed output given the mnemonic string and a password.
    // An error is returned if the mnemonic is not convertible to a byte array.
    public static func makeSeed(mnemonic: String, password: String) throws -> Data {
        _ = try data(from: mnemonic)
        return seed(mnemonic: mnemonic, password: password)
    }
    
    // NewSeed creates a hashed seed output given a provided string and password.
    // No checking is performed to validate that the string provided is a valid mnemonic.
    static func seed(mnemonic: String, password: String) -> Data {
        
        let p: Array<UInt8> = Array(mnemonic.utf8)
        let s: Array<UInt8> = Array(("mnemonic" + password).utf8)

        // TODO: handle the ! properly
        let key = try! PKCS5.PBKDF2(password: p, salt: s, iterations: 2048, keyLength: 64, variant: .sha512).calculate()
        return Data(key)
    }
    
    // Appends to data the first (len(data) / 32)bits of the result of sha256(data)
    // Currently only supports data up to 32 bytes
    static func addChecksum(data: Data) -> Data {
        // Get first byte of sha256
        var hasher = SHA256()
        hasher.update(data: data)
        let hash = hasher.finalize()
        let firstChecksumByte = [UInt8](hash)[0]

        // len() is in bytes so we divide by 4
        let checksumBitLength = UInt(data.count / 4)

        // For each bit of check sum we want we shift the data one the left
        // and then set the (new) right most bit equal to checksum bit at that index
        // staring from the left
        var dataBigInt = UInt32(bigEndian: data)
        
        for i in 0 ..< checksumBitLength {
            // Bitshift 1 left
            dataBigInt <<= 1

            // Set rightmost bit if leftmost checksum bit is set
            if firstChecksumByte & (1 << (7 - UInt8(i))) > 0 {
                dataBigInt |= 1
            }
        }

        return Data(bigEndian: dataBigInt)
    }
    
    static func pad(data: Data, length: Int) -> Data {
        [UInt8](repeating: 0, count: length - data.count) + data
    }

    static func validateEntropy(bitSize: Int) throws {
        guard
            (bitSize % 32) == 0 &&
            bitSize >= 128 &&
            bitSize <= 256
        else {
            struct InvalidEntropyBitSizeError: Error, CustomStringConvertible {
                var description: String
            }
            
            throw InvalidEntropyBitSizeError(description: "Entropy length must be [128, 256] and a multiple of 32")
        }
    }

    static func validateEntropy(withChecksumBitSize bitSize: Int) throws {
        if
            (bitSize != 128 + 4) &&
            (bitSize != 160 + 5) &&
            (bitSize != 192 + 6) &&
            (bitSize != 224 + 7) &&
            (bitSize != 256 + 8)
        {
            struct WrongEntropy: Error, CustomStringConvertible {
                var description: String
            }
            
            throw WrongEntropy(
                description: "Wrong entropy + checksum size - expected \((bitSize-bitSize%32)+(bitSize-bitSize%32)/32)), got \(bitSize)"
            )
        }
    }

    // IsMnemonicValid attempts to verify that the provided mnemonic is valid.
    // Validity is determined by both the number of words being appropriate,
    // and that all the words in the mnemonic are present in the word list.
    static func isValid(mnemonic: String) -> Bool {
        // Create a list of all the words in the mnemonic sentence
        let words = mnemonic.split(whereSeparator: \.isWhitespace)

        //Get num of words
        let wordCount = words.count

        // The number of words should be 12, 15, 18, 21 or 24
        guard wordCount % 3 == 0 && wordCount >= 12 && wordCount <= 24 else {
            return false
        }

        // Check if all words belong in the wordlist
        for word in words {
            guard wordList.contains(word) else {
                return false
            }
        }

        return true
    }

}

extension Data {
    init(bigEndian: Int) {
        self.init(bigEndian.words.map(UInt8.init))
    }
    
    init(bigEndian: UInt32) {
        var bigEndian = bigEndian
        self.init(Swift.withUnsafeBytes(of: &bigEndian, Array.init))
    }
}

extension Int {
    init(bigEndian: Data) {
        var value: Int = 0
        
        _ = Swift.withUnsafeMutableBytes(of: &value) {
            bigEndian.copyBytes(to: $0, count: 4)
        }
        
        self.init(bigEndian: value)
    }
}

extension UInt32 {
    init(bigEndian data: Data) {
        var bigEndian: UInt32 = 0
        
        _ = Swift.withUnsafeMutableBytes(of: &bigEndian) {
            data.copyBytes(to: $0, count: 4)
        }
        
        self.init(bigEndian: bigEndian)
    }
}

extension UInt16 {
    init(bigEndian data: Data) {
        self = UInt16(data[1]) | UInt16(data[0]) << 8
    }
}
