public protocol Geyser: Routed {
    
    associatedtype Flow: Publisher where
        Flow.Output: Droplet,
        Flow.Failure == Never

    func source(of route: Route) throws -> Route // TODO:❗️Publisher
    func gush(_ route: Route) -> Flow
}
