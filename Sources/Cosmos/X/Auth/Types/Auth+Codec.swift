extension Codec {
    // ModuleCdc auth module wide codec
    static let authCodec = Codec()
}

extension AuthAppModuleBasic {
    // RegisterCodec registers concrete types on the codec
    static func register(codec: Codec) {
    //    codec.registerInterface(type: GenesisAccount.self)
    //    codec.registerInterface(type: Account.self)
        BaseAccount.registerMetaType()
    //    codec.registerConcrete(type: StandardTransaction.self, name: "cosmos-sdk/StdTx")
    }

    // RegisterAccountTypeCodec registers an external account type defined in
    // another module for the internal ModuleCdc.
    func registerAccountTypeCodec<A: Account>(type: A.Type, name: String) {
        // TODO: I don't think we need this.
        fatalError()
        Codec.authCodec.registerConcrete(type: type, name: name)
    }

    func initCodec() {
        // TODO: I don't think we need this.
        fatalError()
        Self.register(codec: Codec.authCodec)
    //    codec.registerCrypto(codec: Codec.authCodec)
    }
}
