@_exported import Combine

extension String: Error {}

public protocol Shrubbery:
    Routed,
    AnyWrapper,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    CustomDebugStringConvertible
where
    Value == Any?
{
    func get(_ route: Route) throws -> Self
    mutating func set(_ route: Route, to value: Any?)
    mutating func delete(_ route: Route)
}

public protocol ShrubberyObject: Shrubbery {
    func set(_ route: Route, to value: Any?)
    func delete(_ route: Route)
}

// MARK: views

extension Shrubbery {
    
    public var branches: AnyCollection<Fork> {
        switch unwrapped {
        case let o as [Any?]: return AnyCollection(o.indices.lazy.map(Fork.init))
        case let o as [Key: Any?]: return AnyCollection(o.keys.lazy.map(Fork.init))
        default: return AnyCollection([])
        }
    }
}

// MARK: casting

extension Shrubbery {
    
    public func cast<A>(to: A.Type = A.self) throws -> A {
        try self.as(A.self)
    }
        
    public func `as`<A>(_: A.Type) throws -> A {
        guard let a = unwrapped as? A ?? self as? A else {
            throw "Expected \(A.self) but got \(type(of: unwrapped))"
        }
        return a
    }
}

// MARK: init

extension Shrubbery {
    
    public init(_ o: Self) {
        self.init(o.unwrapped)
    }
}

// MARK: subscript -> Self

extension Shrubbery {

    public subscript(_ route: Key, _ rest: Key...) -> Self {
        get { self[[route] + rest] }
        set { self[[route] + rest] = newValue }
    }

    public subscript<Route>(_ route: Route) -> Self
    where
        Route: Collection,
        Route.Element == Key
    {
        get { self[route.map(Fork.init)] }
        set { self[route.map(Fork.init)] = newValue }
    }
    
    public subscript(_ route: Fork...) -> Self {
        get { self[route] }
        set { self[route] = newValue }
    }

    public subscript<Route>(_ route: Route) -> Self
    where
        Route: Collection,
        Route.Element == Fork
    {
        // TODO: rethink error handling here
        get {
            (try? get(route)) ?? nil
        }
        set {
            set(route.array, to: newValue.unwrapped)
        }
    }
}

// MARK: subscript<A> -> A

extension Shrubbery {

    public subscript<A>(_ route: Key, _ rest: Key..., default o: A) -> A {
        get { self[[route] + rest] ?? o }
        set { self[[route] + rest] = newValue }
    }
    
    public subscript<A, Route>(_ route: Route, default o: A) -> A
    where
        Route: Collection,
        Route.Element == Key
    {
        get { self[route] ?? o }
        set { self[route] = newValue }
    }
    
    public subscript<A>(_ route: Fork..., default o: A) -> A {
        get { self[route] ?? o }
        set { self[route] = newValue }
    }
    
    public subscript<A, Route>(_ route: Route, default o: A) -> A
    where
        Route: Collection,
        Route.Element == Fork
    {
        get { self[route] ?? o }
        set { self[route] = newValue }
    }
}

extension Shrubbery {

    public subscript<A>(_ route: Key, _ rest: Key..., as _: A.Type = A.self) -> A?{
        get { self[[route] + rest, as: A.self] }
        set { self[[route] + rest, as: A.self] = newValue }
    }

    public subscript<A, Route>(_ route: Route, as _: A.Type = A.self) -> A?
    where
        Route: Collection,
        Route.Element == Key
    {
        get { self[route.map(Fork.init), as: A.self] }
        set { self[route.map(Fork.init), as: A.self] = newValue }
    }
    
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
            try? get(route.array, as: A.self)
        }
        set {
            set(route.array, to: newValue)
        }
    }
}

// MARK: get

extension Shrubbery {
    
    public func get<A>(_ route: Key, _ rest: Key..., as: A.Type = A.self) throws -> A {
        try get([route] + rest, as: A.self)
    }

    public func get<A, Route>(_ route: Route, as: A.Type = A.self) throws -> A
    where
        Route: Collection,
        Route.Element == Key
    {
        try get(route.map(Fork.init), as: A.self)
    }

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

    @inlinable public mutating func set<A>(_ route: Key, rest: Key..., to value: A) {
        set([route] + rest, to: value as Any?)
    }
    
    @inlinable public mutating func set<A, Route>(_ route: Route, to value: A) where
        Route: Collection,
        Route.Element == Key
    {
        set(route.map{ ^$0 }, to: value)
    }

    @inlinable public mutating func set<A>(_ route: Fork..., to value: A) {
        set(route, to: value as Any?)
    }
}

extension ShrubberyObject {

