import Foundation
import Tendermint
import Cosmos

// MsgBuyName defines the BuyName message

public struct BuyNameMessage: Message {
    
    public static var metaType: MetaType = Self.metaType(
        key: "cosmos-sdk/BuyName" // TODO: is this the right string?
    )
    
    let name: String
    let bid: [Coin]
    let buyer: AccountAddress
    
    public init(name: String, bid: [Coin], buyer: AccountAddress) {
        self.name = name
        self.bid = bid
        self.buyer = buyer
    }
}

extension BuyNameMessage {
    // Route Implements Msg.
    public var route: String {
        NameServiceKeys.routerKey
    }
    
    // Type Implements Msg.
    public var type: String {
        "buy_name"
    }
    
    // ValidateBasic Implements Msg.
    public func validateBasic() throws { // TODO:
        guard !buyer.isEmpty else {
            throw Cosmos.Error.invalidAddress(address: "missing buyer address")
        }
        
        guard bid.isValid else {
            throw Cosmos.Error.invalidCoins(reason: "\(bid)")
        }
        
        guard bid.isAllPositive else {
            throw Cosmos.Error.invalidCoins(reason: "\(bid)")
        }
    }
    
    // GetSignBytes Implements Msg.
    public var toSign: Data {
        mustSortJSON(data: Codec.bankCodec.mustMarshalJSON(value: self))
    }
    
    // GetSigners Implements Msg.
    public var signers: [AccountAddress] {
        [buyer]
    }
}
