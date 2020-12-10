@_functionBuilder public struct RouteBuilder {
    public static func buildBlock<Destination>(_ component: Route<Destination>) -> [Route<Destination>] {
        [component]
    }
    
    public static func buildBlock<Destination>(_ components: Route<Destination>...) -> [Route<Destination>] {
        components
    }
}
