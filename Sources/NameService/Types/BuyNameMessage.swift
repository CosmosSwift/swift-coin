import Foundation
import Cosmos

// MsgBuyName defines the BuyName message
struct BuyNameMessage: Codable {
    let name: String
    let bid: Coins
    let buyer: AccountAddress
    
    internal init(name: String, bid: Coins, buyer: AccountAddress) {
        self.name = name
        self.bid = bid
        self.buyer = buyer
    }
}

extension BuyNameMessage: Message {
    // Route should return the name of the module
    var route: String {
        NameServiceKeys.routerKey
    }

    // Type should return the action
    var type: String {
        "buy_name"
    }

    // ValidateBasic runs stateless checks on the message
    func validateBasic() throws {
        if buyer.isEmpty{
            throw Cosmos.Error.invalidAddress(address: buyer.string)
        }
        
        if name.isEmpty {
            throw Cosmos.Error.unknownRequest(reason: "Name cannot be empty")
        }
        
        if !bid.isAllPositive {
            throw Cosmos.Error.insufficientFunds(reason: "")
        }
    }

    // GetSignBytes encodes the message for signing
    func getSignBytes() -> Data {
        mustSortJSON(data: Codec.moduleCodec.mustMarshalJSON(value: self))
    }

    // GetSigners defines whose signature is required
    func getSigners() -> [AccountAddress] {
        [buyer]
    }
}
