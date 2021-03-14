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
}

// MARK: Result

public prefix func ^ <Value>(v: Value) -> Result<Value, Error> { .success(v) }
public prefix func ^ <Key, Value>(v: Value) -> Result<Shrub<Key, Value>, Error> { .success(.init(v)) }

extension JSON {
    public typealias Result = Swift.Result<JSON, Error>
}

extension Result: Droplet, CustomStringConvertible where Failure == Error {
    
    public static func value(_ value: Success) -> Self { .success(value) }
    public static func error<E: Error>(_ error: E) -> Self { .failure(error) }
    
    public var isError: Bool { if case .failure = self { return true } else { return false } }
}
