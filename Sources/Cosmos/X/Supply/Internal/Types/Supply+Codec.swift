extension Codec {
    // ModuleCdc generic sealed codec to be used throughout module
    static let supplyCodec = Codec()
}

extension SupplyAppModuleBasic {
    static func register(codec: Codec) {
        // TODO: Implement
//        cdc.RegisterInterface((*exported.ModuleAccountI)(nil), nil)
//        cdc.RegisterInterface((*exported.SupplyI)(nil), nil)
//        cdc.RegisterConcrete(&ModuleAccount{}, "cosmos-sdk/ModuleAccount", nil)
        ModuleAccount.registerMetaType()
//        cdc.RegisterConcrete(&Supply{}, "cosmos-sdk/Supply", nil)
    }
}
