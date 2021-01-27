import Foundation
import Tendermint
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
    static let metaType: MetaType = Self.metaType(
        key: "nameservice/BuyName"
    )
    
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
        guard !buyer.isEmpty else {
            throw Cosmos.Error.invalidAddress(address: buyer.description)
        }
        
        guard !name.isEmpty else {
            throw Cosmos.Error.unknownRequest(reason: "Name cannot be empty")
        }
        
        guard bid.isAllPositive else {
            throw Cosmos.Error.insufficientFunds(reason: "")
        }
    }

    // GetSignBytes encodes the message for signing
    var signedData: Data {
        mustSortJSON(data: Codec.moduleCodec.mustMarshalJSON(value: self))
    }

    // GetSigners defines whose signature is required
    var signers: [AccountAddress] {
        [buyer]
    }
}
