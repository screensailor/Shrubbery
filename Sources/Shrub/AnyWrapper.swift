public protocol AnyWrapper:
    ExpressibleByNilLiteral,
    CustomStringConvertible
{
    var unwrapped: Any? { get }
    init(_ unwrapped: Any?)
}

extension AnyWrapper {
    
    public init(nilLiteral: ()) {
        self.init(nil)
    }
}

extension AnyWrapper {
    
    public var description: String {
        String(describing: unwrapped ?? "nil")
    }
}
