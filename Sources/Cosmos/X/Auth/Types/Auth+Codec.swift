extension Codec {
    // ModuleCdc auth module wide codec
    static let authCodec = Codec()
}

extension AuthAppModuleBasic {
    // RegisterCodec registers concrete types on the codec
    static func register(codec: Codec) {
        BaseAccount.registerMetaType()
        StandardTransaction.registerMetaType()
    }
}
