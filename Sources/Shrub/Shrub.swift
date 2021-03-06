import Peek

public struct Shrub<Key: Hashable, Value> {
    
    public private(set) var unwrapped: Any?
}

extension Shrub {
    public init(_ shrub: Self) { self = shrub }
    public init(_ values: Value...) { self.unwrapped = values.isEmpty ? nil : values }
}

extension Shrub {
    
    public init<Values>(_ values: Values)
    where
        Values: Collection,
        Values.Element == Value
    {
        unwrapped = values.isEmpty ? nil : values
    }
    
    public init<Shrubbery>(_ values: Shrubbery)
    where
        Shrubbery: Collection,
        Shrubbery.Element == Self
    {
        unwrapped = values.isEmpty ? nil : values.map(\.unwrapped)
    }
}

extension Shrub {
    
    public init(_ dictionary: [Key: Value]) {
        unwrapped = dictionary.isEmpty ? nil : dictionary
    }
    
    public init(_ dictionary: [Key: Self]) {
        unwrapped = dictionary.isEmpty ? nil : dictionary.mapValues(\.unwrapped)
    }
}

extension Shrub {
    
    public typealias Index = EitherType<Int, Key>
    
    public static var empty: Self { .init() }
}

extension Shrub {
    
    public subscript<A>(_ path: Index..., as _: A.Type = A.self) -> A? {
        get {
            self[path, as: A.self]
        }
        set {
            self[path, as: A.self] = newValue
        }
    }

    public subscript<A, Path>(_ path: Path, as _: A.Type = A.self) -> A?
    where
        Path: Collection,
        Path.Element == Index
    {
        get {
            try? get(path, as: A.self)
        }
        set {
            _ = try? set(newValue, at: path)
        }
    }
}

extension Shrub {
    
    public subscript(_ path: Index...) -> Any? {
        get {
            self[path, as: Any.self]
        }
        set {
            self[path, as: Any.self] = newValue
        }
    }

    public subscript<Path>(_ path: Path) -> Any?
    where
        Path: Collection,
        Path.Element == Index
    {
        get {
            try? get(path, as: Any.self)
        }
        set {
            _ = try? set(newValue, at: path)
        }
    }
}

extension Shrub {
        
    public func get<Path>(_ path: Path) throws -> Self
    where
        Path: Collection,
        Path.Element == Index
    {
        try Shrub(unwrapped: Shrub<Key, Any>.get(path, in: self.unwrapped))
    }
}

extension Shrub {
    
    public mutating func set<A>(_ value: A, at path: Index...) throws {
        try set(value, at: path)
    }
    
    public mutating func set<Path, A>(_ value: A, at path: Path) throws
    where
        Path: Collection,
        Path.Element == Index
    {
        let value = (value as? Self)?.unwrapped ?? value
        try Shrub<Key, Any>.set(value, at: path, in: &unwrapped)
    }
}

extension Shrub {
    
    public mutating func set(_ value: Self, at path: Index...) throws {
        try set(value, at: path)
    }
    
    public mutating func set<Path>(_ value: Self, at path: Path) throws
    where
        Path: Collection,
        Path.Element == Index
    {
        try Shrub<Key, Any>.set(value.unwrapped, at: path, in: &unwrapped)
    }
}

// MARK: static get and set

extension Shrub where Value == Any {
    
    public static func get(_ path: Index..., in any: Any) throws -> Any
    where Key: Hashable
    {
        try get(path, in: any)
    }
    
    public static func get<Path>(_ path: Path, in any: Any) throws -> Any
    where
        Path: Collection,
        Path.Element == Index
    {
        guard let index = path.first else {
            return any
        }
        switch index.value
        {
        case .a(let int):
            guard let array = any as? [Any] else {
                throw "Expected [Any] but found \(type(of: any)) at \(index) in \(path)".error()
            }
            guard array.indices.contains(int) else {
                throw "Index \(int) in \(path) is out of bounds - found only \(array.count) elements".error()
            }
            return try get(path.dropFirst(), in: array[int])
            
        case .b(let key):
            guard let dictionary = any as? [Key: Any] else {
                throw "Expected [Any] but found \(type(of: any)) at \(key) in \(path)".error()
            }
            guard let any = dictionary[key] else {
                throw "No value found at \(key) in \(path)".error()
            }
            return try get(path.dropFirst(), in: any)
        }
    }
}

extension Shrub where Value == Any {
    
    public static func get(_ path: Index..., in any: Any?) throws -> Any
    where Key: Hashable
    {
        try get(path, in: any as Any)
    }
    
    public static func get<Path>(_ path: Path, in any: Any?) throws -> Any
    where
        Path: Collection,
        Path.Element == Index
    {
        try get(path, in: any as Any)
    }
}

extension Shrub where Value == Any {

    public static func set(_ value: Any?, at path: Index..., in any: inout Any) throws {
        try set(value, at: path, in: &any)
    }


    public static func set<Path>(_ value: Any?, at path: Path, in any: inout Any) throws
    where
        Path: Collection,
        Path.Element == Index
    {
        var o: Any? = any
        try set(value, at: path, in: &o)
        any = o as Any
    }
}

extension Shrub where Value == Any {
    
    public static var none: Any { Optional<Value>.none as Any }

    public static func set(_ value: Any?, at path: Index..., in this: inout Any?) throws {
        try set(value, at: path, in: &this)
    }

    public static func set<Path>(_ value: Any?, at path: Path, in this: inout Any?) throws
    where
        Path: Collection,
        Path.Element == Index
    {
        let value = flattenOptionality(
            of: (value as? Self)?.unwrapped ?? value
        )
        guard let index = path.first else {
            this = value
            return
        }
        switch index.value
        {
        case .a(let int):
            guard int >= 0 else { // TODO: allow relative indexing
                throw "Index in path \(path) is negative".error()
            }
            var array = this as? [Any] ?? []
            array.append(contentsOf: repeatElement(none, count: max(0, int - array.endIndex + 1)))
            var o: Any? = array[int]
            try Self.set(value, at: path.dropFirst(), in: &o)
            array[int] = o as Any
            for e in array.reversed() {
                guard isNilAfterFlattening(e) else { break }
                array.removeLast()
            }
            this = array.isEmpty ? none : array
            
        case .b(let key):
            var dictionary = this as? [Key: Any] ?? [:]
            var o: Any? = dictionary[key] ?? []
            try Self.set(value, at: path.dropFirst(), in: &o)
            dictionary[key] = o
            this = dictionary.isEmpty ? none : dictionary
        }
    }
}

// MARK: expresible

extension Shrub: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        unwrapped = nil
    }
}

extension Shrub: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Self...) {
        unwrapped = elements.map(\.unwrapped)
    }
}

extension Shrub: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Self)...) {
        let pairs = elements.map{ ($0, $1.unwrapped) }
        unwrapped = Dictionary(pairs){ _, last in last }
    }
}

public prefix func ^ <Key, Value>(array: [Value]) -> Shrub<Key, Value> {
    Shrub(array)
}

public prefix func ^ <Key, Value>(dictionary: [Key: Value]) -> Shrub<Key, Value> {
    Shrub(dictionary)
}

// TODO:❗️generalise further, e.g. ↓
//extension Shrub: ExpressibleByArrayLiteral {
//    public init(arrayLiteral elements: EitherType<Self, Value>...) {
//        any = elements.map{ o -> Any in
//            switch o.value {
//            case .a(let shrub): return shrub.any as Any
//            case .b(let value): return value
//            }
//        }
//    }
//}
