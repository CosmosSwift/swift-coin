import Foundation
import Tendermint
import Cosmos

extension BankKeys {
    // RouterKey is they name of the bank module
    static let routerKey = moduleName
}

// MsgSend - high level transaction of the coin module
struct SendMessage: Message {
    static let metaType: MetaType = Self.metaType(
        key: "cosmos-sdk/MsgSend"
    )
    
    let senderAddress: AccountAddress
    let destinationAddress: AccountAddress
    let amount: [Coin]

    // NewMsgSend - construct arbitrary multi-in, multi-out send msg.
    internal init(
        senderAddress: AccountAddress,
        destinationAddress: AccountAddress,
        amount: [Coin]
    ) {
        self.senderAddress = senderAddress
        self.destinationAddress = destinationAddress
        self.amount = amount
    }
}

extension SendMessage {
    // Route Implements Msg.
    var route: String {
        BankKeys.routerKey
    }

    // Type Implements Msg.
    var type: String {
        "send"
    }

    // ValidateBasic Implements Msg.
    func validateBasic() throws {
        guard !senderAddress.isEmpty else {
            throw Cosmos.Error.invalidAddress(address: "missing sender address")
        }
        
        guard !destinationAddress.isEmpty else {
            throw Cosmos.Error.invalidAddress(address: "missing recipient address")
        }
        
        guard amount.isValid else {
            throw Cosmos.Error.invalidCoins(reason: "\(amount)")
        }
        
        guard amount.isAllPositive else {
            throw Cosmos.Error.invalidCoins(reason: "\(amount)")
        }
    }

    // GetSignBytes Implements Msg.
    var signedData: Data {
        mustSortJSON(data: Codec.bankCodec.mustMarshalJSON(value: self))
    }

    // GetSigners Implements Msg.
    var signers: [AccountAddress] {
        [senderAddress]
    }
}

// MsgMultiSend - high level transaction of the coin module
struct MultiSendMessage: Message {
    static let metaType: MetaType = Self.metaType(
        key: "cosmos-sdk/MsgMultiSend"
    )
    
    let inputs:  [Input]
    let outputs: [Output]
    
    // NewMsgMultiSend - construct arbitrary multi-in, multi-out send msg.
    internal init(inputs: [Input], outputs: [Output]) {
        self.inputs = inputs
        self.outputs = outputs
    }
}

extension MultiSendMessage {
    // Route Implements Msg
    var route: String {
        BankKeys.routerKey
    }

    // Type Implements Msg
    var type: String {
        "multisend"
    }

    // ValidateBasic Implements Msg.
    func validateBasic() throws {
        // this just makes sure all the inputs and outputs are properly formatted,
        // not that they actually have the money inside
        guard !inputs.isEmpty else {
            throw Cosmos.Error.noInputs
        }
        
        guard !inputs.isEmpty else {
            throw Cosmos.Error.noOutputs
        }

        try validate(
            inputs: inputs,
            outputs: outputs
        )
    }

    // GetSignBytes Implements Msg.
    var signedData: Data {
        return mustSortJSON(data: Codec.bankCodec.mustMarshalJSON(value: self))
    }

    // GetSigners Implements Msg.
    var signers: [AccountAddress] {
        inputs.map(\.address)
    }
}

// Input models transaction input
public struct Input: Codable {
    let address: AccountAddress
    let coins: [Coin]
    
    // NewInput - create a transaction input, used with MsgMultiSend
    internal init(address: AccountAddress, coins: [Coin]) {
        self.address = address
        self.coins = coins
    }
}

extension Input {
    // ValidateBasic - validate transaction input
    func validateBasic() throws  {
        guard !address.isEmpty else {
            throw Cosmos.Error.invalidAddress(address: "input address missing")
        }
        
        guard coins.isValid else {
            throw Cosmos.Error.invalidCoins(reason: "\(coins)")
        }
        
        guard coins.isAllPositive else {
            throw Cosmos.Error.invalidCoins(reason: "\(coins)")
        }
    }
}
    

// Output models transaction outputs
public struct Output: Codable {
    let address: AccountAddress
    let coins: [Coin]
    
    // NewOutput - create a transaction output, used with MsgMultiSend
    internal init(address: AccountAddress, coins: [Coin]) {
        self.address = address
        self.coins = coins
    }
}

extension Output {
    // ValidateBasic - validate transaction output
    func validateBasic() throws {
        guard !address.isEmpty else {
            throw Cosmos.Error.invalidAddress(address: "output address missing")
        }
        
        guard coins.isValid else {
            throw Cosmos.Error.invalidCoins(reason: "\(coins)")
        }

        guard coins.isAllPositive else {
            throw Cosmos.Error.invalidCoins(reason: "\(coins)")
        }
    }
}

extension MultiSendMessage {
    // ValidateInputsOutputs validates that each respective input and output is
    // valid and that the sum of inputs is equal to the sum of outputs.
    func validate(
        inputs: [Input],
        outputs: [Output]
    ) throws {
        var totalIn = [Coin]()
        var totalOut = [Coin]()

        for input in inputs {
            try input.validateBasic()
            totalIn = totalIn + input.coins
        }

        for output in outputs {
            try output.validateBasic()
            totalOut = totalOut + output.coins
        }

        // make sure inputs and outputs match
        guard totalIn == totalOut else {
            throw Cosmos.Error.inputOutputMismatch
        }
    }
}
