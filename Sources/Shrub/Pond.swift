/**
 * - unflow everything?, keep .flow() as just an operator?
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
    func source(of: Key) throws -> PrefixCount // TODO:❗️-> AnyPublisher<PrefixCount, Error>
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
    Source.Key == [EitherType<Int, Key>],
    Source.Value == Value,
    Key: Hashable
{
    public typealias Basin = DeltaShrub<Key, Value>
    public typealias Route = Source.Key
    public typealias Fork = Source.Key.Element
    
    public let geyser: Source
    
    private var basin: Basin
    private var bag: Set<AnyCancellable> = []
    
    public init(
        geyser: Source,
        basin: Basin = .init()
    ) {
        self.geyser = geyser
        self.basin = basin
    }
    
    deinit { // TODO:❗️test 🗑
        print("✅ 🗑", Self.self, ObjectIdentifier(self))
    }

    public func flow<A>(of route: Route, as: A.Type) -> Flow<A> {
        
        let source: Route
        
        do {
            source = try Array(route.prefix(geyser.source(of: route)))
        } catch {
            return error.flow()
        }
        
        
        
        
        return basin.flow(of: route)
    }
}
