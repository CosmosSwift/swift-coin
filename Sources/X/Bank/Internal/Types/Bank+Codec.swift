import Cosmos

extension Codec {
    // ModuleCdc defines the module codec
    public static let bankCodec = Codec()
}

extension BankAppModuleBasic {
    // RegisterCodec registers concrete types on codec
    static func register(codec: Codec) {
        SendMessage.registerMetaType()
        MultiSendMessage.registerMetaType()
    }
}
