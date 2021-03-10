import Foundation
import Crypto
import DataConvertible

// BIP44Params wraps BIP 44 params (5 level BIP 32 path).
// To receive a canonical string representation ala
// m / purpose' / coinType' / account' / change / addressIndex
// call String() on a BIP44Params instance.
public struct BIP44Params: Codable, CustomStringConvertible {
    let purpose: UInt32
    let coinType: UInt32
    let account: UInt32
    let change: Bool
    let addressIndex: UInt32
}

extension BIP44Params {
    public var description: String {
        // m / Purpose' / coin_type' / Account' / Change / address_index
        "\(purpose)'/\(coinType)'/\(account)'/\(change ? "1" : "0")/\(addressIndex)"
    }
}
    
enum HD {
    // ComputeMastersFromSeed returns the master public key, master secret, and chain code in hex.
    static func computeMasters(fromSeed seed: Data) -> (secret: Data, chainCode: Data) {
        let masterSecret = "Bitcoin seed".data
        let (secret, chainCode) = i64(key: masterSecret, data: seed)
        return (secret, chainCode)
    }

    // DerivePrivateKeyForPath derives the private key by following the BIP 32/44 path from privKeyBytes,
    // using the given chainCode.
    static func derivePrivateKey(forPath path: String, privateKey: Data, chainCode: Data) throws -> Data {
        var privateKey = privateKey
        var chainCode = chainCode
        let parts = path.split(separator: "/")
        
        for var part in parts {
            // do we have an apostrophe?
            let harden = part.last == "'"
            
            // harden == private derivation, else public derivation:
            if harden {
                part.removeLast()
            }
            
            guard let index = UInt32(part) else {
                struct InvalidBIPPathError: Swift.Error, CustomStringConvertible {
                    var description: String
                }
                
                throw InvalidBIPPathError(description: "invalid BIP 32 path")
            }

            (privateKey, chainCode) = derivePrivateKey(
                privateKey: privateKey,
                chainCode: chainCode,
                index: index,
                harden: harden
            )
        }
        
        if privateKey.count != 32 {
            struct InvalidLengthError: Swift.Error, CustomStringConvertible {
                var description: String
            }
            
            throw InvalidLengthError(
                description: "expected a (secp256k1) key of length 32, got length: \(privateKey.count)"
            )
        }

        return privateKey
    }
    
    // derivePrivateKey derives the private key with index and chainCode.
    // If harden is true, the derivation is 'hardened'.
    // It returns the new private key and new chain code.
    // For more information on hardened keys see:
    //  - https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
    static func derivePrivateKey(
        privateKey: Data,
        chainCode: Data,
        index: UInt32,
        harden: Bool
    ) -> (privateKey: Data, chainCode: Data) {
        // TODO: Implement
        fatalError()
//        var data []byte
//
//        if harden {
//            index |= 0x80000000
//            data = append([]byte{byte(0)}, privKeyBytes[:]...)
//        } else {
//            // this can't return an error:
//            _, ecPub := btcec.PrivKeyFromBytes(btcec.S256(), privKeyBytes[:])
//            pubkeyBytes := ecPub.SerializeCompressed()
//            data = pubkeyBytes
//
//            /* By using btcec, we can remove the dependency on tendermint/crypto/secp256k1
//            pubkey := secp256k1.PrivKeySecp256k1(privKeyBytes).PubKey()
//            public := pubkey.(secp256k1.PubKeySecp256k1)
//            data = public[:]
//            */
//        }
//
//        data = append(data, uint32ToBytes(index)...)
//        data2, chainCode2 := i64(chainCode[:], data)
//        x := addScalars(privKeyBytes[:], data2[:])
//        return (x, chainCode2)
    }

}

extension BIP44Params {
    // NewFundraiserParams creates a BIP 44 parameter object from the params:
    // m / 44' / coinType' / account' / 0 / address_index
    // The fixed parameters (purpose', coin_type', and change) are determined by what was used in the fundraiser.
    static func fundraiser(
        account: UInt32,
        coinType: UInt32,
        addressIndex: UInt32
    ) -> BIP44Params {
        BIP44Params(
            purpose: 44,
            coinType: coinType,
            account: account,
            change: false,
            addressIndex: addressIndex
        )
    }
}

extension HD {
    // i64 returns the two halfs of the SHA512 HMAC of key and data.
    static func i64(key: Data, data: Data) -> (il: Data, ir: Data) {
        var sha512 = SHA512()
        sha512.update(data: key)
        sha512.update(data: data)
        let data = sha512.finalize()
        let il = data.prefix(32)
        let ir = data.suffix(32)
        return (Data(il), Data(ir))
    }
}
