import Peek

public protocol Shrubbery:
    AnyWrapper,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral where Key: Hashable
{
    typealias Index = Fork<Key>

    func get(_ path: [Index]) throws -> Self
    
    mutating
    func set(_ value: Any?, at path: [Index]) throws
    
    mutating
    func delete(_ path: [Index])
}

// MARK: as

extension Shrubbery {
    
    public func cast<A>(to: A.Type = A.self) throws -> A {
        try self.as(A.self)
    }
        
    public func `as`<A>(_: A.Type) throws -> A {
        guard let a = unwrapped as? A ?? self as? A else {
            throw "Expected \(A.self) but got \(type(of: unwrapped))".error()
        }
        return a
    }
}

// MARK: subscript

extension Shrubbery {

    public subscript(_ path: Index...) -> Self? {
        get { self[path] }
        set { self[path] = newValue }
    }

    public subscript<Path>(_ path: Path) -> Self?
    where
        Path: Collection,
        Path.Element == Index
    {
        get {
            do { return try get(path) }
            catch { "\(error)".peek(as: .debug) }
            return nil
        }
        set {
            do { try set(newValue, at: path.array) }
            catch { "\(error)".peek(as: .debug) }
        }
    }
}

extension Shrubbery {

    public subscript<A>(_ path: Index..., as _: A.Type = A.self) -> A? {
        get { self[path, as: A.self] }
        set { self[path, as: A.self] = newValue }
    }

    public subscript<A, Path>(_ path: Path, as _: A.Type = A.self) -> A?
    where
        Path: Collection,
        Path.Element == Index
    {
        get {
            do { return try get(path.array, as: A.self) }
            catch { "\(error)".peek(as: .debug) }
            return nil
        }
        set {
            do { try set(newValue, at: path.array) }
            catch { "\(error)".peek(as: .debug) }
        }
    }
}

// MARK: get

extension Shrubbery {
    
    public func get<A>(_ path: Index..., as: A.Type = A.self) throws -> A {
        try get(path.array).as(A.self)
    }
    
    public func get<A, Path>(_ path: Path, as: A.Type = A.self) throws -> A
    where
        Path: Collection,
        Path.Element == Index
    {
        try get(path.array).as(A.self)
    }
}

// MARK: set

extension Shrubbery {

    public mutating func set<A>(_ value: A, at path: Index...) throws {
        try set(value as Any?, at: path)
    }
    
    public mutating func set<A, Path>(_ value: A, at path: Path) throws
    where
        Path: Collection,
        Path.Element == Index
    {
        try set(value as Any?, at: path.array)
    }
    
    public mutating func delete<Path>(_ path: Path)
    where
        Path: Collection,
        Path.Element == Index
    {
        delete(path.array)
    }
}

// MARK: expresible

extension Shrubbery {

    public init(arrayLiteral elements: Value...) {
        self.init(elements)
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(elements){ _, last in last })
    }
}

// MARK: lift

public prefix func ^ <S: Shrubbery>(array: [S]) -> S {
    S(array.map(\.unwrapped).ifNotEmpty)
}

public prefix func ^ <S: Shrubbery>(dictionary: [S.Key: S]) -> S {
    S(dictionary.mapValues(\.unwrapped).ifNotEmpty)
}
