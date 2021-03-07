public protocol Droplet {
    
    associatedtype Value
    
    static func value(_: Value) -> Self
    static func error<E: Error>(_: E) -> Self
    
    var isError: Bool { get }
    
    func get() throws -> Value
}

extension Result: Droplet, CustomStringConvertible where Failure == Error {
    
    public static func value(_ value: Success) -> Self { .success(value) }
    public static func error<E: Error>(_ error: E) -> Self { .failure(error) }
    
    public var isError: Bool { if case .failure = self { return true } else { return false } }
    
    public var description: String {
        switch self {
        case let .success(o): return "\(o)"
        case let .failure(o): return "⚠️ \(o)"
        }
    }
}
