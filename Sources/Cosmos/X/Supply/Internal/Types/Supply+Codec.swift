extension Codec {
    // ModuleCdc generic sealed codec to be used throughout module
    static let supplyCodec = Codec()
}

extension SupplyAppModuleBasic {
    static func register(codec: Codec) {
        ModuleAccount.registerMetaType()
    }
}
