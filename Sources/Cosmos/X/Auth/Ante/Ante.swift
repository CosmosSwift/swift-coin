extension Auth {
    // NewAnteHandler returns an AnteHandler that checks and increments sequence
    // numbers, checks signatures & account numbers, and deducts fees from the first
    // signer.
    public static func anteHandler(
        accountKeeper: AccountKeeper,
        supplyKeeper: SupplyKeeper,
        signatureVerificationGasConsumer: SignatureVerificationGasConsumer
    ) -> AnteHandler {
        // TODO: Implement
        fatalError()
    //    return sdk.ChainAnteDecorators(
    //        NewSetUpContextDecorator(), // outermost AnteDecorator. SetUpContext must be called first
    //        NewMempoolFeeDecorator(),
    //        NewValidateBasicDecorator(),
    //        NewValidateMemoDecorator(ak),
    //        NewConsumeGasForTxSizeDecorator(ak),
    //        NewSetPubKeyDecorator(ak), // SetPubKeyDecorator must be called before all signature verification decorators
    //        NewValidateSigCountDecorator(ak),
    //        NewDeductFeeDecorator(ak, supplyKeeper),
    //        NewSigGasConsumeDecorator(ak, sigGasConsumer),
    //        NewSigVerificationDecorator(ak),
    //        NewIncrementSequenceDecorator(ak), // innermost AnteDecorator
    //    )
    }
}
