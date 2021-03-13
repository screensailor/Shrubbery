/**
 * - events vs? streams - i.e. events as streams of () or of Event value?
 * - subscribing vs observing
 * - concurrent and serial dependencies - i.e. group vs sequence
 * - flat collections (path components) vs deep documents (values)
 * - decoder & encoder of ``Shrubbery`` (`as _: A.Type` tries a cast then decode where `A: Decodable`)
 */
public protocol Encoded: Shrubbery where Key == String, Value: Codable {}
public typealias Coded = Shrub<String, Codable>

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

// TODO: instead of Result ↓
public struct Datum<Key, Value, Context> where Key: Hashable {
    public let route: Route<Key>
    public let result: Result<Shrub<Key, Value>, Error>
    public let context: Context
}
