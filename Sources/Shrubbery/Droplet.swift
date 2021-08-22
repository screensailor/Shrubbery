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
    
    @inlinable public mutating func set(_ route: Route, to: Any?) throws {
        var o = try? get()
        try Shrub<String>.set(route, in: &o, to: to)
        self = Self(o)
    }
    
    @inlinable public mutating func delete(_ route: Route) {
        _ = try? set(route, to: nil)
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

// MARK: Result

public prefix func ^ <Value>(v: Value) -> Result<Value, Error> { .success(v) }
public prefix func ^ <Key, Value>(v: Value) -> Result<Shrub<Key>, Error> { .success(.init(v)) }

extension Result: Droplet, CustomStringConvertible where Failure == Error {
    
    @inlinable public static func value(_ value: Success) -> Self { .success(value) }
    @inlinable public static func error<E: Error>(_ error: E) -> Self { .failure(error) }

    @inlinable public var isError: Bool { if case .failure = self { return true } else { return false } }
}

extension Result:
    Shrubbery,
    AnyWrapper,
    ExpressibleByNilLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    CustomDebugStringConvertible
where Success == Any?, Failure == Error {

    public init(arrayLiteral elements: Any?...) { // TODO: inherit
        self.init(elements)
    }
    
    public init(dictionaryLiteral elements: (String, Any?)...) { // TODO: inherit
        self.init(Dictionary(elements){ _, last in last })
    }
}
