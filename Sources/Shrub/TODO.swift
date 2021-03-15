/**
 * - repos for:
 *      - Datum/Droplet
 *      - EitherType
 *      - Shrub
 *      - Hedge<Key, Value>
 *      - Pond
 * - performance and stress testing
 * - unflow everything?, keep .flow() as just an operator?
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

public protocol Encoded: Shrubbery /* where Key == String, Value: Codable */ {}
public typealias Coded = Shrub<String>
