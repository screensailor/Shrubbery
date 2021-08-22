public protocol Geyser: Routed {
    
    associatedtype Gush: Publisher where
        Gush.Output: Droplet,
        Gush.Failure == Never

    func source(of: Route) throws -> Route // TODO:❗️-> AnyPublisher<Route, Error>
    func gush(of: Route) -> Gush
}
