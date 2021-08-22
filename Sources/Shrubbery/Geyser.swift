public protocol Geyser: Routed {
    
    associatedtype GeyserFlow: Publisher where
        GeyserFlow.Output: Droplet,
        GeyserFlow.Failure == Never

    func source(of: Route) throws -> Route // TODO:❗️Publisher
    func gush(of: Route) -> GeyserFlow
}
