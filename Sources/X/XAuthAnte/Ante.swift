import Cosmos
import XAuth
import XSupply

extension Auth {
    // NewAnteHandler returns an AnteHandler that checks and increments sequence
    // numbers, checks signatures & account numbers, and deducts fees from the first
    // signer.
    public static func anteHandler(
        accountKeeper: AccountKeeper,
        supplyKeeper: SupplyKeeper,
        signatureVerificationGasConsumer: SignatureVerificationGasConsumer
    ) -> AnteHandler? {
        return chainAnteDecorators([
            // outermost AnteDecorator. SetUpContext must be called first
            SetUpContextDecorator(),
            // TODO: Implement the rest
//            MempoolFeeDecorator(),
//            ValidateBasicDecorator(),
//            ValidateMemoDecorator(ak),
//            ConsumeGasForTxSizeDecorator(ak),
//            SetPubKeyDecorator(ak), // SetPubKeyDecorator must be called before all signature verification decorators
//            ValidateSigCountDecorator(ak),
//            DeductFeeDecorator(ak, supplyKeeper),
//            SigGasConsumeDecorator(ak, sigGasConsumer),
//            SigVerificationDecorator(ak),
//            IncrementSequenceDecorator(ak), // innermost AnteDecorator
        ])
    }
}
