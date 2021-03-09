import Peek

prefix operator ^ /// lift operator

public prefix func ^ <Key, Value>(a: Value) -> Shrub<Key, Value> { .init(a) }

public struct Shrub<Key, Value>: Shrubbery
where Key: Hashable
{    
    public private(set) var unwrapped: Any?
    
    public init(_ unwrapped: Any? = nil) { try! set(unwrapped, at: []) }

    public func get(_ path: [Index]) throws -> Shrub {
        try Self(ShrubAny.get(path, in: self.unwrapped))
    }
    
    mutating
    public func set(_ value: Any?, at path: [Index]) throws {
        try ShrubAny.set(value, at: path, in: &unwrapped)
    }
}

// MARK: static get & set

public typealias ShrubAny<Key> = Shrub<Key, Any?> where Key: Hashable

extension ShrubAny {

    public static func get(_ path: Index..., in any: Any?) throws -> Any? {
        try get(path, in: any)
    }
    
    public static func get<Path>(_ path: Path, in any: Any?) throws -> Any?
    where
        Path: Collection,
        Path.Element == Index
    {
        let ºany = flattenOptionality(
            of: (any as? AnyWrapper)?.unwrapped ?? any
        )
        guard let index = path.first else {
            return ºany
        }
        guard let any = ºany else {
            throw "Expected \(path) but found nil".error()
        }
        switch index.value
        {
        case .a(let int):
            guard let array = any as? [Any] else {
                throw "Expected [Any] but found \(type(of: any)) at '\(index)' in \(path)".error()
            }
            guard array.indices.contains(int) else {
                throw "Index \(int) in \(path) is out of bounds - found only \(array.count) elements".error()
            }
            return try get(path.dropFirst(), in: array[int])
            
        case .b(let key):
            guard let dictionary = any as? [Key: Any] else {
                throw "Expected [Any] but found \(type(of: any)) at '\(key)' in \(path)".error()
            }
            guard let any = dictionary[key] else {
                throw "No value found at \(key) in \(path)".error()
            }
            return try get(path.dropFirst(), in: any)
        }
    }
}

extension ShrubAny {
    
    public static var none: Any { Optional<Value>.none as Any }

    public static func set(_ value: Any?, at path: Index..., in any: inout Any?) throws {
        try set(value, at: path, in: &any)
    }

    public static func set<Path>(_ value: Any?, at path: Path, in any: inout Any?) throws
    where
        Path: Collection,
        Path.Element == Index
    {
        let value = flattenOptionality(
            of: (value as? AnyWrapper)?.unwrapped ?? value
        )
        guard let index = path.first else {
            any = value
            return
        }
        switch index.value
        {
        case .a(let int):
            guard int >= 0 else { // TODO: allow relative indexing
                throw "Index in path \(path) is negative".error()
            }
            var array = any as? [Any] ?? []
            array.append(contentsOf: repeatElement(none, count: max(0, int - array.endIndex + 1)))
            var o: Any? = array[int]
            try Self.set(value, at: path.dropFirst(), in: &o)
            array[int] = o as Any
            for e in array.reversed() {
                guard isNilAfterFlattening(e) else { break }
                array.removeLast()
            }
            any = array.isEmpty ? none : array
            
        case .b(let key):
            var dictionary = any as? [Key: Any] ?? [:]
            var o: Any? = dictionary[key] ?? []
            try Self.set(value, at: path.dropFirst(), in: &o)
            dictionary[key] = o
            any = dictionary.isEmpty ? none : dictionary
        }
    }
}
