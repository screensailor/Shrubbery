public protocol AnyWrapper:
    ExpressibleByNilLiteral,
    CustomStringConvertible
{
    var unwrapped: Any? { get }
    init(_ unwrapped: Any?)
}

extension AnyWrapper {
    public init(nilLiteral: ()) { self.init(nil) }
}
