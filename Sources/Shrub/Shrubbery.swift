/*
 * - decoder & encoder of Shrubbery
 * - subscribing vs observing
 * - flat collections (path components) vs deep documents (values)
 */

// TODO: implement most of Shrub here

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
