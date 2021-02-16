import Cosmos

extension Codec {
    // ModuleCdc is a generic sealed codec to be used throughout this module
    static let stakingCodec = Codec()
}

extension StakingAppModuleBasic {
    static func register(codec: Codec) {
        // TODO: Implement
//        CreateValidatorMessage.registerMetaType()
//        EditValidatorMessage.registerMetaType()
//        DelegateMessage.registerMetaType()
//        UndelegateMessage.registerMetaType()
//        BeginRedelegateMessage.registerMetaType()
//        cdc.RegisterConcrete(MsgCreateValidator{}, "cosmos-sdk/MsgCreateValidator", nil)
//        cdc.RegisterConcrete(MsgEditValidator{}, "cosmos-sdk/MsgEditValidator", nil)
//        cdc.RegisterConcrete(MsgDelegate{}, "cosmos-sdk/MsgDelegate", nil)
//        cdc.RegisterConcrete(MsgUndelegate{}, "cosmos-sdk/MsgUndelegate", nil)
//        cdc.RegisterConcrete(MsgBeginRedelegate{}, "cosmos-sdk/MsgBeginRedelegate", nil)
    }
}
