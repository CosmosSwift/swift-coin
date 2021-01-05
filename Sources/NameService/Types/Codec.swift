import Cosmos

extension Codec {
    // RegisterCodec registers concrete types on codec
    static func register(codec: Codec) {
        // this line is used by starport scaffolding # 1
    //    codec.registerConcrete(BuyNameMessage.self, "nameservice/BuyName", nil)
    //    codec.registerConcrete(SetNameMessage.self, "nameservice/SetName", nil)
    //    codec.registerConcrete(DeleteNameMessage.self, "nameservice/DeleteName", nil)
    }

    // ModuleCdc defines the module codec
    static let moduleCodec = Codec()

    func initialize() {
    //    register(codec: moduleCodec)
    //    codec.registerCrypto(moduleCodec)
    //    moduleCodec.seal()
    }
}
