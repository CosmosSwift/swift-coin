final class State {
    let multiStore: CacheMultiStore
    var request: Request
   
    init(
        multiStore: CacheMultiStore,
        request: Request
    ) {
        self.multiStore = multiStore
        self.request = request
    }
}
