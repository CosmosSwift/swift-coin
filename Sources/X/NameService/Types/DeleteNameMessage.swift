import Foundation
import Tendermint
import Cosmos

public struct DeleteNameMessage: Codable {
    let name: String
    let owner: AccountAddress
    
    public init(name: String, owner: AccountAddress) {
        self.name = name
        self.owner = owner
    }
}

extension DeleteNameMessage: Message {
    
    public static let metaType: MetaType = Self.metaType(
        key: "nameservice/DeleteName"
    )
    
    public var route: String {
        NameServiceKeys.routerKey
    }
    
    public var type: String {
        "delete_name"
    }

    public var signers: [AccountAddress] {
        [owner]
    }

    public var toSign: Data {
        mustSortJSON(data: Codec.moduleCodec.mustMarshalJSON(value: self))
    }

    public func validateBasic() throws {
        if owner.isEmpty {
            throw Cosmos.Error.invalidAddress(address: "owner can't be empty")
        }
    }
}
