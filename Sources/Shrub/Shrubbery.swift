extension Shrub: Shrubbery {}

public protocol Shrubbery {
    
    associatedtype Key: Hashable
    typealias Index = EitherType<Int, Key>
    
    func get<A, Path>(_ path: Path, as: A.Type) throws -> A
    where
        Path: Collection,
        Path.Element == Index
}
