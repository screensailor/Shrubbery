/**
 * - events vs? streams - i.e. events as streams of () or of Event value?
 * - subscribing vs observing
 * - concurrent and serial dependencies - i.e. group vs sequence
 * - flat collections (path components) vs deep documents (values)
 * - decoder & encoder of ``Shrubbery`` (`as _: A.Type` tries a cast then decode where `A: Decodable`)
 */
public typealias Code = Shrub<String, Codable>
public protocol Encoded: Shrubbery where Key == String, Value: Codable {}

extension Shrub: Shrubbery {}

public protocol Shrubbery {
    
    associatedtype Key: Hashable
    associatedtype Value
    
    typealias Index = EitherType<Int, Key>
    
    func get<A, Path>(_ path: Path, as: A.Type) throws -> A
    where
        Path: Collection,
        Path.Element == Index
}

// TODO: implement most of Shrub here

