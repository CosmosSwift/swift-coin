import Foundation

public enum Random {
    // 62 characters
    private static let stringCharacters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    public static func string(count: Int) -> String {
        var characters: [Character] = []
        
        main_loop: while true {
            var randomValue = Int64.random(in: .min ... .max)
            
            for _ in 0 ..< 10 {
                let value = Int(randomValue & 0x3f) // rightmost 6 bits
                
                if value >= 62 {         // only 62 characters in strChars
                    randomValue >>= 6
                    continue
                } else {
                    characters.append(stringCharacters[stringCharacters.index(stringCharacters.startIndex, offsetBy: value)])
                    
                    if characters.count == count {
                        break main_loop
                    }
                    
                    randomValue >>= 6
                }
            }
        }

        return String(characters)
    }
}
