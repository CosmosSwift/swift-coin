import Cosmos
import XBank

// Keeper of the nameservice store
public struct NameServiceKeeper {
    let coinKeeper: BankKeeper
    let storeKey: StoreKey
    let codec: Codec
    
    // NewKeeper creates a nameservice keeper
    public init(coinKeeper: BankKeeper, codec: Codec, storeKey: StoreKey) {
        self.coinKeeper = coinKeeper
        self.storeKey = storeKey
        self.codec = codec
    }
}
