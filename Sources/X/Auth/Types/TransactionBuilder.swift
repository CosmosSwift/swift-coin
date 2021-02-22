import Foundation
import Tendermint
import Cosmos

#warning("STUB")
struct Keybase {
    func sign(name: String, passPhrase: String, data: Data) -> StandardSignature {
        fatalError()
    }
}

struct TransactionBuilder {
    var transactionEncoder: TransactionEncoder
    var keybase: Keybase?
    var accountNumber: UInt64
    var sequence: UInt64
    var gas: UInt64
    let gasAdjustment: Double
    let simulateAndExecute: Bool
    var chainID: String
    var memo: String
    var transactionType: TransactionType
    
    enum TransactionType {
        case fees([Coin])
        case gasPrices([DecimalCoin])
    }
    
    init(
        transactionEncoder: @escaping TransactionEncoder,
        accountNumber: UInt64,
        sequence: UInt64,
        gas: UInt64,
        gasAdjustment: Double,
        simulateAndExecute: Bool,
        chainID: String,
        memo: String,
        transactionType: TransactionType
    ) throws {
        if chainID.isEmpty {
            throw TransactionBuilderError.chainIDRequired
        }
        
        self.transactionEncoder = transactionEncoder
        self.keybase = nil
        self.accountNumber = accountNumber
        self.sequence = sequence
        self.gas = gas
        self.gasAdjustment = gasAdjustment
        self.simulateAndExecute = simulateAndExecute
        self.chainID = chainID
        self.memo = memo
        self.transactionType = transactionType
    }
    
    func buildSignMessage(messages: [Message]) throws -> StandardSignedMessage {
        let finalFees: [Coin]
        
        switch transactionType {
        case let .fees(fees):
            finalFees = fees
        case let .gasPrices(gasPrices):
            let gasDecimal = Decimal(gas)
            let coins = gasPrices.map { gasPrice -> Coin in
                let fee = gasPrice.amount * gasDecimal
                let roundedFee = fee.rounded(0, .up)
                // wrap it in an NSDecimalNumber since Decimal can't be cast to uint itself.
                let amount = UInt(NSDecimalNumber(decimal: roundedFee))
                return Coin(denomination: gasPrice.denomination, amount: amount)
            }
            finalFees = coins
        }
        
        let fee = StandardFee(amount: finalFees, gas: gas)
        
        return StandardSignedMessage(
            chainID: chainID,
            accountNumber: accountNumber,
            sequence: sequence,
            fee: fee,
            messages: messages,
            memo: memo
        )
    }
    
    // Sign signs a transaction given a name, passphrase, and a single message to
    // signed. An error is returned if signing fails.
    func sign(name: String, passPhrase: String, message: StandardSignedMessage) throws -> Data {
        let signature = try TransactionBuilder.makeSignature(keybase: keybase, name: name, passPhrase: passPhrase, message: message)
        let transaction = StandardTransaction(messages: message.messages, fee: message.fee, signatures: [signature], memo: message.memo)
        return try transactionEncoder(transaction)
    }
    
    struct KeyringServiceName {
        #warning("STUB")
    }
    static func newKeyring(_ keyringServiceName: KeyringServiceName, keyringBackend: String, homeFlag: String) -> Keybase {
        #warning("STUB")
        fatalError()
    }
    
    // MakeSignature builds a StdSignature given keybase, key name, passphrase, and a StdSignMsg.
    static func makeSignature(keybase: Keybase?, name: String, passPhrase: String, message: StandardSignedMessage) throws -> StandardSignature {
        let keybase = keybase ?? newKeyring(KeyringServiceName(), keyringBackend: "", homeFlag: "")
        return keybase.sign(name: name, passPhrase: passPhrase, data: message.data)
    }
    
    // BuildAndSign builds a single message to be signed, and signs a transaction
    // with the built message given a name, passphrase, and a set of messages.
    func buildAndSign(name: String, passPhrase: String, messages: [Message]) throws -> Data {
        let message = try buildSignMessage(messages: messages)
        return try sign(name: name, passPhrase: passPhrase, message: message)
    }
    
