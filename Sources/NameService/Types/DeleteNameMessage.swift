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
        NameServiceKeys.routerKey
    }
    
    var type: String {
        "delete_name"
    }

    var signers: [AccountAddress] {
        [owner]
    }

    var signedData: Data {
        mustSortJSON(data: Codec.moduleCodec.mustMarshalJSON(value: self))
    }

    func validateBasic() throws {
        if owner.isEmpty {
            throw Cosmos.Error.invalidAddress(address: "owner can't be empty")
        }
    }
}
