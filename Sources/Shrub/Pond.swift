public typealias Fork<Key> = EitherType<Int, Key> where Key: Hashable
public typealias Route<Key> = [Fork<Key>] where Key: Hashable

public protocol Delta {
    associatedtype Key: Hashable
    func flow<A>(of: Key, as: A.Type) -> Flow<A>
}

public protocol Tributary: Delta {
    associatedtype RouteKey: Hashable
    func source(of: Key) -> Flow<Key>
    func route(to: Key) -> Flow<Route<RouteKey>>
}

public protocol Pond: Delta {
    
}
