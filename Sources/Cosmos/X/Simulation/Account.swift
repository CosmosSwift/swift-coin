import Tendermint

// Account contains a privkey, pubkey, address tuple
// eventually more useful data can be placed in here.
// (e.g. number of coins)
public struct Account {
    let privateKey: PrivateKey
    let publicKey: PublicKey
    let address: AccountAddress
}
