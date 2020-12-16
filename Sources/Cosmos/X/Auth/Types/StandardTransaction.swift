import Foundation
import Tendermint

// StdTx is a standard way to wrap a Msg with Fee and Signatures.
// NOTE: the first signature is the fee payer (Signatures must not be nil).
struct StandardTransaction: Transaction {
    static let maxGasWanted = UInt64((1 << 63) - 1)

    let messages: [Message]
    let fee: StandardFee
    let signatures: [StandardSignature]
    let memo: String

    // TODO: Find a way to implement Codable for protocols, maybe make StandardTransaction generic?
    init(from decoder: Decoder) throws {
        fatalError()
    }
    
    func encode(to encoder: Encoder) throws {
        fatalError()
    }

    // ValidateBasic does a simple and lightweight validation check that doesn't
    // require access to any other information.
    func validateBasic() throws {
        let standardSignatures = signatures

        if fee.gas > Self.maxGasWanted {
            throw Cosmos.Error.invalidRequest(reason: "invalid gas supplied; \(fee.gas) > \(Self.maxGasWanted)")
        }
        
        if standardSignatures.isEmpty {
            throw Cosmos.Error.noSignatures
        }
        
        if standardSignatures.count != signers.count {
            throw Cosmos.Error.unauthorized(reason: "wrong number of signers; expected \(signers.count), got \(standardSignatures.count)")
        }
    }
    
    // GetSigners returns the addresses that must sign the transaction.
    // Addresses are returned in a deterministic order.
    // They are accumulated from the GetSigners method for each Msg
    // in the order they appear in tx.GetMsgs().
    // Duplicate addresses will be omitted.
    var signers: [AccountAddress] {
        var seen: [String: Bool] = [:]
        var signers: [AccountAddress] = []
       
        for message in messages {
            for address in message.getSigners() {
                if seen[address.string()] == false {
                    signers.append(address)
                    seen[address.string()] = true
                }
            }
        }
       
        return signers
    }
}

//__________________________________________________________

// StdFee includes the amount of coins paid in fees and the maximum
// gas to be used by the transaction. The ratio yields an effective "gasprice",
// which must be above some miminum to be accepted into the mempool.
struct StandardFee: Codable {
    let amount: Coins
    let gas: UInt64
}

// StdSignature represents a sig
struct StandardSignature: Codable {
    // TODO: Find a way to implement Codable for protocols, maybe make StandardSignature generic?
//    let publicKey: PublicKey?
    let signature: Data
}


extension Auth {
    // DefaultTxDecoder logic for standard transaction decoding
    public static func defaultTransactionDecoder(codec: Codec) -> TransactionDecoder {
        return { transactionData in
            if transactionData.isEmpty {
                throw Cosmos.Error.transactionDecode(reason: "transaction data is empty")
            }

            // StdTx.Msg is an interface. The concrete types
            // are registered by MakeTxCodec
            do {
                let transaction: StandardTransaction = try codec.unmarshalBinaryLengthPrefixed(data: transactionData)
                return transaction
            } catch {
                throw Cosmos.Error.transactionDecode(reason: "\(error)")
            }
        }
    }
}
