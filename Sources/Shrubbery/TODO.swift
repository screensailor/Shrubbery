/**
 * - repos for:
 *      - Datum/Droplet
 *      - EitherType
 *      - Paths
 *      - Tree
 *      - Shrub
 *      - Hedge<Key, Value>
 *      - Pond
 * - unflow everything?, keep .flow() as just an operator?
 * - - Result<Any?, Error>: Shrubbery
 * - Datum<Key, Value, Context> instead of Result<Value, Error>
 * - events vs? streams - i.e. events as streams of () or of Event value?
 * - subscribing vs observing
 * - concurrent and serial dependencies - i.e. group vs sequence
 * - flat collections (path components) vs deep documents (values)
 * - decoder & encoder of ``Shrubbery`` (`as _: A.Type` tries a cast then decode where `A: Decodable`)
 */
public struct Datum<Key, Value, Context> where Key: Hashable {
    public let source: [EitherType<Int, Key>]
    public let result: Result<Shrub<Key>, Error>
    public let context: Context
}

public protocol Hedgerow /* Shrubbery */ {
    associatedtype Key: Hashable
    associatedtype Value
}

public struct Hedge<Key, Value>: Hedgerow
where Key: Hashable {}

public protocol Encoded: Hedgerow where Key == String, Value: Codable {}
public typealias Coded<Value> = Hedge<String, Value> where Value: Codable

public struct AnyEquatableError: Equatable, Error {
    
    public static func == (lhs: AnyEquatableError, rhs: AnyEquatableError) -> Bool {
        lhs.isEqualTo(rhs.error)
    }

    public let error: Error
    public let isEqualTo: (Error) -> Bool
    
    public init<E>(_ error: E) where E: Error, E: Equatable {
        self.error = error
        self.isEqualTo = { error == $0 as? E }
    }
}

extension Error where Self: Equatable {
    
    public func typeErased() -> AnyEquatableError { .init(self) }
}
