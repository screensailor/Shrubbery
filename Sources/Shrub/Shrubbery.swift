import Peek

public protocol Shrubbery:
    AnyWrapper,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    CustomDebugStringConvertible
where
    Key: Hashable,
    Value == Any
{
    typealias Fork = EitherType<Int, Key> where Key: Hashable
    typealias Route = [Fork]

    func get(_ route: Route) throws -> Self
    
    mutating
    func set(_ route: Route, to: Any?) throws

    mutating
    func delete(_ route: Route)
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

    public subscript(_ route: Fork...) -> Self? {
        get { self[route] }
        set { self[route] = newValue }
    }

    public subscript<Route>(_ route: Route) -> Self?
    where
        Route: Collection,
        Route.Element == Fork
    {
        get {
            do {
                return try get(route)
            }
            catch {
                if #available(iOS 14.0, *) {
                    "\(error)".peek(as: .debug)
                }
            }
            return nil
        }
        set {
            do {
                try set(route.array, to: newValue)
            }
            catch {
                if #available(iOS 14.0, *) {
                    "\(error)".peek(as: .debug)
                }
            }
        }
    }
}

extension Shrubbery {

    public subscript<A>(_ route: Fork..., as _: A.Type = A.self) -> A? {
        get { self[route, as: A.self] }
        set { self[route, as: A.self] = newValue }
    }

    public subscript<A, Route>(_ route: Route, as _: A.Type = A.self) -> A?
    where
        Route: Collection,
        Route.Element == Fork
    {
        get {
            do {
                return try get(route.array, as: A.self)
            }
            catch {
                if #available(iOS 14.0, *) {
                    "\(error)".peek(as: .debug)
                }
            }
            return nil
        }
        set {
            do { try set(route.array, to: newValue) }
            catch {
                if #available(iOS 14.0, *) {
                    "\(error)".peek(as: .debug)
                }
            }
        }
    }
}

// MARK: get

extension Shrubbery {
    
    public func get<A>(_ route: Fork..., as: A.Type = A.self) throws -> A {
        try get(route.array).as(A.self)
    }
    
    public func get<A, Route>(_ route: Route, as: A.Type = A.self) throws -> A
    where
        Route: Collection,
        Route.Element == Fork
    {
        try get(route.array).as(A.self)
    }
}

// MARK: set

extension Shrubbery {

    public mutating func set<A>(_ route: Fork..., to value: A) throws {
        try set(route, to: value as Any?)
    }
    
    public mutating func set<A, Route>(_ route: Route, to value: A) throws
    where
        Route: Collection,
        Route.Element == Fork
    {
        try set(route.array, to: value as Any?)
    }
    
    public mutating func delete<Route>(_ route: Route)
    where
        Route: Collection,
        Route.Element == Fork
    {
        delete(route.array)
    }
}

// MARK: expresible

extension Shrubbery {

    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
    
    public init(dictionaryLiteral elements: (Key, Any)...) {
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

// MARK: traverse

public enum ShrubberyValue<Key>
where Key: Hashable
{
    case none
    case leaf(Any)
    case array([Any])
    case dictionary([Key: Any])
}

extension ShrubberyValue {
    
    public var any: Any? {
        switch self
        {
        case .none: return nil
        case .leaf(let leaf): return leaf
        case .array(let array): return array
        case .dictionary(let dictionary): return dictionary
        }
    }
}

extension Shrubbery {
    
    // TODO:❗️breadth vs depth first
    // TODO: make it a Publisher
    /// Depth first traversal
    public func traverse(
        sort: ([Key: Any]) -> [(Key, Any)] = { $0.map{ $0 } },
        yield: ((route: [Fork], value: ShrubberyValue<Key>)) -> ()
    ) {
        Self.traverse(route: [], this: self, sort: sort, yield: yield)
    }
    
    private static func traverse(
        route: [Fork],
        this: Any?,
        sort: ([Key: Any]) -> [(Key, Any)] = { $0.map{ $0 } },
        yield: ((route: [Fork], value: ShrubberyValue<Key>)) -> ()
    ) {
        let ºany = flattenOptionality(
            of: (this as? AnyWrapper)?.unwrapped ?? this
        )
        switch ºany
        {
        case let array as [Any]:
            yield((route, .array(array)))
            for (i, element) in array.enumerated() {
                traverse(route: route + [^i], this: element, sort: sort, yield: yield)
            }
            
        case let dictionary as [Key: Any]:
            yield((route, .dictionary(dictionary)))
            for (key, value) in sort(dictionary) {
                traverse(route: route + [^key], this: value, sort: sort, yield: yield)
            }
            
        case let any?:
            yield((route, .leaf(any)))
            
        case nil:
            yield((route, .none))
        }
    }
}

extension Shrubbery where Key: Comparable {
    
    /// Depth first traversal
    public func traverse(
        sort: ([Key: Any]) -> [(Key, Any)] = { $0.sorted{ $0.key < $1.key } },
        yield: ((route: [Fork], value: ShrubberyValue<Key>)) -> ()
    ) {
        Self.traverse(route: [], this: self, sort: sort, yield: yield)
    }
}

extension Shrubbery {
    
    public var debugDescription: String {
        sortedDescription{ $0.sorted{ "\($0.key)" < "\($1.key)" } }
    }
    
    public func sortedDescription(_ sort: ([Key: Any]) -> [(Key, Any)]) -> String {
        var o = "\(Self.self)"
        traverse(sort: sort) { route, value in
            let t = repeatElement("  |", count: max(0, route.count - 1)).joined()
            switch value {
            case .none, .leaf:
                o += "\(t)  \(route.last?.description ?? ""): "
                o += "\(value.any.map(String.init(describing:)) ?? "nil")\n"
            case .array, .dictionary:
                o += "\(t)  \(route.last?.description ?? "")\n"
            }
        }
        return o
    }
}

extension Shrubbery where Key: Comparable {
    
    public var debugDescription: String {
        sortedDescription{ $0.sorted{ $0.key < $1.key } }
    }
}
