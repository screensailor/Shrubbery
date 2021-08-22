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
    
    public mutating func set(_ route: Route, to: Any?) throws {
        var o = try? get()
        try Shrub<String>.set(route, in: &o, to: to)
        self = Self(o)
    }
    
    public mutating func delete(_ route: Route) {
        _ = try? set(route, to: nil)
    }
}

extension Shrubbery where Self: Droplet, Self.Key == String {

    public func map(_ route: Route) throws -> Self {
        do {
            guard let o = try Shrub.get(route, in: get()) else {
                throw "\(route) is nil"
            }
            return .value(o)
        } catch {
            return .error(error)
        }
    }

    public func flatMap(_ route: Route) -> Self {
        Self {
            guard let o = try Shrub.get(route, in: get()) else {
                throw "\(route) is nil"
            }
            return o
        }
    }
}

// MARK: Result

public prefix func ^ <Value>(v: Value) -> Result<Value, Error> { .success(v) }
public prefix func ^ <Key, Value>(v: Value) -> Result<Shrub<Key>, Error> { .success(.init(v)) }

extension Result: Droplet, CustomStringConvertible where Failure == Error {
    
    public static func value(_ value: Success) -> Self { .success(value) }
    public static func error<E: Error>(_ error: E) -> Self { .failure(error) }
    
    public var isError: Bool { if case .failure = self { return true } else { return false } }
}

extension Result:
    Shrubbery,
    AnyWrapper,
    ExpressibleByNilLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    CustomDebugStringConvertible
where Success == Any, Failure == Error {
    
    public init(arrayLiteral elements: Any...) { // TODO: implent in Shrubbery
        self.init(elements as Any)
    }
    
    public init(dictionaryLiteral elements: (String, Any)...) { // TODO: implent in Shrubbery
        self.init(Dictionary(elements){ _, last in last })
    }
}
