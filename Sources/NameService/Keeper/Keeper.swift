import Cosmos
import Bank

// Keeper of the nameservice store
struct Keeper {
    let coinKeeper: Bank.Keeper
    let storeKey: StoreKey
    let codec: Codec
    
    // NewKeeper creates a nameservice keeper
    init(coinKeeper: Bank.Keeper, codec: Codec, storeKey: StoreKey) {
        self.coinKeeper = coinKeeper
        self.storeKey = storeKey
        self.codec = codec
    }
}
