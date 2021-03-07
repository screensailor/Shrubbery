public typealias Fork<Key> = EitherType<Int, Key> where Key: Hashable
public typealias Route<Key> = [Fork<Key>] where Key: Hashable

public protocol Delta {
    associatedtype Key: Hashable
    func stream<A>(of: Key, as: A.Type) -> Flow<A>
}

public protocol Tributary: Delta {
    associatedtype RouteKey: Hashable
    func source(of: Key) -> AnyPublisher<Key, Error>
    func route(to: Key) -> AnyPublisher<Route<RouteKey>, Error>
}

public protocol Pond: Delta {
    
}
