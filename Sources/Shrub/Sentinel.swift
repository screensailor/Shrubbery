public enum Sentinel: String {
    case deletion
}

extension Sentinel: CustomDebugStringConvertible {
    public var debugDescription: String { "\(Self.self).\(rawValue)" }
}

