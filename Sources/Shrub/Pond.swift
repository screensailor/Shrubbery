/**
 * - events vs? streams - i.e. events as streams of () or of Event value?
 * - subscribing vs observing
 * - concurrent and serial dependencies - i.e. group vs sequence
 * - flat collections (path components) vs deep documents (values)
 * - decoder & encoder of ``Shrubbery`` (`as _: A.Type` tries a cast then decode where `A: Decodable`)
 */
public typealias Coded = Shrub<String, Codable>
public protocol Encoded: Shrubbery where Key == String, Value: Codable {}

public typealias Flow<A> = AnyPublisher<Result<A, Error>, Never>

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

public struct Signal<Key, Value> where Key: Hashable {
    public let date: Double
    public let route: Route<Key>
    public let result: Result<Shrub<Key, Value>, Error>
}
