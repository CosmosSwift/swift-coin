import Foundation

public enum Armor {
    public static func encodeArmor(
        blockType: String,
        headers: [String: String],
        data: Data
    ) -> String {
        struct EncodedArmor: Codable {
            let blockType: String
            let headers: [String: String]
            let data: Data
        }
        
        let armor = EncodedArmor(
            blockType: blockType,
            headers: headers,
            data: data
        )
        
        return try! JSONEncoder().encode(armor).string
        // TODO: Implement
//        buf := new(bytes.Buffer)
//
//        w, err := armor.Encode(buf, blockType, headers)
//        if err != nil {
//            panic(fmt.Errorf("could not encode ascii armor: %s", err))
//        }
//
//        _, err = w.Write(data)
//
//        if err != nil {
//            panic(fmt.Errorf("could not encode ascii armor: %s", err))
//        }
//
//        err = w.Close()
//
//        if err != nil {
//            panic(fmt.Errorf("could not encode ascii armor: %s", err))
//        }
//
//        return buf.String()
    }
}
