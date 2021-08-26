public typealias ResultProtocol = Droplet

public protocol Droplet: CustomStringConvertible {
    
    associatedtype Success
    associatedtype Failure: Error
    
    static func success(_: Success) -> Self
    static func failure(_: Failure) -> Self
    
    var isSuccess: Bool { get }
    var isFailure: Bool { get }

    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure>
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> where NewFailure : Error
    func flatMap<NewSuccess>(_ transform: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure>
    func flatMapError<NewFailure>(_ transform: (Failure) -> Result<Success, NewFailure>) -> Result<Success, NewFailure> where NewFailure : Error
    func get() throws -> Success
}

extension Droplet {

    public var description: String {
        do { return try "\(Self.self).success(\(get()))" }
        catch { return "\(Self.self).failure(\(error))" }
    }
    
    @inlinable public func get(default o: Success) -> Success {
        (try? get()) ?? o
    }
}

extension Droplet where Failure == Error {
    
    public init(catching body: () throws -> Success) {
        do { self = try .success(body()) }
        catch { self = .failure(error) }
    }

    @inlinable public init(_ ƒ: @autoclosure () throws -> Success) {
        self.init(catching: ƒ)
    }
}

extension Shrubbery where Self: Droplet, Success == Any?, Failure == Error { // AnyWrapper
    
    public var unwrapped: Any? { try? get() }
    
    public init(_ unwrapped: Any?) {
        if let o = unwrapped { self = .success(o) }
        else { self = .failure("nil") }
    }
}

extension Shrubbery where Self.Key == String, Self: Droplet, Success == Any?, Failure == Error {

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

extension Shrubbery where Self.Key == String, Self: Droplet, Success == Any?, Failure == Error {

    public func map(_ route: Route) throws -> Self {
        try .success(
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

extension Result: Droplet, CustomStringConvertible {
    
    @inlinable public var isSuccess: Bool {
        switch self {
        case .failure: return false
        case .success: return true
        }
    }
    
    @inlinable public var isFailure: Bool {
        switch self {
        case .failure: return true
        case .success: return false
        }
    }
}

extension Result:
    Routed,
    Shrubbery,
    AnyWrapper,
    ExpressibleByNilLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
    CustomDebugStringConvertible
where
    Success == Any?,
    Failure == Error
{
    public typealias Key = String
    public typealias ArrayLiteralElement = Any?
}
