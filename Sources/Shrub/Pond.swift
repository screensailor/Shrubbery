/**
 * - Datum<Key, Value, Context> instead of Result<Value, Error>
 * - events vs? streams - i.e. events as streams of () or of Event value?
 * - subscribing vs observing
 * - concurrent and serial dependencies - i.e. group vs sequence
 * - flat collections (path components) vs deep documents (values)
 * - decoder & encoder of ``Shrubbery`` (`as _: A.Type` tries a cast then decode where `A: Decodable`)
 */
public struct Datum<Key, Value, Context> where Key: Hashable {
    public let source: Route<Key>
    public let result: Result<Shrub<Key, Value>, Error>
    public let context: Context
}

public protocol Encoded: Shrubbery where Key == String, Value: Codable {}
public typealias Coded = Shrub<String, Codable>

public typealias Flow<A> = AnyPublisher<Result<A, Error>, Never>

public typealias Fork<Key> = EitherType<Int, Key> where Key: Hashable
public typealias Route<Key> = [Fork<Key>] where Key: Hashable

public protocol Delta {
    associatedtype Key: Hashable
    func flow<A>(of: Key, as: A.Type) -> Flow<A>
}

public protocol Geyser: Delta where Key: Collection {
    associatedtype Value
    typealias PrefixCount = Int
    func gush(of: Key) -> Flow<Value>
    func source(of: Key) -> AnyPublisher<PrefixCount, Error> // TODO: should Error be GeyserError?
}

extension Geyser where Value: Shrubbery {
    
    public func flow<A>(of route: Key, as: A.Type) -> Flow<A> {
        gush(of: route).map{ o in Result{ try o.get().as(A.self) } }.eraseToAnyPublisher()
    }
}

public enum GeyserError<Key>: Error {
    case badKey(key: Key, message: String)
}

public class Pond<Source, Key, Value>: Delta
where
    Source: Geyser,
    Source.Key.Element == EitherType<Int, Key>,
    Source.Value == Value,
    Key: Hashable
{
    public typealias Fork = Source.Key.Element
    public typealias Route = [Fork]
    public typealias Store = DeltaShrub<Key, Value>
    
    public let source: Source
    private var store: Store
    
    public init(
        source: Source,
        store: Store = .init()
    ) {
        self.source = source
        self.store = store
    }

    public func flow<A>(of: Route, as: A.Type) -> Flow<A> {
        
        
        return Just(Result<A, Error>.failure("⚠️".error())).eraseToAnyPublisher()
    }
}