    @inlinable public func set<A>(_ route: Key, rest: Key..., to value: A) {
        set([route] + rest, to: value as Any?)
    }
    
    @inlinable public func set<A, Route>(_ route: Route, to value: A) where
        Route: Collection,
        Route.Element == Key
    {
        set(route.map{ ^$0 }, to: value)
    }

    @inlinable public func set<A>(_ route: Fork..., to value: A) {
        set(route, to: value as Any?)
    }
}

// MARK: delete

extension Shrubbery {
    
    @inlinable mutating public func delete() {
        delete([])
    }
    
    @inlinable mutating public func delete(_ route: Fork...) {
        delete(route)
    }

    @inlinable mutating public func delete<Route>(_ route: Route) where
        Route: Collection,
        Route.Element == Fork
    {
        set(Array(route), to: nil)
    }
}

extension ShrubberyObject {
    
    @inlinable public func delete() {
        delete([])
    }
    
    @inlinable public func delete(_ route: Fork...) {
        delete(route)
    }

    @inlinable public func delete<Route>(_ route: Route) where
        Route: Collection,
        Route.Element == Fork
    {
        set(Array(route), to: nil)
    }
    
    public func delete(_ route: [EitherType<Int, Key>]) {
        set(Array(route), to: nil)
    }
}

// MARK: merge

extension Shrubbery {

    public mutating func merge(_ other: Self) {
        let ºother = other.unwrapped
        switch ºother
        {
        case let other as [Any]:
            guard self.unwrapped is [Any] else {
                self = .init(other)
                return
            }
            for (i, other) in other.enumerated() {
                let i = [Fork(i)]
                if let other = other as? Sentinel, other == .deletion {
                    self.delete(i)
                    continue
                }
                var o = Self(try? get(i))
                o.merge(Self(other))
                set(i, to: o)
            }

        case let other as [Key: Any]:
            guard self.unwrapped is [Key: Any] else {
                self = .init(other)
                return
            }
            for (key, other) in other {
                let key = [Fork(key)]
                if let other = other as? Sentinel, other == .deletion {
                    self.delete(key)
                    continue
                }
                var o = Self(try? get(key))
                o.merge(Self(other))
                set(key, to: o)
            }

        case let other?:
            self.set(to: other)

        case nil:
            self.delete()
        }
    }
}

// MARK: expresible

extension Shrubbery {

    public init(arrayLiteral elements: Any?...) {
        self.init(elements)
    }
    
    public init(dictionaryLiteral elements: (Key, Any?)...) {
        var o: [Key: Any] = [:]
        for (k, v) in elements {
            o[k] = v
        }
        self.init(o)
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

// MARK: traverse

extension Shrubbery {
    
    // TODO:❗️breadth vs depth first
    // TODO: make it a Publisher
    /// Depth first traversal
    public func traverse(
        sort: ([Key: Any]) -> [(Key, Any)] = { $0.map{ $0 } },
        yield: ((route: [Fork], value: ShrubberyValue<Key>)) throws -> ()
    ) rethrows {
        try Self.traverse(route: [], this: self, sort: sort, yield: yield)
    }
    
    private static func traverse(
        route: [Fork],
        this: Any?,
        sort: ([Key: Any]) -> [(Key, Any)] = { $0.map{ $0 } },
        yield: ((route: [Fork], value: ShrubberyValue<Key>)) throws -> ()
    ) rethrows {
        let ºany = flattenOptionality(
            of: (this as? AnyWrapper)?.unwrapped ?? this
        )
        switch ºany
        {
        case let array as [Any]:
            try yield((route, .array(array)))
            for (i, element) in array.enumerated() {
                try traverse(route: route + [^i], this: element, sort: sort, yield: yield)
            }
            
        case let dictionary as [Key: Any]:
            try yield((route, .dictionary(dictionary)))
            for (key, value) in sort(dictionary) {
                try traverse(route: route + [^key], this: value, sort: sort, yield: yield)
            }
            
        case let any?:
            try yield((route, .leaf(any)))
            
        case nil:
            try yield((route, .none))
        }
    }
}

extension Shrubbery where Key: Comparable {
    
    /// Depth first traversal
    public func traverse(
        sort: ([Key: Any]) -> [(Key, Any)] = { $0.sorted{ $0.key < $1.key } },
        yield: ((route: [Fork], value: ShrubberyValue<Key>)) throws -> ()
    ) rethrows {
        try Self.traverse(route: [], this: self, sort: sort, yield: yield)
    }
}

// MARK: debug description

extension Shrubbery {
    
    public var debugDescription: String {
        sortedDescription{ $0.sorted{ String(describing: $0.key) < String(describing: $1.key) } }
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
