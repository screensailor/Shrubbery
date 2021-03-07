public protocol Delta {
    associatedtype Key: Hashable
    func stream<A>(of: Key, as: A.Type) -> Stream<A>
}

public protocol Tributary: Delta {
    associatedtype RouteKey: Hashable
    typealias Route = [EitherType<Int, RouteKey>]
    func route(to: Key) -> AnyPublisher<Route, Error>
    func source(of: Key) -> AnyPublisher<Key, Error>
}

public protocol Pond: Delta {
    
}
