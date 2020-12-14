import Foundation
import Cosmos

struct DeleteNameMessage: Codable {
    let name: String
    let owner: AccountAddress
    
    init(name: String, owner: AccountAddress) {
        self.name = name
        self.owner = owner
    }
}

extension DeleteNameMessage: Message {
    var route: String {
        Keys.routerKey
    }
    
    var type: String {
        "delete_name"
    }

    func getSigners() -> [AccountAddress] {
        [owner]
    }

    func getSignBytes() -> Data {
        mustSortJSON(data: Codec.moduleCodec.mustMarshalJSON(value: self))
    }

    func validateBasic() throws {
        if owner.isEmpty {
            throw Cosmos.Error.invalidAddress(address: "owner can't be empty")
        }
    }
}
