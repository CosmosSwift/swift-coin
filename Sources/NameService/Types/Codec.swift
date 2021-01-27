import Cosmos

extension Codec {
    // ModuleCdc defines the module codec
    static let moduleCodec = Codec()
}

extension NameServiceAppModuleBasic {
    // RegisterCodec registers concrete types on codec
    static func register(codec: Codec) {
        // this line is used by starport scaffolding # 1
        BuyNameMessage.registerMetaType()
        SetNameMessage.registerMetaType()
        DeleteNameMessage.registerMetaType()
    }
}
