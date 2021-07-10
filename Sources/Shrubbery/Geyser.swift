public protocol Geyser {

    associatedtype Key: Hashable

    typealias Fork = EitherType<Int, Key>
    typealias Route = [Fork]

    func source(of: Route) throws -> Route // TODO:❗️-> AnyPublisher<Route, Error>
    func gush(of: Route) -> Flow<Shrub<Key>>
}
