extension Codec {
    // TODO: Use this strategy for all modules' codecs
    static let keysCodec: Codec = {
        let codec = Codec()
        registerKeysCodec(codec: codec)
        return codec
    }()
}

// RegisterCodec registers concrete types and interfaces on the given codec.
func registerKeysCodec(codec: Codec) {
//    cdc.RegisterInterface((*Info)(nil), nil)
//    cdc.RegisterConcrete(hd.BIP44Params{}, "crypto/keys/hd/BIP44Params", nil)
//    cdc.RegisterConcrete(localInfo{}, , nil)
    LocalInfo.registerMetaType()
//    cdc.RegisterConcrete(ledgerInfo{}, "crypto/keys/ledgerInfo", nil)
    OfflineInfo.registerMetaType()
//    cdc.RegisterConcrete(multiInfo{}, "crypto/keys/multiInfo", nil)
}
