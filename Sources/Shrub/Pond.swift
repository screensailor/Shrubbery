public typealias Fork<Key> = EitherType<Int, Key> where Key: Hashable
public typealias Route<Key> = [Fork<Key>] where Key: Hashable

public protocol Delta {
    associatedtype Key: Hashable
    func flow<A>(of: Key, as: A.Type) -> Flow<A>
}

public protocol Tributary: Delta where Key: Collection {
    typealias PrefixCount = Int
    func source(of: Key) -> Flow<PrefixCount>
}

public protocol Pond: Delta {
    
}
