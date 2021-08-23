public protocol Geyser: Routed {
    
    associatedtype GeyserFlow: Publisher where
        GeyserFlow.Output: Droplet,
        GeyserFlow.Failure == Never

    func source(of route: Route) throws -> Route // TODO:❗️Publisher
    func gush(_ route: Route) -> GeyserFlow
}
