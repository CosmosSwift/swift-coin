import Foundation
import Tendermint
import Cosmos
import XAuth

// SignatureVerificationGasConsumer is the type of function that is used to both
// consume gas when verifying signatures and also to accept or reject different types of pubkeys
// This is where apps can define their own PubKey
public typealias SignatureVerificationGasConsumer = (_ gasMeter: GasMeter, _ signature: Data, _ publicKey: PublicKey, _ params: AuthParameters) throws -> Void

extension Auth {
    // DefaultSigVerificationGasConsumer is the default implementation of SignatureVerificationGasConsumer. It consumes gas
    // for signature verification based upon the public key type. The cost is fetched from the given params and is matched
    // by the concrete type.
    public static func defaultSignatureVerificationGasConsumer(
        gasMeter: GasMeter,
        signatue: Data,
        publicKey: PublicKey,
        parameters: AuthParameters
    ) throws {
        // TODO: Implement
        fatalError()
//        switch pubkey := pubkey.(type) {
//        case ed25519.PubKeyEd25519:
//            meter.ConsumeGas(params.SigVerifyCostED25519, "ante verify: ed25519")
//            return sdkerrors.Wrap(sdkerrors.ErrInvalidPubKey, "ED25519 public keys are unsupported")
//
//        case secp256k1.PubKeySecp256k1:
//            meter.ConsumeGas(params.SigVerifyCostSecp256k1, "ante verify: secp256k1")
//            return nil
//
//        case multisig.PubKeyMultisigThreshold:
//            var multisignature multisig.Multisignature
//            codec.Cdc.MustUnmarshalBinaryBare(sig, &multisignature)
//
//            ConsumeMultisignatureVerificationGas(meter, multisignature, pubkey, params)
//            return nil
//
//        default:
//            return sdkerrors.Wrapf(sdkerrors.ErrInvalidPubKey, "unrecognized public key type: %T", pubkey)
//        }
    }
}
