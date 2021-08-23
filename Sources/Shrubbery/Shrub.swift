public struct Shrub<Key>: Shrubbery where Key: Hashable {

    public private(set) var unwrapped: Any?
    
    public init(_ unwrapped: Any? = nil) { set([], to: unwrapped) }

    @inlinable public func get(_ route: Route) throws -> Self {
        try Self(Self.get(route, in: self.unwrapped))
    }

    public mutating func set(_ route: Route, to value: Any?) {
        Self.set(route, in: &unwrapped, to: value)
    }

    public mutating func delete(_ route: Route) {
        Self.set(route, in: &unwrapped, to: nil)
    }

    public mutating func delete() {
        Self.set(in: &unwrapped, to: nil)
    }
}

// MARK: static get

extension Shrub {

    public static func get(_ route: Fork..., in any: Any?) throws -> Any? {
        try get(route, in: any)
    }
    
    public static func get<Route>(_ route: Route, in any: Any?) throws -> Any?
    where
        Route: Collection,
        Route.Element == Fork
    {
        let ºany = flattenOptionality(
            of: (any as? AnyWrapper)?.unwrapped ?? any
        )
        guard let index = route.first else {
            return ºany
        }
        guard let any = ºany else {
            throw "Expected \(route) but found nil"
        }
        switch index.value
        {
        case .a(let int):
            guard let array = any as? [Any] else {
                throw "Expected [Any] but found \(type(of: any)) at '\(index)' in \(route)"
            }
            guard array.indices.contains(int) else {
                throw "Index \(int) in \(route) is out of bounds - found only \(array.count) elements"
            }
            return try get(route.dropFirst(), in: array[int])
            
        case .b(let key):
            guard let dictionary = any as? [Key: Any] else {
                throw "Expected [\(Key.self): Any] but found \(type(of: any)) at '\(key)' in \(route)"
            }
            guard let any = dictionary[key] else {
                throw "No value found at \(key) in \(route)"
            }
            return try get(route.dropFirst(), in: any)
        }
    }
}

// MARK: static set

extension Shrub {
    
    public static var none: Any { Optional<Value>.none as Any }

    public static func set(_ route: Fork..., in any: inout Any?, to value: Any?) {
        set(route, in: &any, to: value)
    }

    public static func set<Route>(_ route: Route, in any: inout Any?, to value: Any?) where
        Route: Collection,
        Route.Element == Fork
    {
        let value = flattenOptionality(
            of: (value as? AnyWrapper)?.unwrapped ?? value
        )
        guard let index = route.first else {
            any = value
            return
        }
        switch index.value
        {
        case .a(let int):
            guard int >= 0 else {
                // TODO: allow relative indexing
                return
            }
            var array = any as? [Any] ?? []
            array.append(contentsOf: repeatElement(none, count: max(0, int - array.endIndex + 1)))
            var o: Any? = array[int]
            Self.set(route.dropFirst(), in: &o, to: value)
            array[int] = o ?? none
            for e in array.reversed() {
                guard isNilAfterFlattening(e) else { break }
                array.removeLast()
            }
            any = array.isEmpty ? none : array
            
        case .b(let key):
            var dictionary = any as? [Key: Any] ?? [:]
            var o: Any? = dictionary[key] ?? []
            Self.set(route.dropFirst(), in: &o, to: value)
            dictionary[key] = o
            any = dictionary.isEmpty ? none : dictionary
        }
    }
}