    // BuildTxForSim creates a StdSignMsg and encodes a transaction with the
    // StdSignMsg with a single empty StdSignature for tx simulation.
    func buildTransactionForSimulation(messages: [Message]) throws -> Data {
        let signedMessage = try buildSignMessage(messages: messages)
        
        fatalError("This is not correct yet")
        //let signatures = [StandardSig]
        
        return try transactionEncoder(
            StandardTransaction(
                messages: signedMessage.messages,
                fee: signedMessage.fee,
                signatures: [], // this probably shouldn't be empty
                memo: signedMessage.memo
            )
        )
        
//        func (bldr TxBuilder) BuildTxForSim(msgs []sdk.Msg) ([]byte, error) {
//            signMsg, err := bldr.BuildSignMsg(msgs)
//            if err != nil {
//                return nil, err
//            }
//
//            // the ante handler will populate with a sentinel pubkey
//            sigs := []StdSignature{{}}
//            return bldr.txEncoder(NewStdTx(signMsg.Msgs, signMsg.Fee, sigs, signMsg.Memo))
//        }
    }
    
    // SignStdTx appends a signature to a StdTx and returns a copy of it. If append
    // is false, it replaces the signatures already attached with the new signature.
    func signStandardTransaction(name: String, passPhrase: String, standardTransaction: StandardTransaction, appendSignature: Bool) throws -> StandardTransaction {
        let message = StandardSignedMessage(
            chainID: chainID,
            accountNumber: accountNumber,
            sequence: sequence,
            fee: standardTransaction.fee,
            messages: standardTransaction.messages,
            memo: standardTransaction.memo
        )
        let standardSignature = try TransactionBuilder.makeSignature(keybase: keybase, name: name, passPhrase: passPhrase, message: message)
        let signatures: [StandardSignature]
        if standardTransaction.signatures.count == 0 || !appendSignature {
            signatures = [standardSignature]
        } else {
            signatures = standardTransaction.signatures + [standardSignature]
        }
        return StandardTransaction(
            messages: standardTransaction.messages,
            fee: standardTransaction.fee,
            signatures: signatures,
            memo: standardTransaction.memo
        )
    }
}



/*
 package types

 import (
     "errors"
     "fmt"
     "io"
     "os"
     "strings"

     "github.com/spf13/viper"

     "github.com/cosmos/cosmos-sdk/client/flags"
     "github.com/cosmos/cosmos-sdk/crypto/keys"
     sdk "github.com/cosmos/cosmos-sdk/types"
 )


 // NewTxBuilderFromCLI returns a new initialized TxBuilder with parameters from
 // the command line using Viper.
 func NewTxBuilderFromCLI(input io.Reader) TxBuilder {
     kb, err := keys.NewKeyring(sdk.KeyringServiceName(), viper.GetString(flags.FlagKeyringBackend), viper.GetString(flags.FlagHome), input)
     if err != nil {
         panic(err)
     }
     txbldr := TxBuilder{
         keybase:            kb,
         accountNumber:      uint64(viper.GetInt64(flags.FlagAccountNumber)),
         sequence:           uint64(viper.GetInt64(flags.FlagSequence)),
         gas:                flags.GasFlagVar.Gas,
         gasAdjustment:      viper.GetFloat64(flags.FlagGasAdjustment),
         simulateAndExecute: flags.GasFlagVar.Simulate,
         chainID:            viper.GetString(flags.FlagChainID),
         memo:               viper.GetString(flags.FlagMemo),
     }

     txbldr = txbldr.WithFees(viper.GetString(flags.FlagFees))
     txbldr = txbldr.WithGasPrices(viper.GetString(flags.FlagGasPrices))

     return txbldr
 }
*/

extension TransactionBuilder {
    enum TransactionBuilderError: Swift.Error, CustomStringConvertible, LocalizedError {
        case chainIDRequired
        
        public var errorDescription: String? {
            return self.description
        }
        
        public var description: String {
            return "TransactionBuilder error: \(self.reason)"
        }
        
        var reason: String {
            switch self {
            case .chainIDRequired:
                return "chain ID required but not specified"
            }
        }
    }
}
