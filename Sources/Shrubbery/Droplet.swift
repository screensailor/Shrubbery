public protocol Droplet: CustomStringConvertible {
    
    associatedtype Value
    
    static func value(_: Value) -> Self
    static func error(_: Error) -> Self
    
    var isError: Bool { get }
    
    func get() throws -> Value
}

extension Droplet {
    
    public var description: String {
        do { return try "\(get())" }
        catch { return "⚠️ \(error)" }
    }
    
    @inlinable public init(_ ƒ: @autoclosure () throws -> Value) {
        self.init(ƒ)
    }
    
    @inlinable public init(_ ƒ: () throws -> Value) {
        do { self = try .value(ƒ()) }
        catch { self = .error(error) }
    }
}

extension Shrubbery where Self: Droplet { // AnyWrapper
    
    public var unwrapped: Any? { try? get() }
    
    public init(_ unwrapped: Any?) {
        if let o = unwrapped { self = .value(o) }
        else { self = .error("nil") }
    }
}

extension Shrubbery where Self: Droplet, Self.Key == String {

    @inlinable public func get(_ route: Route) throws -> Self {
        try map(route)
    }
    
    @inlinable public mutating func set(_ route: Route, to: Any?) {
        var o = try? get()
        Shrub<String>.set(route, in: &o, to: to)
        self = Self(o)
    }
    
    @inlinable public mutating func delete(_ route: Route) {
        set(route, to: nil)
    }
}

extension Shrubbery where Self: Droplet, Self.Key == String {

    public func map(_ route: Route) throws -> Self {
        try .value(
            Shrub.get(route, in: get())
        )
    }

    public func flatMap(_ route: Route) -> Self {
        Self {
            try Shrub.get(route, in: get())
        }
    }
}

extension Publisher where Output: Droplet, Failure == Never {
    
    public func cast<A>(to: A.Type = A.self) -> Publishers.Map<Self, Result<A, Error>> {
        map{ o in
            Result { () throws -> A in
                guard let r = try o.get() as? A else {
                    throw "\(o) of type \(type(of: o)) is not an \(A.self)" // TODO:❗️trace
                }
                return r
            }
        }
    }
    
    public func decode<A, D>(type: A.Type = A.self, decoder: D) -> Publishers.Map<Self, Result<A, Error>> where
        A: Decodable,
        D: TopLevelDecoder,
        D.Input == Any?
    {
        map{ o in
            Result {
                let o = try o.get()
                if let o = o as? A {
                    return o
                }
                return try decoder.decode(A.self, from: o)
            }
        }
    }
}

// MARK: Result

//public prefix func ^ <Value>(v: Value) -> Result<Value, Error> { .success(v) }
//public prefix func ^ <Key, Value>(v: Value) -> Result<Shrub<Key>, Error> { .success(.init(v)) }

extension Result: Droplet, CustomStringConvertible where Failure == Error {
    
    @inlinable public static func value(_ value: Success) -> Self { .success(value) }
    @inlinable public static func error<E: Error>(_ error: E) -> Self { .failure(error) }

    @inlinable public var isError: Bool { if case .failure = self { return true } else { return false } }
}

extension Result:
    Routed,
    Shrubbery,
    AnyWrapper,
    ExpressibleByNilLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    CustomDebugStringConvertible
where Success == Any?, Failure == Error {
    
    public typealias Key = String
}
