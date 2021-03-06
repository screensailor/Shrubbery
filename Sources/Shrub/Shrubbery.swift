/**
 * - events vs? streams - i.e. events as streams of () or of Event value?
 * - subscribing vs observing
 * - decoder & encoder of Shrubbery
 * - flat collections (path components) vs deep documents (values)
 */
public typealias Code = Shrub
public typealias Encoded = Shrubbery

extension Shrub: Shrubbery {}

public protocol Shrubbery {
    
    associatedtype Key: Hashable
    typealias Index = EitherType<Int, Key>
    
    func get<A, Path>(_ path: Path, as: A.Type) throws -> A
    where
        Path: Collection,
        Path.Element == Index
}

// TODO: implement most of Shrub here

